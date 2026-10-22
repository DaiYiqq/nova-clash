/// 全局常量。
class AppConstants {
  AppConstants._();

  static const String appName = 'NovaClash';
  static const String appVersion = '0.1.0';
  static const int appBuild = 1;

  /// mihomo 外部控制器地址（本地回环）。
  static const String controllerHost = '127.0.0.1';
  static const int controllerPort = 9090;

  /// 核心二进制文件名（按平台区分，由用户/打包脚本提供）。
  static const String coreBinaryName = 'nova_core';
  static const String coreConfigDirName = 'nova_clash';
  static const String coreConfigFileName = 'config.yaml';

  /// 应用本地配置文件名。
  static const String appConfigFileName = 'app_config.json';
  static const String profilesFileName = 'profiles.json';
  static const String healthHistoryFileName = 'health_history.json';
  static const String auditLogFileName = 'audit_log.json';

  /// 测速与健康度检测默认地址。
  static const String defaultTestUrl = 'https://www.gstatic.com/generate_204';

  /// 本项目开源仓库。
  static const String repoUrl = 'https://github.com/Daiyiqq/nova-clash';
  static const String issueUrl = 'https://github.com/Daiyiqq/nova-clash/issues';

  /// 开发者信息。
  static const String developerName = 'Daiyiqq';
  static const String developerEmail = '1703205607@qq.com';
  static const String developerSite = 'https://github.com/Daiyiqq';
}

/// 代理模式（连接模式）。
enum ProxyMode { rule, global, direct }

extension ProxyModeX on ProxyMode {
  String get label {
    switch (this) {
      case ProxyMode.rule:
        return '规则模式';
      case ProxyMode.global:
        return '全局模式';
      case ProxyMode.direct:
        return '直连模式';
    }
  }

  String get apiValue {
    switch (this) {
      case ProxyMode.rule:
        return 'rule';
      case ProxyMode.global:
        return 'global';
      case ProxyMode.direct:
        return 'direct';
    }
  }

  static ProxyMode fromApi(String v) {
    switch (v) {
      case 'global':
        return ProxyMode.global;
      case 'direct':
        return ProxyMode.direct;
      default:
        return ProxyMode.rule;
    }
  }
}
