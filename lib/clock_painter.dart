import 'dart:math';

import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  ClockPainter({
    required this.progress,
    this.color = Colors.orange,
    this.trackColor = const Color(0xFF2C2D34),
    this.strokeWidth = 10,
  });

  final double progress;
  final Color color;
  final Color trackColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final Paint outerCircle = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw the outer circle track
    canvas.drawCircle(center, radius, outerCircle);

    // Draw tick marks with stronger emphasis every 5th mark
    for (int i = 0; i < 60; i++) {
      final bool isMajor = i % 5 == 0;
      final tickPaint = Paint()
        ..color = Colors.white.withValues(alpha: isMajor ? 0.28 : 0.12)
        ..strokeWidth = isMajor ? 2.4 : 1.4
        ..strokeCap = StrokeCap.round;

      final double angle = (i * 6) * pi / 180;
      final double tickLength = isMajor ? 16 : 10;
      final double startX = center.dx + radius * cos(angle);
      final double startY = center.dy + radius * sin(angle);
      final double endX = center.dx + (radius - tickLength) * cos(angle);
      final double endY = center.dy + (radius - tickLength) * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Draw the progress arc with a subtle gradient
    final Rect sweepRect = Rect.fromCircle(center: center, radius: radius);
    final double sweepAngle = 2 * pi * progress;

    final Paint progressArc = Paint()
      ..shader = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + sweepAngle,
        colors: [
          color.withValues(alpha: 0.35),
          color,
        ],
      ).createShader(sweepRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(sweepRect, -pi / 2, sweepAngle, false, progressArc);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.trackColor != trackColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
