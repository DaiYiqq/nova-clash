/// 实时流量快照（上行 / 下行字节数，累计值）。
class TrafficSnapshot {
  final int up;
  final int down;

  const TrafficSnapshot({this.up = 0, this.down = 0});

  factory TrafficSnapshot.fromJson(Map<String, dynamic> json) => TrafficSnapshot(
        up: (json['up'] as num?)?.toInt() ?? 0,
        down: (json['down'] as num?)?.toInt() ?? 0,
      );

  TrafficSnapshot operator -(TrafficSnapshot other) => TrafficSnapshot(
        up: up - other.up,
        down: down - other.down,
      );

  static String formatBytes(int bytes) {
    if (bytes < 1024) return bytes.toString() + ' B';
    if (bytes < 1024 * 1024) {
      return (bytes / 1024).toStringAsFixed(1) + ' KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return (bytes / 1024 / 1024).toStringAsFixed(1) + ' MB';
    }
    return (bytes / 1024 / 1024 / 1024).toStringAsFixed(2) + ' GB';
  }

  /// 每秒速率的人类可读形式。
  static String formatSpeed(int bytesPerSec) =>
      formatBytes(bytesPerSec) + '/s';

  @override
  String toString() => 'Traffic(up=$up, down=$down)';
}

/// 一段时间窗口内的历史流量点，用于绘制图表。
class TrafficPoint {
  final DateTime time;
  final int upPerSec;
  final int downPerSec;

  const TrafficPoint({
    required this.time,
    required this.upPerSec,
    required this.downPerSec,
  });
}
