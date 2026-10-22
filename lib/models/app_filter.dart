/// 分应用代理条目（创新功能 3：分应用代理）。
class AppFilter {
  final String packageName;
  final String appName;
  final String? proxyGroup;
  final bool enabled;

  const AppFilter({
    required this.packageName,
    required this.appName,
    this.proxyGroup,
    this.enabled = true,
  });

  factory AppFilter.fromJson(Map<String, dynamic> json) => AppFilter(
        packageName: json['packageName'] as String? ?? '',
        appName: json['appName'] as String? ?? '',
        proxyGroup: json['proxyGroup'] as String?,
        enabled: json['enabled'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'packageName': packageName,
        'appName': appName,
        'proxyGroup': proxyGroup,
        'enabled': enabled,
      };

  @override
  String toString() => 'AppFilter($appName -> $proxyGroup)';
}
