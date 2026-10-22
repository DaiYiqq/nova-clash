/// 单个代理节点（Proxy）。
///
/// 对应 mihomo/Clash 核心 REST API 返回的 proxies 列表中的一项。
/// 兼容 SS / SSR / VMess / VLESS / Trojan / Hysteria2 / TUIC / WireGuard 等协议。
class Proxy {
  final String name;
  final String type;
  final bool udp;

  final String? server;
  final int? port;
  final String? uuid;
  final String? password;
  final String? sni;
  final String? network;
  final String? wsPath;
  final String? tls;
  final String? servername;
  final String? clientFingerprint;
  final String? obfs;
  final String? protocol;
  final String? cipher;
  final String? flow;
  final String? publicKey;
  final String? privateKey;

  const Proxy({
    required this.name,
    required this.type,
    this.udp = false,
    this.server,
    this.port,
    this.uuid,
    this.password,
    this.sni,
    this.network,
    this.wsPath,
    this.tls,
    this.servername,
    this.clientFingerprint,
    this.obfs,
    this.protocol,
    this.cipher,
    this.flow,
    this.publicKey,
    this.privateKey,
  });

  factory Proxy.fromJson(Map<String, dynamic> json) => Proxy(
        name: json['name'] as String? ?? '',
        type: json['type'] as String? ?? 'unknown',
        udp: json['udp'] as bool? ?? false,
        server: json['server'] as String?,
        port: json['port'] as int?,
        uuid: json['uuid'] as String?,
        password: json['password'] as String?,
        sni: json['sni'] as String?,
        network: json['network'] as String?,
        wsPath: (json['ws-opts'] as Map<String, dynamic>?)?['path'] as String?,
        tls: json['tls'] as bool? == true ? 'true' : null,
        servername: json['servername'] as String?,
        clientFingerprint: json['client-fingerprint'] as String?,
        obfs: json['obfs'] as String?,
        protocol: json['protocol'] as String?,
        cipher: json['cipher'] as String?,
        flow: json['flow'] as String?,
        publicKey: json['public-key'] as String?,
        privateKey: json['private-key'] as String?,
      );

  /// 节点展示用的一行摘要（协议 + 主机）。
  String get summary {
    if (server != null && server!.isNotEmpty) {
      return '$type · $server' + (port != null ? ':$port' : '');
    }
    return type;
  }

  /// 类型对应的友好显示名。
  String get typeLabel {
    const map = {
      'ss': 'Shadowsocks',
      'ssr': 'ShadowsocksR',
      'vmess': 'VMess',
      'vless': 'VLESS',
      'trojan': 'Trojan',
      'hysteria2': 'Hysteria2',
      'hy2': 'Hysteria2',
      'tuic': 'TUIC',
      'wireguard': 'WireGuard',
      'socks5': 'SOCKS5',
      'http': 'HTTP',
      'direct': '直连',
      'reject': '拒绝',
    };
    return map[type.toLowerCase()] ?? type;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'type': type,
        'udp': udp,
        'server': server,
        'port': port,
        'uuid': uuid,
        'password': password,
        'sni': sni,
        'network': network,
        'tls': tls,
        'servername': servername,
        'client-fingerprint': clientFingerprint,
        'obfs': obfs,
        'protocol': protocol,
        'cipher': cipher,
        'flow': flow,
        'public-key': publicKey,
        'private-key': privateKey,
      };

  @override
  String toString() => 'Proxy($name, $type)';
}
