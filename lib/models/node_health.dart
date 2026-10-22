/// 节点健康度（创新功能 2：节点健康评分）。
///
/// 综合延迟、抖动、丢包率、历史稳定性计算 0..100 的综合评分。
class NodeHealth {
  final String nodeName;
  final int latencyMs; // -1 表示未知/超时
  final double jitterMs;
  final double packetLoss; // 0..1
  final double uptime; // 0..1
  final double score; // 0..100
  final DateTime testedAt;

  const NodeHealth({
    required this.nodeName,
    required this.latencyMs,
    this.jitterMs = 0,
    this.packetLoss = 0,
    this.uptime = 1,
    this.score = 0,
    required this.testedAt,
  });

  factory NodeHealth.fromJson(Map<String, dynamic> json) => NodeHealth(
        nodeName: json['nodeName'] as String? ?? '',
        latencyMs: (json['latencyMs'] as num?)?.toInt() ?? -1,
        jitterMs: (json['jitterMs'] as num?)?.toDouble() ?? 0,
        packetLoss: (json['packetLoss'] as num?)?.toDouble() ?? 0,
        uptime: (json['uptime'] as num?)?.toDouble() ?? 1,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        testedAt: DateTime.tryParse(json['testedAt'].toString()) ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );

  Map<String, dynamic> toJson() => {
        'nodeName': nodeName,
        'latencyMs': latencyMs,
        'jitterMs': jitterMs,
        'packetLoss': packetLoss,
        'uptime': uptime,
        'score': score,
        'testedAt': testedAt.toIso8601String(),
      };

  /// 健康等级（用于 UI 徽标）。
  String get grade {
    if (score >= 85) return '优秀';
    if (score >= 70) return '良好';
    if (score >= 50) return '一般';
    if (score > 0) return '较差';
    return '未知';
  }

  @override
  String toString() => 'NodeHealth($nodeName, $latencyMs ms, $score)';
}
