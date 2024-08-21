import 'package:flutter/material.dart';
import 'dart:math';

class ClockPainter extends CustomPainter {
  final double progress;
  final Color color;

  ClockPainter({required this.progress, this.color = Colors.orange});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCircle = Paint()
      ..color = Colors.grey.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint progressArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw the outer circle
    canvas.drawCircle(center, radius, outerCircle);

    // Draw tick marks around the circle
    final tickPaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 2;
    const tickLength = 10.0;
    for (int i = 0; i < 60; i++) {
      final double angle = (i * 6) * pi / 180; // Convert degrees to radians
      final double startX = center.dx + radius * cos(angle);
      final double startY = center.dy + radius * sin(angle);
      final double endX = center.dx + (radius - tickLength) * cos(angle);
      final double endY = center.dy + (radius - tickLength) * sin(angle);
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), tickPaint);
    }

    // Draw the progress arc
    final double angle = 2 * pi * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2,
        angle, false, progressArc);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
