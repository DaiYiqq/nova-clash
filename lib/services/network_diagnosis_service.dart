import '../core/core_state.dart';
import '../core/external_controller.dart';
import '../models/traffic.dart';

/// 一键体检（网络诊断）服务（创新功能 7）。
class NetworkDiagnosisService {
  NetworkDiagnosisService();

  /// 运行一系列诊断项并返回结果列表。
  Future<List<DiagnosisItem>> run(
    ExternalController ctl,
    CoreState core,
  ) async {
    final items = <DiagnosisItem>[];

    // 1. 核心进程运行状态。
    final running = await ctl.isRunning();
    items.add(DiagnosisItem(
      name: '核心进程',
      ok: running,
      detail: running ? 'mihomo 核心正在运行' : '无法连接外部控制器，核心可能未启动',
    ));

    // 2. 核心版本。
    final version = await ctl.version();
    items.add(DiagnosisItem(
      name: '核心版本',
      ok: version.isNotEmpty,
      detail: version.isNotEmpty ? version : '未获取到版本信息',
    ));

    // 3. 节点加载。
    final proxyCount = core.proxies.length;
    items.add(DiagnosisItem(
      name: '节点加载',
      ok: proxyCount > 0,
      detail: proxyCount > 0 ? '共 $proxyCount 个节点' : '未加载到任何节点',
    ));

    // 4. 策略组加载。
    final groupCount = core.groups.length;
    items.add(DiagnosisItem(
      name: '策略组',
      ok: groupCount > 0,
      detail: groupCount > 0 ? '共 $groupCount 个策略组' : '未加载到任何策略组',
    ));

    // 5. 节点连通性（选取一个可测速节点）。
    final probe = _pickProbe(core);
    if (probe == null) {
      items.add(const DiagnosisItem(
        name: '节点连通性',
        ok: false,
        detail: '没有可用于测速的节点',
      ));
    } else {
      final delay = await ctl.testDelay(probe);
      items.add(DiagnosisItem(
        name: '节点连通性',
        ok: delay > 0,
        detail: delay > 0 ? '$probe：$delay ms' : '$probe：测速失败或超时',
      ));
    }

    // 6. 实时流量统计。
    final traffic = await ctl.getTraffic();
    items.add(DiagnosisItem(
      name: '实时流量',
      ok: true,
      detail: '上行 ' +
          TrafficSnapshot.formatBytes(traffic.up) +
          ' / 下行 ' +
          TrafficSnapshot.formatBytes(traffic.down),
    ));

    return items;
  }

  /// 挑选一个适合测速的节点：优先非 direct/reject 节点。
  String? _pickProbe(CoreState core) {
    final names = core.proxies.keys.toList();
    if (names.isEmpty) return null;
    for (final n in names) {
      final t = (core.proxies[n]?.type ?? '').toLowerCase();
      if (t != 'direct' && t != 'reject') return n;
    }
    return names.first;
  }
}

/// 单个诊断项。
class DiagnosisItem {
  final String name;
  final bool ok;
  final String detail;

  const DiagnosisItem({
    required this.name,
    required this.ok,
    required this.detail,
  });
}
