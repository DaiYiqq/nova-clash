import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config_provider.dart';
import '../core/core_state.dart';
import '../models/profile.dart';
import '../services/subscription_service.dart';
import '../models/traffic.dart';
import '../widgets/section_card.dart';

/// 订阅页：列出订阅、支持添加 / 更新 / 删除。
class ProfilesPage extends StatefulWidget {
  const ProfilesPage({super.key});

  @override
  State<ProfilesPage> createState() => _ProfilesPageState();
}

class _ProfilesPageState extends State<ProfilesPage> {
  String _fmt(DateTime? d) {
    if (d == null) return '未知';
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  Future<void> _addProfile(ConfigProvider cfg) async {
    final nameCtrl = TextEditingController();
    final urlCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加订阅'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              autofocus: true,
              decoration: const InputDecoration(labelText: '订阅名称'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(labelText: '订阅链接'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () {
              final n = nameCtrl.text.trim();
              if (n.isEmpty) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('请输入订阅名称')),
                );
                return;
              }
              Navigator.pop(ctx, n);
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
    final url = urlCtrl.text.trim();
    nameCtrl.dispose();
    urlCtrl.dispose();
    if (name == null || !mounted) return;
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final profile = Profile(
      id: id,
      name: name,
      url: url,
      updatedAt: DateTime.now(),
    );
    cfg.addProfile(profile);
    await cfg.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已添加订阅「$name」')),
      );
    }
  }

  Future<void> _updateProfile(Profile p) async {
    final core = context.read<CoreState>();
    final ctl = core.controller;
    if (ctl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先启动连接后再更新订阅。')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('正在更新订阅「${p.name}」...')),
    );
    final ok = await SubscriptionService().updateProfile(p, ctl);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? '订阅「${p.name}」已更新' : '订阅「${p.name}」更新失败'),
        ),
      );
    }
  }

  Future<void> _deleteProfile(ConfigProvider cfg, Profile p) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除订阅'),
        content: Text('确定删除订阅「${p.name}」吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('取消'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (ok != true) return;
    cfg.removeProfile(p.id);
    await cfg.save();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('已删除订阅「${p.name}」')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ConfigProvider>();
    final profiles = cfg.config.profiles;
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '添加订阅',
            onPressed: () => _addProfile(cfg),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          if (profiles.isEmpty)
            SectionCard(
              title: '暂无订阅',
              icon: Icons.rss_feed,
              child: Text(
                '点击右上角「+」添加订阅链接，导入你的节点。',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
            )
          else
            for (final p in profiles) ...[
              _profileCard(cfg, p),
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 4),
          _tipCard(),
        ],
      ),
    );
  }

  Widget _profileCard(ConfigProvider cfg, Profile p) {
    final scheme = Theme.of(context).colorScheme;
    final ratio = p.usedRatio;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.link, color: scheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.url,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) {
                    if (v == 'update') _updateProfile(p);
                    if (v == 'delete') _deleteProfile(cfg, p);
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: 'update',
                      child: Text('更新订阅'),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Text('删除'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _info('更新', _fmt(p.updatedAt)),
                const SizedBox(width: 16),
                _info('到期', _fmt(p.expireAt)),
                const SizedBox(width: 16),
                _info('剩余', p.remainDays == null ? '未知' : '${p.remainDays} 天'),
              ],
            ),
            const SizedBox(height: 14),
            if (ratio != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: ratio,
                  minHeight: 8,
                  backgroundColor: scheme.onSurface.withAlpha(16),
                  valueColor: AlwaysStoppedAnimation<Color>(_ratioColor(ratio)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '已用 ${TrafficSnapshot.formatBytes(p.usedBytes ?? 0)} / ${TrafficSnapshot.formatBytes(p.totalBytes ?? 0)}（${(ratio * 100).toStringAsFixed(0)}%）',
                style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
              ),
            ] else
              Text(
                '流量信息未知',
                style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
              ),
          ],
        ),
      ),
    );
  }

  Color _ratioColor(double r) {
    if (r < 0.6) return Theme.of(context).colorScheme.primary;
    if (r < 0.9) return const Color(0xFFFFB300);
    return const Color(0xFFFF5370);
  }

  Widget _info(String label, String value) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _tipCard() {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: '订阅说明',
      icon: Icons.info_outline,
      child: Text(
        '订阅链接由你的服务商提供。NovaClash 不会内置任何节点或订阅，请自行获取合规的订阅来源。',
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, height: 1.5),
      ),
    );
  }
}
