import '../models/node_health.dart';

/// AI 智能选路服务（创新功能 1）。
///
/// 依据节点健康度综合评分，在候选节点中挑选最优节点。
/// 评分权重：延迟 40%、抖动 20%、丢包 20%、历史稳定性 20%，归一化为 0..100。
class AiRecommendService {
  AiRecommendService._();

  /// 延迟评分拐点：低于该值视为满分（毫秒）。
  static const double _latencyBestMs = 30;

  /// 延迟评分拐点：高于该值视为 0 分（毫秒）。
  static const double _latencyWorstMs = 600;

  /// 抖动评分拐点：低于该值视为满分（毫秒）。
  static const double _jitterBestMs = 5;

  /// 抖动评分拐点：高于该值视为 0 分（毫秒）。
  static const double _jitterWorstMs = 120;

  /// 综合评分：延迟 40%、抖动 20%、丢包 20%、历史稳定性 20%。
  /// [h.latencyMs] 为 -1（或 <=0）时视为不可用，返回 0。
  static double score(NodeHealth h) {
    if (h.latencyMs <= 0) return 0;
    final latency =
        _linear(h.latencyMs.toDouble(), _latencyBestMs, _latencyWorstMs);
    final jitter = _linear(h.jitterMs, _jitterBestMs, _jitterWorstMs);
    final loss = (1 - _clampUnit(h.packetLoss)) * 100;
    final uptime = _clampUnit(h.uptime) * 100;
    final result = latency * 0.4 + jitter * 0.2 + loss * 0.2 + uptime * 0.2;
    return _clamp100(result);
  }

  /// 从 [nodes] 中挑选健康评分最高的节点；无可用的返回 null。
  String? recommend(List<String> nodes, Map<String, NodeHealth> health) {
    String? best;
    var bestScore = 0.0;
    for (final name in nodes) {
      final h = health[name];
      if (h == null) continue;
      final s = score(h);
      if (s > bestScore) {
        bestScore = s;
        best = name;
      }
    }
    return best;
  }

  /// 将指标线性映射到 0..100：<=good 得 100，>=bad 得 0。
  static double _linear(double value, double good, double bad) {
    if (value <= good) return 100;
    if (value >= bad) return 0;
    return 100 * (1 - (value - good) / (bad - good));
  }

  static double _clampUnit(double v) => v < 0 ? 0.0 : (v > 1 ? 1.0 : v);

  static double _clamp100(double v) => v < 0 ? 0.0 : (v > 100 ? 100.0 : v);
}
