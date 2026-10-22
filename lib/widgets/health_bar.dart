import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// 健康度条：0..100 评分 + 等级文字，绿色到琥珀再到红色渐变。
class HealthBar extends StatelessWidget {
  final double score;
  final String grade;

  const HealthBar({super.key, required this.score, required this.grade});

  Color _color() {
    if (score >= 85) return AppTheme.okGreen;
    if (score >= 70) return AppTheme.accentTeal;
    if (score >= 50) return AppTheme.warnAmber;
    if (score > 0) return AppTheme.dangerRed;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    final v = score.clamp(0.0, 100.0).toDouble();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 56,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: v / 100.0,
              minHeight: 6,
              backgroundColor: c.withAlpha(30),
              valueColor: AlwaysStoppedAnimation<Color>(c),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          grade,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: c,
          ),
        ),
      ],
    );
  }
}
