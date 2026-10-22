import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/proxy.dart';
import '../models/proxy_group.dart';
import '../models/traffic.dart';
import '../models/rule.dart';

/// mihomo / Clash 外部控制器 REST API 客户端。
///
/// 封装节点/组查询、节点切换、流量、配置、规则、测速等接口。
class ExternalController {
  final String baseUrl;
  final String secret;
  final http.Client _client = http.Client();

  ExternalController({required this.baseUrl, this.secret = ''});

  Map<String, String> get _headers =>
      secret.isEmpty ? {} : {'Authorization': 'Bearer $secret'};

  Uri _u(String path) => Uri.parse(baseUrl + path);

  Future<bool> isRunning() async {
    try {
      final res = await _client.get(_u('/version'), headers: _headers).timeout(
            const Duration(seconds: 2),
          );
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<String> version() async {
    try {
      final res =
          await _client.get(_u('/version'), headers: _headers).timeout(
                const Duration(seconds: 3),
              );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final v = data['version'] as String? ?? data['meta'] as String? ?? '';
        return v;
      }
    } catch (_) {}
    return '';
  }

  /// 获取全部代理组（含 "all" 字段的条目）。
  Future<Map<String, ProxyGroup>> getProxyGroups() async {
    final all = await _rawProxies();
    final result = <String, ProxyGroup>{};
    all.forEach((name, data) {
      if (data is Map<String, dynamic> && data.containsKey('all')) {
        result[name] = ProxyGroup.fromJson(data);
      }
    });
    return result;
  }

  /// 获取全部单个节点（不含 "all" 字段的条目）。
  Future<Map<String, Proxy>> getAllProxies() async {
    final all = await _rawProxies();
    final result = <String, Proxy>{};
    all.forEach((name, data) {
      if (data is Map<String, dynamic> && !data.containsKey('all')) {
        result[name] = Proxy.fromJson(data);
      }
    });
    return result;
  }

  Future<Map<String, dynamic>> _rawProxies() async {
    try {
      final res =
          await _client.get(_u('/proxies'), headers: _headers).timeout(
                const Duration(seconds: 5),
              );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['proxies'] as Map<String, dynamic>? ?? const {};
      }
    } catch (_) {}
    return const {};
  }

  Future<bool> selectProxy(String group, String node) async {
    try {
      final res = await _client
          .put(
            _u('/proxies/' + Uri.encodeComponent(group)),
            headers: _headers,
            body: jsonEncode({'name': node}),
          )
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<TrafficSnapshot> getTraffic() async {
    try {
      final res = await _client.get(_u('/traffic'), headers: _headers).timeout(
            const Duration(seconds: 3),
          );
      if (res.statusCode == 200) {
        return TrafficSnapshot.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
      }
    } catch (_) {}
    return const TrafficSnapshot();
  }

  Future<Map<String, dynamic>> getConfig() async {
    try {
      final res =
          await _client.get(_u('/configs'), headers: _headers).timeout(
                const Duration(seconds: 5),
              );
      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return const {};
  }

  Future<bool> patchConfig(Map<String, dynamic> patch) async {
    try {
      final res = await _client
          .patch(
            _u('/configs'),
            headers: {..._headers, 'Content-Type': 'application/json'},
            body: jsonEncode(patch),
          )
          .timeout(const Duration(seconds: 5));
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<bool> setMode(String mode) => patchConfig({'mode': mode});

  Future<bool> reloadConfig() async {
    try {
      final res = await _client
          .put(
            _u('/configs'),
            headers: _headers,
            body: jsonEncode({'force': true}),
          )
          .timeout(const Duration(seconds: 8));
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<Rule>> getRules() async {
    try {
      final res =
          await _client.get(_u('/rules'), headers: _headers).timeout(
                const Duration(seconds: 5),
              );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final rules = data['rules'] as List<dynamic>? ?? const [];
        return rules
            .whereType<Map<String, dynamic>>()
            .map((e) {
              final payload = e['payload'];
              if (payload is List) {
                return (payload)
                    .map((p) => Rule(
                          type: e['type'] as String? ?? '',
                          payload: p.toString(),
                          proxy: e['proxy'] as String? ?? '',
                        ))
                    .toList();
              }
              return [
                Rule(
                  type: e['type'] as String? ?? '',
                  payload: payload.toString(),
                  proxy: e['proxy'] as String? ?? '',
                )
              ];
            })
            .expand((e) => e)
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  /// 测速，返回毫秒延迟；超时/失败返回 -1。
  Future<int> testDelay(String proxy,
      {String? url, int timeout = 5000}) async {
    try {
      final testUrl = url ?? 'https://www.gstatic.com/generate_204';
      final query = Uri(queryParameters: {'url': testUrl, 'timeout': '$timeout'})
          .query;
      final res = await _client
          .get(
            _u('/proxies/' + Uri.encodeComponent(proxy) + '/delay?' + query),
            headers: _headers,
          )
          .timeout(Duration(milliseconds: timeout + 1000));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['delay'] as num?)?.toInt() ?? -1;
      }
    } catch (_) {}
    return -1;
  }

  Future<List<String>> getProviderNames() async {
    try {
      final res = await _client
          .get(_u('/providers/proxies'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final providers = data['providers'] as Map<String, dynamic>? ?? const {};
        return providers.keys.toList();
      }
    } catch (_) {}
    return const [];
  }

  Future<bool> updateProvider(String name) async {
    try {
      final res = await _client
          .put(
            _u('/providers/proxies/' + Uri.encodeComponent(name)),
            headers: _headers,
          )
          .timeout(const Duration(seconds: 30));
      return res.statusCode == 204 || res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<dynamic>> getConnections() async {
    try {
      final res = await _client
          .get(_u('/connections'), headers: _headers)
          .timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return data['connections'] as List<dynamic>? ?? const [];
      }
    } catch (_) {}
    return const [];
  }

  void close() => _client.close();
}
