import 'package:flutter/foundation.dart';
import 'config.dart';
import 'settings.dart';
import '../models/profile.dart';
import '../models/app_filter.dart';
import '../models/rule.dart';

/// 应用配置 Provider（ChangeNotifier）。
///
/// 包装 NovaClashConfig，供 UI 读取与修改设置、订阅、规则等。
class ConfigProvider extends ChangeNotifier {
  NovaClashConfig config;

  ConfigProvider(this.config);

  AppSettings get settings => config.settings;

  void updateSettings(AppSettings s) {
    config.settings = s;
    notifyListeners();
  }

  void addProfile(Profile p) {
    config.profiles.add(p);
    notifyListeners();
  }

  void removeProfile(String id) {
    config.profiles.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  void addAppFilter(AppFilter f) {
    config.appFilters.add(f);
    notifyListeners();
  }

  void removeAppFilter(String packageName) {
    config.appFilters.removeWhere((e) => e.packageName == packageName);
    notifyListeners();
  }

  void addCustomRule(Rule r) {
    config.customRules.add(r);
    notifyListeners();
  }

  void removeCustomRule(int index) {
    if (index >= 0 && index < config.customRules.length) {
      config.customRules.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> save() async {
    await config.save();
    notifyListeners();
  }
}
