import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// 本地 JSON 持久化工具。
///
/// 所有配置文件统一存放在应用支持目录下的 nova_clash 子目录中。
class Storage {
  Storage._();

  static Future<Directory> appDir() async {
    final base = await getApplicationSupportDirectory();
    final dir = Directory(base.path + Platform.pathSeparator + 'nova_clash');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  static Future<File> file(String name) async {
    final dir = await appDir();
    return File(dir.path + Platform.pathSeparator + name);
  }

  static Future<void> writeJson(String name, Map<String, dynamic> data) async {
    final f = await file(name);
    await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data));
  }

  static Future<Map<String, dynamic>?> readJson(String name) async {
    try {
      final f = await file(name);
      if (!await f.exists()) return null;
      final text = await f.readAsString();
      final decoded = jsonDecode(text);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } catch (_) {
      return null;
    }
  }

  static Future<void> writeText(String name, String text) async {
    final f = await file(name);
    await f.writeAsString(text);
  }

  static Future<String?> readText(String name) async {
    try {
      final f = await file(name);
      if (!await f.exists()) return null;
      return await f.readAsString();
    } catch (_) {
      return null;
    }
  }

  static Future<void> delete(String name) async {
    try {
      final f = await file(name);
      if (await f.exists()) await f.delete();
    } catch (_) {}
  }
}
