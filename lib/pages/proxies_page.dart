import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/core_state.dart';
import '../models/proxy.dart';
import '../models/proxy_group.dart';
import '../services/node_health_service.dart';
import '../widgets/proxy_group_tile.dart';
import '../widgets/section_card.dart';

/// 代理页：列出全部代理组与节点，支持切换与测速。
class ProxiesPage extends StatefulWidget {
  const ProxiesPage({super.key});

  @override
  State<ProxiesPage> createState() => _ProxiesPageState();
}

class _ProxiesPageState extends State<ProxiesPage> {
  bool _testing = false;

  Future<void> _testAll(CoreState core) async {
    setState(() => _testing = true);
    try {
      await NodeHealthService().testAll(core);
    } finally {
      if (mounted) setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final core = context.watch<CoreState>();
    final groups = core.groups.values.toList();

    String? current;
    for (final g in groups) {
      final now = g.now;
      if (now != null && now.isNotEmpty) {
        current = now;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('代理')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          SectionCard(
            title: '当前节点',
            icon: Icons.router,
            trailing: _testing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : TextButton.icon(
                    onPressed: core.proxies.isEmpty ? null : () => _testAll(core),
                    icon: const Icon(Icons.speed, size: 18),
                    label: const Text('全部测速'),
                  ),
            child: Row(
              children: [
                Icon(
                  Icons.check_circle,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    current ?? '尚未选择节点',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (groups.isEmpty)
            _empty(context)
          else
            for (final g in groups) ...[
              ProxyGroupTile(
                group: g,
                nodes: _resolveNodes(core, g),
                health: core.health,
                onSelect: (node) {
                  core.selectNode(g.name, node);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('已切换「${g.name}」到「$node」')),
                  );
                },
              ),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }

  List<Proxy> _resolveNodes(CoreState core, ProxyGroup g) {
    final list = <Proxy>[];
    for (final name in g.proxies) {
      final p = core.proxies[name];
      if (p != null) {
        list.add(p);
      } else if (core.groups.containsKey(name)) {
        list.add(Proxy(name: name, type: 'group'));
      }
    }
    return list;
  }

  Widget _empty(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SectionCard(
      title: '暂无节点',
      icon: Icons.cloud_off,
      child: Text(
        '尚未连接核心，或当前订阅未包含任何节点。请先在主页启动连接，并在订阅页导入订阅。',
        style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
      ),
    );
  }
}
