import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../core/constants.dart';
import '../core/storage.dart';
import '../models/audit_entry.dart';

/// 安全审计日志服务（创新功能 12）。
///
/// 每条日志带链式 SHA-256 哈希，实现防篡改审计：
/// hash = sha256(prevHash + time + category + action + detail)。
class AuditService {
  AuditService();

  String _chainHead = '';

  /// 当前审计链头（最新一条日志的哈希）。
  String get chainHead => _chainHead;

  /// 读取全部审计日志，并同步链头。
  Future<List<AuditEntry>> entries() async {
    final list = await _load();
    if (list.isNotEmpty) _chainHead = list.last.hash;
    return list;
  }

  /// 追加一条审计日志并返回该条目。
  Future<AuditEntry> log(
    String category,
    String action,
    String detail,
  ) async {
    final list = await _load();
    final prev = list.isEmpty ? _chainHead : list.last.hash;
    if (list.isNotEmpty) _chainHead = list.last.hash;
    final time = DateTime.now();
    final timeStr = time.toIso8601String();
    final hash = _hashOf(prev, timeStr, category, action, detail);
    final entry = AuditEntry(
      time: time,
      category: category,
      action: action,
      detail: detail,
      prevHash: prev,
      hash: hash,
    );
    list.add(entry);
    _chainHead = hash;
    await _save(list);
    return entry;
  }

  /// 校验整条审计链是否完整未被篡改。
  bool verifyChain(List<AuditEntry> list) {
    var prev = '';
    for (final e in list) {
      if (e.prevHash != prev) return false;
      final expect = _hashOf(
        e.prevHash,
        e.time.toIso8601String(),
        e.category,
        e.action,
        e.detail,
      );
      if (e.hash != expect) return false;
      prev = e.hash;
    }
    return true;
  }

  String _hashOf(
    String prev,
    String time,
    String category,
    String action,
    String detail,
  ) {
    return sha256.convert(utf8.encode(prev + time + category + action + detail))
        .toString();
  }

  Future<List<AuditEntry>> _load() async {
    final data = await Storage.readJson(AppConstants.auditLogFileName);
    if (data == null) return [];
    final arr = data['entries'] as List<dynamic>? ?? const [];
    return arr
        .whereType<Map<String, dynamic>>()
        .map(AuditEntry.fromJson)
        .toList();
  }

  Future<void> _save(List<AuditEntry> list) async {
    await Storage.writeJson(AppConstants.auditLogFileName, {
      'entries': list.map((e) => e.toJson()).toList(),
    });
  }
}
