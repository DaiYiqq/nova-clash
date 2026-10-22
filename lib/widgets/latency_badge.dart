import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 延迟徽标：按延迟大小着色，-1 表示未知/超时。
class LatencyBadge extends StatelessWidget {
  final int latencyMs;

  const LatencyBadge({super.key, required this.latencyMs});

  Color _color() {
    if (latencyMs < 0) return Colors.grey;
    if (latencyMs < 100) return AppTheme.okGreen;
    if (latencyMs < 200) return AppTheme.accentTeal;
    if (latencyMs < 400) return AppTheme.warnAmber;
    return AppTheme.dangerRed;
  }

  String _text() => latencyMs < 0 ? '超时' : '$latencyMs ms';

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: c.withAlpha(28),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.speed, size: 12, color: c),
          const SizedBox(width: 4),
          Text(
            _text(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c,
            ),
          ),
        ],
      ),
    );
  }
}
