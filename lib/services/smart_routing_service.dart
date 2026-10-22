import '../core/settings.dart';
import '../models/app_filter.dart';
import '../models/rule.dart';

/// 智能分流引擎服务（创新功能 5）。
///
/// 依据应用设置与分应用过滤规则生成内置智能分流规则：国内直连、
/// 境外代理、按应用分流等。
class SmartRoutingService {
  SmartRoutingService();

  /// 构建智能分流规则列表；未启用时返回空列表。
  List<Rule> buildRules(AppSettings s, List<AppFilter> filters) {
    final rules = <Rule>[];
    if (!s.smartRoutingEnabled) return rules;

    // 国内域名直连。
    const directSuffixes = [
      'cn',
      'com.cn',
      'net.cn',
      'org.cn',
      'gov.cn',
      'taobao.com',
      'tmall.com',
      'jd.com',
      'qq.com',
      'weixin.qq.com',
      'baidu.com',
      'bilibili.com',
      'zhihu.com',
      'douyin.com',
      'bytedance.com',
    ];
    for (final d in directSuffixes) {
      rules.add(Rule(type: 'DOMAIN-SUFFIX', payload: d, proxy: 'DIRECT'));
    }
    rules.add(const Rule(type: 'GEOIP', payload: 'CN', proxy: 'DIRECT'));

    // 常见境外服务走代理。
    const proxySuffixes = [
      'google.com',
      'googleapis.com',
      'gstatic.com',
      'youtube.com',
      'ytimg.com',
      'twitter.com',
      'x.com',
      'facebook.com',
      'fbcdn.net',
      'instagram.com',
      'telegram.org',
      't.me',
      'openai.com',
      'github.com',
      'cloudflare.com',
    ];
    for (final d in proxySuffixes) {
      rules.add(Rule(type: 'DOMAIN-SUFFIX', payload: d, proxy: 'PROXY'));
    }

    // 分应用代理规则。
    for (final f in filters) {
      if (!f.enabled || f.packageName.trim().isEmpty) continue;
      final group = f.proxyGroup?.trim() ?? '';
      final target = group.isEmpty ? 'PROXY' : group;
      rules.add(Rule(
        type: 'PROCESS-NAME',
        payload: f.packageName.trim(),
        proxy: target,
      ));
    }

    return rules;
  }
}
