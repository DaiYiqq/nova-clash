import 'constants.dart';

/// 应用设置（App Settings）。
///
/// 集中管理全部创新功能的开关与参数，持久化到 app_config.json。
class AppSettings {
  // 基础
  String themeMode; // system / light / dark
  ProxyMode connectionMode;
  bool autoConnect;
  bool launchAtStartup;

  // 端口与控制器
  int mixedPort;
  int socksPort;
  int controllerPort;
  String controllerSecret;

  // 创新 1：AI 智能选路
  bool aiRecommendEnabled;

  // 创新 2：节点健康评分
  bool healthScoreEnabled;

  // 创新 3：分应用代理
  bool perAppEnabled;

  // 创新 4：隐私护盾
  bool privacyShieldEnabled;
  bool blockWebRTCLeak;
  bool randomizeTlsFingerprint;
  String dnsOverHttpsUrl;

  // 创新 5：智能分流引擎
  bool smartRoutingEnabled;

  // 创新 6：数据用量预测
  bool forecastEnabled;

  // 创新 7：一键体检（网络诊断）
  bool diagnosisEnabled;

  // 创新 8：订阅自动更新
  bool subscriptionAutoUpdate;
  int subscriptionUpdateIntervalHours;

  // 创新 9：代理链（多级代理）
  bool proxyChainEnabled;
  String proxyChainRelayGroup;

  // 创新 10：局域网共享 + 设备白名单
  bool lanShareEnabled;
  bool allowLan;
  List<String> lanDeviceAllowlist;

  // 创新 11：能耗优化
  bool ecoModeEnabled;

  // 创新 12：安全审计日志
  bool auditEnabled;

  // 创新 13：定时静默模式
  bool quietHoursEnabled;
  String quietStart; // "23:00"
  String quietEnd; // "07:00"

  // 创新 14：自动故障转移
  bool autoFailoverEnabled;
  String failoverBackupGroup;

  // 创新 15：DNS 抗污染
  bool dnsAntiPollutionEnabled;

  AppSettings({
    this.themeMode = 'system',
    this.connectionMode = ProxyMode.rule,
    this.autoConnect = false,
    this.launchAtStartup = false,
    this.mixedPort = 7890,
    this.socksPort = 7891,
    this.controllerPort = AppConstants.controllerPort,
    this.controllerSecret = '',
    this.aiRecommendEnabled = true,
    this.healthScoreEnabled = true,
    this.perAppEnabled = false,
    this.privacyShieldEnabled = false,
    this.blockWebRTCLeak = true,
    this.randomizeTlsFingerprint = false,
    this.dnsOverHttpsUrl = 'https://dns.alidns.com/dns-query',
    this.smartRoutingEnabled = false,
    this.forecastEnabled = true,
    this.diagnosisEnabled = true,
    this.subscriptionAutoUpdate = true,
    this.subscriptionUpdateIntervalHours = 24,
    this.proxyChainEnabled = false,
    this.proxyChainRelayGroup = '',
    this.lanShareEnabled = false,
    this.allowLan = false,
    List<String>? lanDeviceAllowlist,
    this.ecoModeEnabled = false,
    this.auditEnabled = true,
    this.quietHoursEnabled = false,
    this.quietStart = '23:00',
    this.quietEnd = '07:00',
    this.autoFailoverEnabled = false,
    this.failoverBackupGroup = '',
    this.dnsAntiPollutionEnabled = false,
  }) : lanDeviceAllowlist = lanDeviceAllowlist ?? const [];

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        themeMode: json['themeMode'] as String? ?? 'system',
        connectionMode:
            ProxyModeX.fromApi(json['connectionMode'] as String? ?? 'rule'),
        autoConnect: json['autoConnect'] as bool? ?? false,
        launchAtStartup: json['launchAtStartup'] as bool? ?? false,
        mixedPort: (json['mixedPort'] as num?)?.toInt() ?? 7890,
        socksPort: (json['socksPort'] as num?)?.toInt() ?? 7891,
        controllerPort:
            (json['controllerPort'] as num?)?.toInt() ?? AppConstants.controllerPort,
        controllerSecret: json['controllerSecret'] as String? ?? '',
        aiRecommendEnabled: json['aiRecommendEnabled'] as bool? ?? true,
        healthScoreEnabled: json['healthScoreEnabled'] as bool? ?? true,
        perAppEnabled: json['perAppEnabled'] as bool? ?? false,
        privacyShieldEnabled: json['privacyShieldEnabled'] as bool? ?? false,
        blockWebRTCLeak: json['blockWebRTCLeak'] as bool? ?? true,
        randomizeTlsFingerprint: json['randomizeTlsFingerprint'] as bool? ?? false,
        dnsOverHttpsUrl: json['dnsOverHttpsUrl'] as String? ??
            'https://dns.alidns.com/dns-query',
        smartRoutingEnabled: json['smartRoutingEnabled'] as bool? ?? false,
        forecastEnabled: json['forecastEnabled'] as bool? ?? true,
        diagnosisEnabled: json['diagnosisEnabled'] as bool? ?? true,
        subscriptionAutoUpdate: json['subscriptionAutoUpdate'] as bool? ?? true,
        subscriptionUpdateIntervalHours:
            (json['subscriptionUpdateIntervalHours'] as num?)?.toInt() ?? 24,
        proxyChainEnabled: json['proxyChainEnabled'] as bool? ?? false,
        proxyChainRelayGroup: json['proxyChainRelayGroup'] as String? ?? '',
        lanShareEnabled: json['lanShareEnabled'] as bool? ?? false,
        allowLan: json['allowLan'] as bool? ?? false,
        lanDeviceAllowlist: (json['lanDeviceAllowlist'] as List<dynamic>? ?? const [])
            .map((e) => e.toString())
            .toList(),
        ecoModeEnabled: json['ecoModeEnabled'] as bool? ?? false,
        auditEnabled: json['auditEnabled'] as bool? ?? true,
        quietHoursEnabled: json['quietHoursEnabled'] as bool? ?? false,
        quietStart: json['quietStart'] as String? ?? '23:00',
        quietEnd: json['quietEnd'] as String? ?? '07:00',
        autoFailoverEnabled: json['autoFailoverEnabled'] as bool? ?? false,
        failoverBackupGroup: json['failoverBackupGroup'] as String? ?? '',
        dnsAntiPollutionEnabled: json['dnsAntiPollutionEnabled'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'connectionMode': connectionMode.apiValue,
        'autoConnect': autoConnect,
        'launchAtStartup': launchAtStartup,
        'mixedPort': mixedPort,
        'socksPort': socksPort,
        'controllerPort': controllerPort,
        'controllerSecret': controllerSecret,
        'aiRecommendEnabled': aiRecommendEnabled,
        'healthScoreEnabled': healthScoreEnabled,
        'perAppEnabled': perAppEnabled,
        'privacyShieldEnabled': privacyShieldEnabled,
        'blockWebRTCLeak': blockWebRTCLeak,
        'randomizeTlsFingerprint': randomizeTlsFingerprint,
        'dnsOverHttpsUrl': dnsOverHttpsUrl,
        'smartRoutingEnabled': smartRoutingEnabled,
        'forecastEnabled': forecastEnabled,
        'diagnosisEnabled': diagnosisEnabled,
        'subscriptionAutoUpdate': subscriptionAutoUpdate,
        'subscriptionUpdateIntervalHours': subscriptionUpdateIntervalHours,
        'proxyChainEnabled': proxyChainEnabled,
        'proxyChainRelayGroup': proxyChainRelayGroup,
        'lanShareEnabled': lanShareEnabled,
        'allowLan': allowLan,
        'lanDeviceAllowlist': lanDeviceAllowlist,
        'ecoModeEnabled': ecoModeEnabled,
        'auditEnabled': auditEnabled,
        'quietHoursEnabled': quietHoursEnabled,
        'quietStart': quietStart,
        'quietEnd': quietEnd,
        'autoFailoverEnabled': autoFailoverEnabled,
        'failoverBackupGroup': failoverBackupGroup,
        'dnsAntiPollutionEnabled': dnsAntiPollutionEnabled,
      };
}
