import 'package:flutter/material.dart';
import 'app.dart';
import 'core/config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final config = await NovaClashConfig.load();
  runApp(NovaClashApp(initialConfig: config));
}
