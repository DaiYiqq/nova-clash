import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/config_provider.dart';
import '../models/rule.dart';
import '../widgets/section_card.dart';

/// 规则页：展示自定义规则，支持新增 / 删除，并说明智能分流与分应用代理。
class RulesPage extends StatelessWidget {
  const RulesPage({super.key});

  Future<void> _addRule(BuildContext context, ConfigProvider cfg) async {
    final payloadCtrl = TextEditingController();
    final proxyCtrl = TextEditingController(text: 'PROXY');
    String type = 'DOMAIN-SUFFIX';
    const types = [
      'DOMAIN-SUFFIX',
      'DOMAIN',
      'DOMAIN-KEYWORD',
      'IP-CIDR',
      'IP-CIDR6',
      'GEOIP',
      'GEOSITE',
      'MATCH',
    ];
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('新增规则'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '规则类型',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in types)
                      ChoiceChip(
                        label: Text(t, style: const TextStyle(fontSize: 12)),
                        selected: type == t,
                        onSelected: (_) => setState(() => type = t),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: payloadCtrl,
                  decoration: const InputDecoration(
                    labelText: '匹配内容',
                    hintText: '例如 google.com',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: proxyCtrl,
                  decoration: const InputDecoration(
                    labelText: '目标策略组',
                    hintText: '例如 PROXY',
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                if (payloadCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('请输入匹配内容')),
                  );
                  return;
                }
                Navigator.pop(ctx, true);
              },
              child: const Text('保存'),
            ),
          ],
        ),
      ),
    );
    final payload = payloadCtrl.text.trim();
    final proxy = proxyCtrl.text.trim();
    payloadCtrl.dispose();
    proxyCtrl.dispose();
    if (ok != true) return;
    final rule = Rule(
      type: type,
      payload: payload,
      proxy: proxy.isEmpty ? 'PROXY' : proxy,
      isCustom: true,
    );
    cfg.addCustomRule(rule);
    await cfg.save();
  }

  @override
  Widget build(BuildContext context) {
    final cfg = context.watch<ConfigProvider>();
    final rules = cfg.config.customRules;
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('规则'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: '新增规则',
            onPressed: () => _addRule(context, cfg),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          _featureCard(
            scheme,
            Icons.auto_awesome,
            '智能分流',
            '智能分流引擎会基于域名、IP 与 GeoIP 自动匹配最优线路，无需手动干预。',
          ),
          const SizedBox(height: 10),
          _featureCard(
            scheme,
            Icons.apps,
            '分应用代理',
            '分应用代理可为不同 App 指定独立的代理策略组，实现精细化控制。',
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: '自定义规则（${rules.length}）',
            icon: Icons.list_alt,
            child: rules.isEmpty
                ? Text(
                    '暂无自定义规则，点击右上角「+」添加。',
                    style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 13),
                  )
                : Column(
                    children: [
                      for (var i = 0; i < rules.length; i++)
                        _ruleTile(cfg, rules[i], i),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _featureCard(
    ColorScheme scheme,
    IconData icon,
    String title,
    String desc,
  ) {
    return SectionCard(
      icon: icon,
      title: title,
      child: Text(
        desc,
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12, height: 1.5),
      ),
    );
  }

  Widget _ruleTile(ConfigProvider cfg, Rule r, int index) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              r.type,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: scheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.payload,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '→ ${r.proxy}',
                  style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            color: scheme.error,
            tooltip: '删除',
            onPressed: () async {
              cfg.removeCustomRule(index);
              await cfg.save();
            },
          ),
        ],
      ),
    );
  }
}
