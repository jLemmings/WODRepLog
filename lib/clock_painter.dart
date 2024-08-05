import 'package:flutter/material.dart';

class ClockPainter extends CustomPainter {
  final double progress;
  final Color color;

  ClockPainter({required this.progress, this.color = Colors.blue});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint outerCircle = Paint()
      ..color = Colors.grey
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final Paint completeArc = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawCircle(center, radius, outerCircle);

    final double angle = 2 * 3.141592653589793 * progress;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius),
        -3.141592653589793 / 2, angle, false, completeArc);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
