import 'dart:math';

import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter({required this.progress});

  final double progress; // 0..1

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 14.0;
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = (size.shortestSide - strokeWidth) / 2;

    // Track
    final trackPaint =
        Paint()
          ..color = AppColors.amber200.withValues(alpha: 0.35)
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, trackPaint);

    // Progress
    final progressPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round
          ..shader = const SweepGradient(
            colors: [
              AppColors.amber400,
              AppColors.amber500,
              AppColors.amber600,
            ],
            stops: [0.0, 0.6, 1.0],
            transform: GradientRotation(-pi / 2),
          ).createShader(rect);

    const startAngle = -pi / 2;
    final sweepAngle = 2 * pi * progress;
    final arcRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, progressPaint);
  }

  @override
  bool shouldRepaint(covariant CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
