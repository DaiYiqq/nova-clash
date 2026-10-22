import 'dart:math' as math;

import '../core/constants.dart';
import '../core/core_state.dart';
import '../core/storage.dart';
import '../models/node_health.dart';
import 'ai_recommend_service.dart';

/// 节点健康评分服务（创新功能 2）。
///
/// 通过多次采样延迟计算均值、抖动、丢包与可用性，合成健康评分，
/// 并将历史健康数据持久化到本地。
class NodeHealthService {
  NodeHealthService();

  /// 单节点采样次数。
  static const int _sampleCount = 3;

  /// 对全部（或指定）节点进行测速采样并计算健康度。
  Future<Map<String, NodeHealth>> testAll(
    CoreState core, {
    List<String>? nodes,
    String? url,
  }) async {
    final targets = nodes ?? core.proxies.keys.toList();
    final result = <String, NodeHealth>{};
    for (final name in targets) {
      final latencies = <int>[];
      for (var i = 0; i < _sampleCount; i++) {
        latencies.add(await core.testDelay(name, url: url));
      }
      result[name] = compute(name, latencies);
    }
    // 同步到运行时状态，供 UI 直接展示。
    core.health = result;
    core.notifyListeners();
    return result;
  }

  /// 由多次采样延迟列表计算健康度。
  ///
  /// 成功样本（>0）均值作为 [NodeHealth.latencyMs]，标准差作为抖动，
  /// 超时样本占比作为丢包，成功占比作为可用性，再合成综合评分。
  NodeHealth compute(String name, List<int> latencies) {
    final now = DateTime.now();
    if (latencies.isEmpty) {
      return NodeHealth(nodeName: name, latencyMs: -1, testedAt: now);
    }
    final ok = latencies.where((l) => l > 0).toList();
    final total = latencies.length;
    final success = ok.length;
    if (success == 0) {
      return NodeHealth(
        nodeName: name,
        latencyMs: -1,
        jitterMs: 0,
        packetLoss: 1,
        uptime: 0,
        score: 0,
        testedAt: now,
      );
    }
    final mean = ok.reduce((a, b) => a + b) / success;
    final variance =
        ok.map((l) => (l - mean) * (l - mean)).reduce((a, b) => a + b) /
            success;
    final jitter = math.sqrt(variance);
    final packetLoss = (total - success) / total;
    final uptime = success / total;
    final base = NodeHealth(
      nodeName: name,
      latencyMs: mean.round(),
      jitterMs: jitter,
      packetLoss: packetLoss,
      uptime: uptime,
      score: 0,
      testedAt: now,
    );
    final s = AiRecommendService.score(base);
    return NodeHealth(
      nodeName: name,
      latencyMs: mean.round(),
      jitterMs: jitter,
      packetLoss: packetLoss,
      uptime: uptime,
      score: s,
      testedAt: now,
    );
  }

  /// 读取历史健康记录（节点名 -> 记录列表）。
  Future<Map<String, List<NodeHealth>>> loadHistory() async {
    final data = await Storage.readJson(AppConstants.healthHistoryFileName);
    if (data == null) return {};
    final result = <String, List<NodeHealth>>{};
    data.forEach((key, value) {
      if (value is List) {
        result[key] = value
            .whereType<Map<String, dynamic>>()
            .map(NodeHealth.fromJson)
            .toList();
      }
    });
    return result;
  }

  /// 保存历史健康记录。
  Future<void> saveHistory(Map<String, List<NodeHealth>> history) async {
    final data = <String, dynamic>{};
    history.forEach((key, value) {
      data[key] = value.map((e) => e.toJson()).toList();
    });
    await Storage.writeJson(AppConstants.healthHistoryFileName, data);
  }
}
