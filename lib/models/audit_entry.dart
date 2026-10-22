/// 安全审计日志条目（创新功能 12：安全审计日志）。
///
/// 每个条目带链式哈希，实现防篡改审计。
class AuditEntry {
  final DateTime time;
  final String category;
  final String action;
  final String detail;
  final String prevHash;
  final String hash;

  const AuditEntry({
    required this.time,
    required this.category,
    required this.action,
    required this.detail,
    required this.prevHash,
    required this.hash,
  });

  factory AuditEntry.fromJson(Map<String, dynamic> json) => AuditEntry(
        time: DateTime.tryParse(json['time'].toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
        category: json['category'] as String? ?? '',
        action: json['action'] as String? ?? '',
        detail: json['detail'] as String? ?? '',
        prevHash: json['prevHash'] as String? ?? '',
        hash: json['hash'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'time': time.toIso8601String(),
        'category': category,
        'action': action,
        'detail': detail,
        'prevHash': prevHash,
        'hash': hash,
      };

  @override
  String toString() => 'AuditEntry($time, $category/$action)';
}
