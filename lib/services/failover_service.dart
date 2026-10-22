import '../core/core_state.dart';
import '../core/settings.dart';
import 'node_health_service.dart';

/// 自动故障转移服务（创新功能 14）。
///
/// 检测当前使用节点健康度，不健康时自动切换到组内更优节点，
/// 或切换到备份策略组。
class FailoverService {
  FailoverService();

  /// 健康度阈值：低于该值视为需要转移。
  static const double _failThreshold = 40;

  /// 尝试故障转移；返回是否发生了切换。
  Future<bool> maybeFailover(
    CoreState core,
    AppSettings s,
    NodeHealthService health,
  ) async {
    if (!s.autoFailoverEnabled) return false;
    final result = await health.testAll(core);
    if (result.isEmpty) return false;

    var switched = false;
    for (final g in core.groups.values) {
      final current = g.now;
      if (current == null) continue;
      final currentHealth = result[current];
      // 当前节点不可用或健康度过低。
      final unhealthy = currentHealth == null ||
          currentHealth.latencyMs <= 0 ||
          currentHealth.score < _failThreshold;
      if (!unhealthy) continue;

      // 1) 优先在组内找更优节点。
      String? best;
      var bestScore = currentHealth?.score ?? 0;
      for (final node in g.proxies) {
        final h = result[node];
        if (h == null || h.latencyMs <= 0) continue;
        if (h.score > bestScore) {
          bestScore = h.score;
          best = node;
        }
      }
      if (best != null && best != current) {
        if (await core.selectNode(g.name, best)) switched = true;
        continue;
      }

      // 2) 组内无更优节点，尝试切换到备份组。
      final backup = s.failoverBackupGroup.trim();
      if (backup.isNotEmpty && backup != g.name) {
        if (await core.selectNode(g.name, backup)) switched = true;
      }
    }
    return switched;
  }
}
