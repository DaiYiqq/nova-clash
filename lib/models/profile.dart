/// 订阅配置（Profile）。
///
/// 对应一个订阅链接及其解析出的节点集合，支持流量/到期信息展示。
class Profile {
  final String id;
  final String name;
  final String url;
  final String? userAgent;
  final DateTime? updatedAt;
  final DateTime? expireAt;
  final int? totalBytes;
  final int? usedBytes;

  const Profile({
    required this.id,
    required this.name,
    required this.url,
    this.userAgent,
    this.updatedAt,
    this.expireAt,
    this.totalBytes,
    this.usedBytes,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '未命名',
        url: json['url'] as String? ?? '',
        userAgent: json['userAgent'] as String?,
        updatedAt: json['updatedAt'] != null
            ? DateTime.tryParse(json['updatedAt'].toString())
            : null,
        expireAt: json['expireAt'] != null
            ? DateTime.tryParse(json['expireAt'].toString())
            : null,
        totalBytes: json['totalBytes'] as int?,
        usedBytes: json['usedBytes'] as int?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'url': url,
        'userAgent': userAgent,
        'updatedAt': updatedAt?.toIso8601String(),
        'expireAt': expireAt?.toIso8601String(),
        'totalBytes': totalBytes,
        'usedBytes': usedBytes,
      };

  /// 剩余天数，未知返回 null。
  int? get remainDays {
    final exp = expireAt;
    if (exp == null) return null;
    final d = exp.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  /// 已用流量占比 0..1，未知返回 null。
  double? get usedRatio {
    if (totalBytes == null || usedBytes == null || totalBytes == 0) return null;
    return (usedBytes! / totalBytes!).clamp(0.0, 1.0);
  }

  @override
  String toString() => 'Profile($name)';
}
