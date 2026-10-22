import 'dart:convert';
import 'constants.dart';
import 'settings.dart';
import 'storage.dart';
import '../models/profile.dart';
import '../models/app_filter.dart';
import '../models/rule.dart';

/// 应用级配置聚合。
///
/// 包含应用设置、订阅列表、分应用规则、自定义分流规则与审计链头。
class NovaClashConfig {
  AppSettings settings;
  List<Profile> profiles;
  List<AppFilter> appFilters;
  List<Rule> customRules;
  String auditChainHead;

  NovaClashConfig({
    required this.settings,
    required this.profiles,
    required this.appFilters,
    required this.customRules,
    this.auditChainHead = '',
  });

  factory NovaClashConfig.defaults() => NovaClashConfig(
        settings: AppSettings(),
        profiles: [],
        appFilters: [],
        customRules: [],
      );

  Map<String, dynamic> toJson() => {
        'settings': settings.toJson(),
        'profiles': profiles.map((e) => e.toJson()).toList(),
        'appFilters': appFilters.map((e) => e.toJson()).toList(),
        'customRules': customRules.map((e) => e.toJson()).toList(),
        'auditChainHead': auditChainHead,
      };

  factory NovaClashConfig.fromJson(Map<String, dynamic> json) => NovaClashConfig(
        settings: AppSettings.fromJson(
            json['settings'] as Map<String, dynamic>? ?? const {}),
        profiles: (json['profiles'] as List<dynamic>? ?? const [])
            .map((e) => Profile.fromJson(e as Map<String, dynamic>))
            .toList(),
        appFilters: (json['appFilters'] as List<dynamic>? ?? const [])
            .map((e) => AppFilter.fromJson(e as Map<String, dynamic>))
            .toList(),
        customRules: (json['customRules'] as List<dynamic>? ?? const [])
            .map((e) => Rule.fromJson(e as Map<String, dynamic>))
            .toList(),
        auditChainHead: json['auditChainHead'] as String? ?? '',
      );

  /// 从磁盘加载，文件不存在时返回默认配置。
  static Future<NovaClashConfig> load() async {
    final data = await Storage.readJson(AppConstants.appConfigFileName);
    if (data == null) {
      final def = NovaClashConfig.defaults();
      await def.save();
      return def;
    }
    try {
      return NovaClashConfig.fromJson(data);
    } catch (_) {
      return NovaClashConfig.defaults();
    }
  }

  Future<void> save() async {
    await Storage.writeJson(AppConstants.appConfigFileName, toJson());
  }

  String exportJson() => const JsonEncoder.withIndent('  ').convert(toJson());
}
