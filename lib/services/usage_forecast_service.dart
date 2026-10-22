import '../models/traffic.dart';

/// 数据用量预测服务（创新功能 6）。
///
/// 根据历史流量速率估算未来一天的数据用量（MB）。
class UsageForecastService {
  UsageForecastService();

  /// 根据历史流量点预测每日用量（MB）。
  ///
  /// 取最近若干采样点的平均速率（上行+下行），外推到 24 小时。
  double predictDailyMb(List<TrafficPoint> history) {
    if (history.isEmpty) return 0;
    // 最多取最近 288 个点（按 5 分钟一个点约覆盖 24 小时）。
    final recent =
        history.length > 288 ? history.sublist(history.length - 288) : history;
    var totalRate = 0.0;
    for (final p in recent) {
      totalRate += p.upPerSec + p.downPerSec;
    }
    final avgRate = totalRate / recent.length;
    final dailyBytes = avgRate * 86400;
    return dailyBytes / (1024 * 1024);
  }
}
