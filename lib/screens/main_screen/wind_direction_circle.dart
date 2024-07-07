import 'package:flutter/material.dart';
import 'package:sky_snap/api/models/weather.dart';
import 'dart:math' as math;

import 'package:sky_snap/utils/colors.dart';

class WindDirectionCircle extends StatelessWidget {
  final String direction;
  final Weather weather;

  const WindDirectionCircle(
      {super.key, required this.direction, required this.weather});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WindDirectionPainter(direction, weather),
    );
  }
}

class WindDirectionPainter extends CustomPainter {
  final String direction;
  final Weather weather;

  WindDirectionPainter(this.direction, this.weather);

  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 150 / 5;
    const Offset center = Offset(150 / 5, 150 / 5);

    Paint circlePaint = Paint()
      ..color = textColor!
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, circlePaint);

    TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    const double textPadding = 20;

    textPainter.text =
        const TextSpan(text: 'N', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset northOffset = Offset(
        center.dx - textPainter.width / 2, center.dy - radius - textPadding);
    textPainter.paint(canvas, northOffset);

    textPainter.text =
        const TextSpan(text: 'S', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset southOffset = Offset(center.dx - textPainter.width / 2,
        center.dy + radius + textPadding - textPainter.height);
    textPainter.paint(canvas, southOffset);

    textPainter.text =
        const TextSpan(text: 'W', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset westOffset = Offset(center.dx - radius - 5 - textPainter.width,
        center.dy - textPainter.height / 2);
    textPainter.paint(canvas, westOffset);

    textPainter.text =
        const TextSpan(text: 'E', style: TextStyle(fontSize: 16));
    textPainter.layout();
    Offset eastOffset =
        Offset(center.dx + radius + 5, center.dy - textPainter.height / 2);
    textPainter.paint(canvas, eastOffset);

    double angle = weather.windDeg.toDouble();
    double arrowLength = radius - textPadding;

    Offset arrowStart = Offset(
      center.dx + arrowLength * math.cos(angle),
      center.dy + arrowLength * math.sin(angle),
    );

    Paint arrowPaint = Paint()..color = Colors.amber;
    canvas.drawLine(center, arrowStart, arrowPaint);

    Path path = Path();
    path.moveTo(arrowStart.dx, arrowStart.dy);
    path.lineTo(
      arrowStart.dx + 10 * math.cos(angle - math.pi / 6),
      arrowStart.dy + 10 * math.sin(angle - math.pi / 6),
    );
    path.lineTo(
      arrowStart.dx + 10 * math.cos(angle + math.pi / 6),
      arrowStart.dy + 10 * math.sin(angle + math.pi / 6),
    );
    path.close();
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
