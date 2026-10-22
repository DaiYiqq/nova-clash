import '../models/app_filter.dart';

/// 分应用代理服务（创新功能 3）。
///
/// 将应用过滤规则转换为 mihomo 可识别的 PROCESS-NAME 规则文本片段。
class PerAppService {
  PerAppService();

  /// 生成分应用代理规则片段（仅包含启用的应用）。
  ///
  /// 每条规则形如 PROCESS-NAME,<包名>,<策略组>；未指定策略组的应用回退到
  /// 默认策略组 PROXY。无启用项时返回空字符串。
  String buildRuleSnippet(List<AppFilter> filters) {
    final buffer = StringBuffer();
    var wroteHeader = false;
    for (final f in filters) {
      if (!f.enabled || f.packageName.trim().isEmpty) continue;
      final group = f.proxyGroup?.trim() ?? '';
      final target = group.isEmpty ? 'PROXY' : group;
      if (!wroteHeader) {
        buffer.writeln('# 分应用代理规则（PROCESS-NAME）');
        wroteHeader = true;
      }
      buffer.writeln('PROCESS-NAME,' + f.packageName.trim() + ',' + target);
    }
    return buffer.toString().trim();
  }
}
