import '../core/external_controller.dart';

/// 局域网共享服务（创新功能 10）。
///
/// 通过切换 mihomo 的 allow-lan 与 bind-address 实现局域网设备共享代理。
class LanShareService {
  LanShareService();

  /// 开启局域网共享：允许局域网连接并监听所有网卡。
  Future<bool> enable(ExternalController ctl, int mixedPort) async {
    return await ctl.patchConfig({
      'allow-lan': true,
      'bind-address': '*',
      'mixed-port': mixedPort,
    });
  }

  /// 关闭局域网共享：仅本机可访问。
  Future<bool> disable(ExternalController ctl) async {
    return await ctl.patchConfig({
      'allow-lan': false,
      'bind-address': '127.0.0.1',
    });
  }
}
