import '../core/settings.dart';

/// DNS 抗污染服务（创新功能 15）。
///
/// 生成 mihomo 的 DNS 配置补丁，通过 DoH/DoT 与回落过滤避免 DNS 污染。
class DnsAntiPollutionService {
  DnsAntiPollutionService();

  /// 构建 DNS 抗污染补丁；未启用时返回空 Map。
  Map<String, dynamic> buildDnsPatch(AppSettings s) {
    if (!s.dnsAntiPollutionEnabled) return const {};
    final doh = s.dnsOverHttpsUrl.trim().isEmpty
        ? 'https://dns.alidns.com/dns-query'
        : s.dnsOverHttpsUrl.trim();
    return {
      'dns': {
        'enable': true,
        'enhanced-mode': 'fake-ip',
        'nameserver': [doh, 'tls://223.5.5.5', 'tls://1.1.1.1'],
        'fallback': ['tls://1.1.1.1', 'tls://8.8.8.8'],
        'fallback-filter': {
          'geoip': true,
          'ipcidr': ['240.0.0.0/4', '0.0.0.0/32'],
        },
      },
    };
  }
}
