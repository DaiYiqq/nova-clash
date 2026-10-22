import '../core/settings.dart';

/// 隐私护盾服务（创新功能 4）。
///
/// 生成用于写入 mihomo 配置的隐私保护补丁：DNS over HTTPS、
/// 随机化 TLS 指纹、屏蔽 WebRTC 泄露（STUN 域名）。
class PrivacyShieldService {
  PrivacyShieldService();

  /// 构建隐私护盾配置补丁；未启用时返回空 Map。
  Map<String, dynamic> buildPatch(AppSettings s) {
    if (!s.privacyShieldEnabled) return const {};
    final patch = <String, dynamic>{};

    // DNS over HTTPS：避免明文 DNS 泄露。
    if (s.dnsOverHttpsUrl.trim().isNotEmpty) {
      patch['dns'] = {
        'enable': true,
        'enhanced-mode': 'fake-ip',
        'nameserver': [s.dnsOverHttpsUrl.trim()],
      };
    }

    // 随机化 TLS 指纹：降低被指纹追踪的风险。
    if (s.randomizeTlsFingerprint) {
      patch['global-client-fingerprint'] = 'random';
    }

    // 屏蔽 WebRTC 泄露：将常见 STUN 服务器解析到本机回环。
    if (s.blockWebRTCLeak) {
      patch['sniffer'] = {'enable': true};
      patch['hosts'] = {
        'stun.l.google.com': '127.0.0.1',
        'stun1.l.google.com': '127.0.0.1',
        'stun2.l.google.com': '127.0.0.1',
        'stun.ekiga.net': '127.0.0.1',
        'stun.ideasip.com': '127.0.0.1',
      };
    }

    return patch;
  }
}
