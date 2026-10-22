import 'package:flutter/material.dart';
import '../models/proxy.dart';
import '../models/proxy_group.dart';
import '../models/node_health.dart';
import 'proxy_card.dart';

/// 代理组折叠面板：头部显示组信息与当前节点，展开显示组内节点列表。
class ProxyGroupTile extends StatefulWidget {
  final ProxyGroup group;
  final List<Proxy> nodes;
  final Map<String, NodeHealth> health;
  final ValueChanged<String> onSelect;

  const ProxyGroupTile({
    super.key,
    required this.group,
    required this.nodes,
    required this.health,
    required this.onSelect,
  });

  @override
  State<ProxyGroupTile> createState() => _ProxyGroupTileState();
}

class _ProxyGroupTileState extends State<ProxyGroupTile> {
  bool _expanded = false;

  IconData get _icon {
    final g = widget.group;
    if (g.isUrlTest) return Icons.speed;
    if (g.isFallback) return Icons.swap_horiz;
    if (g.isLoadBalance) return Icons.balance;
    return Icons.tune;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final g = widget.group;
    final now = g.now;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          ListTile(
            onTap: () => setState(() => _expanded = !_expanded),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withAlpha(110),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_icon, size: 20, color: scheme.primary),
            ),
            title: Text(
              g.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text('${g.typeLabel} · ${widget.nodes.length} 个节点'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (now != null && now.isNotEmpty)
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        now,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Column(
                      children: [
                        for (final p in widget.nodes)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: ProxyCard(
                              proxy: p,
                              latencyMs: widget.health[p.name]?.latencyMs ?? -1,
                              score: widget.health[p.name]?.score,
                              grade: widget.health[p.name]?.grade,
                              selected: now == p.name,
                              onTap: () => widget.onSelect(p.name),
                            ),
                          ),
                      ],
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
