import 'package:flutter/material.dart';
import '../models/proxy.dart';
import '../theme/app_theme.dart';
import 'latency_badge.dart';
import 'health_bar.dart';

/// 单个节点卡片：协议徽标 + 名称 + 摘要 + 延迟 + 健康度 + 选中态。
class ProxyCard extends StatelessWidget {
  final Proxy proxy;
  final int latencyMs;
  final double? score;
  final String? grade;
  final bool selected;
  final VoidCallback? onTap;

  const ProxyCard({
    super.key,
    required this.proxy,
    this.latencyMs = -1,
    this.score,
    this.grade,
    this.selected = false,
    this.onTap,
  });

  Color _typeColor() {
    switch (proxy.type.toLowerCase()) {
      case 'ss':
        return const Color(0xFF5B8DEF);
      case 'ssr':
        return const Color(0xFF9C6ADE);
      case 'vmess':
        return const Color(0xFFEF6C00);
      case 'vless':
        return const Color(0xFF00A86B);
      case 'trojan':
        return const Color(0xFFE53935);
      case 'hysteria2':
      case 'hy2':
        return AppTheme.accentTeal;
      case 'tuic':
        return const Color(0xFF7E57C2);
      case 'wireguard':
        return const Color(0xFFB71C1C);
      case 'socks5':
      case 'http':
        return const Color(0xFF546E7A);
      case 'direct':
        return AppTheme.okGreen;
      case 'reject':
        return AppTheme.dangerRed;
      default:
        return AppTheme.seedColor;
    }
  }

  String _tag() {
    switch (proxy.type.toLowerCase()) {
      case 'direct':
        return '直连';
      case 'reject':
        return '拒绝';
      case 'group':
        return '分组';
      default:
        return proxy.type.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final typeColor = _typeColor();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primaryContainer.withAlpha(90)
              : scheme.onSurface.withAlpha(8),
          borderRadius: BorderRadius.circular(14),
          border: selected
              ? Border.all(color: scheme.primary, width: 1.2)
              : null,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: typeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _tag(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: typeColor,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    proxy.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    proxy.summary,
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
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                LatencyBadge(latencyMs: latencyMs),
                if (score != null) ...[
                  const SizedBox(height: 4),
                  HealthBar(score: score!, grade: grade ?? ''),
                ],
              ],
            ),
            if (selected) ...[
              const SizedBox(width: 8),
              Icon(Icons.check_circle, size: 18, color: scheme.primary),
            ],
          ],
        ),
      ),
    );
  }
}
