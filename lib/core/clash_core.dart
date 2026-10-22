import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'constants.dart';
import 'external_controller.dart';

/// mihomo / Clash 核心进程管理。
///
/// 负责定位核心二进制、生成配置目录、启动/停止子进程，
/// 并暴露外部控制器客户端。与 FlClash 内嵌 mihomo 的思路一致。
class ClashCore {
  Process? _process;
  ExternalController? _controller;

  bool get isRunning => _process != null;

  ExternalController? get controller => _controller;

  /// 定位核心二进制（优先应用支持目录，其次应用资源目录）。
  Future<String?> resolveCoreBinary() async {
    final base = await getApplicationSupportDirectory();
    final candidates = <String>[
      base.path +
          Platform.pathSeparator +
          'nova_clash' +
          Platform.pathSeparator +
          AppConstants.coreBinaryName,
      AppConstants.coreBinaryName,
    ];
    for (final c in candidates) {
      if (File(c).existsSync()) return c;
    }
    return null;
  }

  Future<Directory> configDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(base.path +
        Platform.pathSeparator +
        AppConstants.coreConfigDirName);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// 启动核心进程。
  ///
  /// [configPath] 为 mihomo 配置文件绝对路径；[secret] 为外部控制器密钥。
  Future<void> start({required String configPath, String secret = ''}) async {
    if (isRunning) return;
    final binary = await resolveCoreBinary();
    if (binary == null) {
      throw StateError(
          '未找到核心二进制，请将 mihomo/clash 核心放置到应用支持目录的 nova_core 文件。');
    }
    final dir = await configDir();
    final args = <String>[
      '-d',
      dir.path,
      '-f',
      configPath,
      '-ext-ctl',
      AppConstants.controllerHost + ':' + AppConstants.controllerPort.toString(),
    ];
    if (secret.isNotEmpty) {
      args.addAll(['-ext-ctl-secret', secret]);
    }
    _process = await Process.start(binary, args, workingDirectory: dir.path);
    _process!.stdout.drain<void>().ignore();
    _process!.stderr.drain<void>().ignore();
    _controller = ExternalController(
      baseUrl: 'http://' +
          AppConstants.controllerHost +
          ':' +
          AppConstants.controllerPort.toString(),
      secret: secret,
    );
  }

  Future<void> stop() async {
    if (_process == null) return;
    final p = _process!;
    _process = null;
    _controller?.close();
    _controller = null;
    p.kill(ProcessSignal.sigterm);
    // 等待退出，超时则强制结束，避免僵尸进程。
    await p.exitCode.timeout(const Duration(seconds: 2), onTimeout: () {
      p.kill(ProcessSignal.sigkill);
      return 0;
    });
  }

  Future<void> restart({required String configPath, String secret = ''}) async {
    await stop();
    await start(configPath: configPath, secret: secret);
  }
}
