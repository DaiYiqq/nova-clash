import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core_state.dart';
import '../core/constants.dart';
import '../models/audit_entry.dart';
import '../services/audit_service.dart';
import '../widgets/section_card.dart';

/// 连接日志页：安全审计日志 + 实时连接信息（创新功能 12）。
class LogsPage extends StatefulWidget {
  const LogsPage({super.key});

  @override
  State<LogsPage> createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  List<AuditEntry> _entries = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await AuditService().entries();
    if (!mounted) return;
    setState(() {
      _entries = list;
      _loading = false;
    });
  }

  String _fmt(DateTime d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  Widget build(BuildContext context) {
    final core = context.watch<CoreState>();
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('连接日志')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionCard(
            title: '安全审计日志',
            icon: Icons.shield_outlined,
            child: _buildAudit(scheme),
          ),
          const SizedBox(height: 12),
          SectionCard(
            title: '实时连接',
            icon: Icons.link_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _kv(scheme, '连接状态', core.connected ? '已连接' : '未连接'),
                _kv(
                  scheme,
                  '核心版本',
                  core.coreVersion.isEmpty ? '未知' : core.coreVersion,
                ),
                _kv(scheme, '代理模式', core.mode.label),
                _kv(scheme, '代理组数量', '${core.groups.length}'),
                _kv(scheme, '节点数量', '${core.proxies.length}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudit(ColorScheme scheme) {
    if (_loading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(),
        ),
      );
    }
    if (_entries.isEmpty) {
      return Text(
        '暂无审计日志。启用「安全审计日志」后，核心启动/停止、节点切换、规则变更等操作将被记录。',
        style: TextStyle(
          color: scheme.onSurfaceVariant,
          fontSize: 12,
          height: 1.5,
        ),
      );
    }
    final reversed = _entries.reversed.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final e in reversed) _entryTile(scheme, e),
      ],
    );
  }

  Widget _entryTile(ColorScheme scheme, AuditEntry e) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '${e.category} · ${e.action}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                _fmt(e.time),
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            e.detail,
            style: TextStyle(
              fontSize: 12,
              color: scheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '哈希 ${e.hash.isEmpty ? '—' : e.hash.substring(0, e.hash.length < 16 ? e.hash.length : 16)}',
            style: TextStyle(fontSize: 10, color: scheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _kv(ColorScheme scheme, String k, String v) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(
              k,
              style: TextStyle(fontSize: 13, color: scheme.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              v,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
