/// 分流规则（Rule）。
///
/// 同时支持内置规则展示与用户自定义规则编辑。
class Rule {
  final String type; // DOMAIN-SUFFIX / DOMAIN / IP-CIDR / GEOIP / MATCH ...
  final String payload;
  final String proxy; // 命中后走哪个策略组
  final bool enabled;
  final bool isCustom;

  const Rule({
    required this.type,
    required this.payload,
    required this.proxy,
    this.enabled = true,
    this.isCustom = false,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        type: json['type'] as String? ?? '',
        payload: json['payload'] as String? ?? '',
        proxy: json['proxy'] as String? ?? '',
        enabled: json['enabled'] as bool? ?? true,
        isCustom: json['isCustom'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'type': type,
        'payload': payload,
        'proxy': proxy,
        'enabled': enabled,
        'isCustom': isCustom,
      };

  /// 完整规则文本（用于写入 mihomo 配置）。
  String toText() => '$type,$payload,$proxy';

  /// 从 mihomo 返回的规则行解析（形如 "DOMAIN-SUFFIX,google.com,PROXY"）。
  factory Rule.parse(String line) {
    final parts = line.split(',');
    if (parts.length < 3) {
      return Rule(type: 'RAW', payload: line, proxy: 'DIRECT');
    }
    return Rule(
      type: parts[0].trim(),
      payload: parts[1].trim(),
      proxy: parts[2].trim(),
    );
  }

  @override
  String toString() => toText();
}
