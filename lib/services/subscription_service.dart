import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;

import '../core/external_controller.dart';
import '../models/profile.dart';

/// 订阅服务（创新功能 8：订阅自动更新）。
class SubscriptionService {
  SubscriptionService();

  /// 拉取订阅 URL 内容；失败返回 null。
  ///
  /// 兼容常见的 base64 编码订阅（节点列表）。
  Future<String?> fetchSubscription(String url) async {
    try {
      final res =
          await http.get(Uri.parse(url)).timeout(const Duration(seconds: 30));
      if (res.statusCode != 200) return null;
      var text = _decodeBytes(res.bodyBytes);
      text = _tryBase64(text);
      return text;
    } catch (_) {
      return null;
    }
  }

  /// 更新单个订阅对应的核心 providers/proxies 提供者。
  ///
  /// 先验证订阅可访问，再按名称匹配核心中的 provider 并触发更新。
  Future<bool> updateProfile(Profile p, ExternalController ctl) async {
    final content = await fetchSubscription(p.url);
    if (content == null) return false;
    final names = await ctl.getProviderNames();
    String? target;
    for (final n in names) {
      if (n == p.name ||
          n == p.id ||
          (p.name.isNotEmpty && n.contains(p.name))) {
        target = n;
        break;
      }
    }
    if (target == null) return false;
    return await ctl.updateProvider(target);
  }

  /// 比较两段订阅内容是否发生变化（内容哈希不同即视为变化）。
  bool detectChange(String a, String b) => _hash(a) != _hash(b);

  String _hash(String input) => sha256.convert(utf8.encode(input)).toString();

  String _decodeBytes(List<int> bytes) {
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  /// 若内容形似 base64（不含常见 URI 协议头），尝试解码。
  String _tryBase64(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.contains('://')) return text;
    try {
      return utf8.decode(base64.decode(trimmed));
    } catch (_) {
      return text;
    }
  }
}
