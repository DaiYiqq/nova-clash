/// 能耗优化服务（创新功能 11）。
///
/// 根据网络可用性与屏幕状态判断是否应进入节流（节能）模式。
class EcoModeService {
  EcoModeService();

  /// 是否应节流：无网络或熄屏时进入节能，暂停高频刷新与测速。
  bool shouldThrottle(bool networkAvailable, bool screenOn) {
    return !networkAvailable || !screenOn;
  }
}
