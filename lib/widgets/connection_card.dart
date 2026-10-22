import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 主连接卡片：大号电源开关，展示连接状态与端口信息。
class ConnectionCard extends StatelessWidget {
  final bool connected;
  final String subtitle;
  final bool busy;
  final VoidCallback onToggle;

  const ConnectionCard({
    super.key,
    required this.connected,
    required this.subtitle,
    this.busy = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = connected ? Colors.white : scheme.onSurface;
    final subColor = connected
        ? Colors.white.withAlpha(210)
        : scheme.onSurfaceVariant;
    final decoration = BoxDecoration(
      gradient: connected
          ? const LinearGradient(
              colors: [AppTheme.seedColor, Color(0xFF7C6CF0)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : LinearGradient(
              colors: [
                scheme.primaryContainer,
                scheme.primaryContainer.withAlpha(140),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(24),
    );
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: decoration,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      connected ? Icons.check_circle : Icons.circle_outlined,
                      size: 16,
                      color: fg,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      connected ? '已连接' : '未连接',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: fg,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: subColor),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: busy ? null : onToggle,
            customBorder: const CircleBorder(),
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: connected
                    ? Colors.white.withAlpha(46)
                    : scheme.onSurface.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: busy
                  ? Padding(
                      padding: const EdgeInsets.all(18),
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: fg,
                      ),
                    )
                  : Icon(
                      Icons.power_settings_new,
                      color: fg,
                      size: 30,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
