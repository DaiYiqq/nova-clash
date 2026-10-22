import 'proxy.dart';

/// 代理组（Proxy Group）。
///
/// 类型对应 mihomo 核心的 Selector / URLTest / Fallback / LoadBalance 等。
/// [now] 为当前选中的节点名（Selector 为手动选中，URLTest 为测速最优）。
class ProxyGroup {
  final String name;
  final String type;
  final List<String> proxies;
  final String? now;
  final String? url;
  final int? interval;

  const ProxyGroup({
    required this.name,
    required this.type,
    required this.proxies,
    this.now,
    this.url,
    this.interval,
  });

  factory ProxyGroup.fromJson(Map<String, dynamic> json) => ProxyGroup(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? 'Selector',
        proxies: (json['all'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        now: json['now'] as String?,
        url: json['url'] as String?,
        interval: json['interval'] as int?,
      );

  bool get isSelector => type.toLowerCase() == 'selector';
  bool get isUrlTest => type.toLowerCase() == 'urltest';
  bool get isFallback => type.toLowerCase() == 'fallback';
  bool get isLoadBalance => type.toLowerCase() == 'loadbalance';

  /// 组类型友好名。
  String get typeLabel {
    switch (type.toLowerCase()) {
      case 'selector':
        return '手动选择';
      case 'urltest':
        return '自动测速';
      case 'fallback':
        return '故障转移';
      case 'loadbalance':
        return '负载均衡';
      default:
        return type;
    }
  }

  @override
  String toString() => 'ProxyGroup($name, $type, now=$now)';
}
