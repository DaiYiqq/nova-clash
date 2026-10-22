import '../core/settings.dart';

/// 定时静默模式服务（创新功能 13）。
///
/// 判断当前时间是否处于静默时段（免打扰），用于暂停代理或降频。
class SchedulerService {
  SchedulerService();

  /// 判断 [now] 是否处于静默时段；支持跨午夜区间。
  bool isInQuietHours(AppSettings s, DateTime now) {
    if (!s.quietHoursEnabled) return false;
    final start = _parseMinutes(s.quietStart);
    final end = _parseMinutes(s.quietEnd);
    if (start == null || end == null) return false;
    final current = now.hour * 60 + now.minute;
    if (start <= end) {
      return current >= start && current < end;
    }
    // 跨午夜：如 23:00 ~ 07:00。
    return current >= start || current < end;
  }

  /// 解析 "HH:mm" 为当天分钟数；失败返回 null。
  int? _parseMinutes(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length != 2) return null;
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    if (h < 0 || h > 23 || m < 0 || m > 59) return null;
    return h * 60 + m;
  }
}
