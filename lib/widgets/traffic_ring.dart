import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/traffic.dart';
import '../theme/app_theme.dart';

/// 实时流量环形图：外环下行、内环上行，中心显示总速率。
class TrafficRing extends StatelessWidget {
  final int upRate;
  final int downRate;
  final double size;

  const TrafficRing({
    super.key,
    required this.upRate,
    required this.downRate,
    this.size = 180,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TrafficRingPainter(
          upRate: upRate,
          downRate: downRate,
          trackColor: scheme.onSurface.withAlpha(22),
          upColor: AppTheme.seedColor,
          downColor: AppTheme.accentTeal,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                TrafficSnapshot.formatSpeed(upRate + downRate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '上行 ${TrafficSnapshot.formatSpeed(upRate)}   下行 ${TrafficSnapshot.formatSpeed(downRate)}',
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TrafficRingPainter extends CustomPainter {
  final int upRate;
  final int downRate;
  final Color trackColor;
  final Color upColor;
  final Color downColor;

  _TrafficRingPainter({
    required this.upRate,
    required this.downRate,
    required this.trackColor,
    required this.upColor,
    required this.downColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final total = upRate + downRate;

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    final outerRadius = size.width / 2 - 10;
    canvas.drawCircle(center, outerRadius, trackPaint);

    if (total > 0) {
      final downSweep = downRate / total * 2 * math.pi;
      final downPaint = Paint()
        ..color = downColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: outerRadius),
        -math.pi / 2,
        downSweep,
        false,
        downPaint,
      );

      final innerRadius = outerRadius - 20;
      final innerTrack = Paint()
        ..color = trackColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawCircle(center, innerRadius, innerTrack);

      final upSweep = upRate / total * 2 * math.pi;
      final upPaint = Paint()
        ..color = upColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: innerRadius),
        -math.pi / 2,
        upSweep,
        false,
        upPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TrafficRingPainter oldDelegate) =>
      oldDelegate.upRate != upRate ||
      oldDelegate.downRate != downRate ||
      oldDelegate.trackColor != trackColor ||
      oldDelegate.upColor != upColor ||
      oldDelegate.downColor != downColor;
}
