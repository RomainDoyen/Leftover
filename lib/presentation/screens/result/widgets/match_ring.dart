import 'dart:math';
import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';

class MatchRing extends StatelessWidget {
  final double score; // 0.0 → 1.0
  final double size;

  const MatchRing({super.key, required this.score, this.size = 96});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(score: score.clamp(0.0, 1.0)),
        child: Center(
          child: Icon(
            Icons.eco,
            color: AppColors.secondary,
            size: size * 0.35,
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double score;
  const _RingPainter({required this.score});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 8.0;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = AppColors.surfaceContainerHighest
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = AppColors.secondary
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, 2 * pi, false, trackPaint);
    if (score > 0) {
      canvas.drawArc(rect, -pi / 2, 2 * pi * score, false, progressPaint);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.score != score;
}
