import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'core/config.dart';
import 'core/config_provider.dart';
import 'core/core_state.dart';
import 'theme/app_theme.dart';
import 'pages/home_page.dart';

/// 应用根组件。
class NovaClashApp extends StatefulWidget {
  final NovaClashConfig initialConfig;

  const NovaClashApp({super.key, required this.initialConfig});

  @override
  State<NovaClashApp> createState() => _NovaClashAppState();
}

class _NovaClashAppState extends State<NovaClashApp> {
  late final ConfigProvider _configProvider =
      ConfigProvider(widget.initialConfig);
  late final CoreState _coreState = CoreState();

  ThemeMode _themeMode(String v) {
    switch (v) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _configProvider),
        ChangeNotifierProvider.value(value: _coreState),
      ],
      child: Consumer<ConfigProvider>(
        builder: (context, cfg, _) {
          return MaterialApp(
            title: 'NovaClash',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: _themeMode(cfg.settings.themeMode),
            locale: const Locale('zh', 'CN'),
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('zh', 'CN'), Locale('en', 'US')],
            home: const HomePage(),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _coreState.dispose();
    _configProvider.dispose();
    super.dispose();
  }
}
