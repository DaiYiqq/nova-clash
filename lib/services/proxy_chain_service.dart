/// 代理链（多级代理）服务（创新功能 9）。
///
/// 生成 mihomo 的 relay 代理组配置片段，用于实现多级代理（链式节点）。
class ProxyChainService {
  ProxyChainService();

  /// 构建 relay 代理组文本片段。
  ///
  /// 使用 mihomo 的 type: relay 组实现链式代理，入口节点与出口节点
  /// 需按实际节点名填写。
  String buildRelaySnippet(String relayGroup) {
    final name = relayGroup.trim().isEmpty ? 'RELAY-CHAIN' : relayGroup.trim();
    return '''
# 代理链（多级代理）：type: relay 依次经过列表中的节点
proxy-groups:
  - name: $name
    type: relay
    # 入口节点（如香港中转）在前，出口节点（如美国落地）在后，可多级
    proxies:
      - 入口节点
      - 出口节点
''';
  }
}
