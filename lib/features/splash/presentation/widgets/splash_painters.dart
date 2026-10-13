import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:resido/app/theme/app_colors.dart';

/// The splash brand mark (gold roof over an emerald arch), drawn from the
/// inline SVG in the Stitch splash design (64×64 view box).
class SplashMarkPainter extends CustomPainter {
  const SplashMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 64, size.height / 64);

    const goldRoof = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFDDB8), Color(0xFFFFB95F), Color(0xFFC97C11)],
      stops: [0, 0.5, 1],
    );
    const emeraldPillar = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFF97F5CC), Color(0xFF7BD8B1)],
    );
    const cream = Color(0xFFFFDDB8);

    final roof = Path()
      ..moveTo(32, 8)
      ..lineTo(54, 23)
      ..lineTo(49, 26)
      ..lineTo(32, 15)
      ..lineTo(15, 26)
      ..lineTo(10, 23)
      ..close();
    canvas.drawShadow(roof.shift(const Offset(0, 1)), Colors.black, 2, false);
    canvas.drawPath(
      roof,
      Paint()
        ..shader = goldRoof.createShader(
          // gradientUnits="userSpaceOnUse" from (12,12) to (52,38).
          Rect.fromPoints(const Offset(12, 12), const Offset(52, 38)),
        ),
    );

    final innerRoof = Path()
      ..moveTo(32, 19)
      ..lineTo(47, 29)
      ..lineTo(43, 31.5)
      ..lineTo(32, 24)
      ..lineTo(21, 31.5)
      ..lineTo(17, 29)
      ..close();
    canvas.drawPath(innerRoof, Paint()..color = cream.withValues(alpha: 0.95));

    final arch = Path()
      ..moveTo(22, 34)
      ..lineTo(22, 52)
      ..lineTo(27, 52)
      ..lineTo(27, 42)
      ..cubicTo(27, 38.5, 29, 36.5, 32, 36.5)
      ..cubicTo(35, 36.5, 37, 38.5, 37, 42)
      ..lineTo(37, 52)
      ..lineTo(42, 52)
      ..lineTo(42, 42)
      ..cubicTo(42, 35, 37.5, 32.5, 32, 32.5)
      ..cubicTo(27, 32.5, 22, 34, 22, 34)
      ..close();
    canvas.drawPath(
      arch,
      Paint()
        ..shader = emeraldPillar.createShader(
          Rect.fromPoints(const Offset(20, 28), const Offset(44, 52)),
        ),
    );

    canvas.drawCircle(const Offset(32, 45), 2.5, Paint()..color = cream);

    final finial = Path()
      ..moveTo(32, 6)
      ..lineTo(33.5, 10)
      ..lineTo(30.5, 10)
      ..close();
    canvas.drawPath(finial, Paint()..color = cream);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// The faint "Nalukettu courtyard" lattice watermark behind the splash
/// brand (400×400 view box: lattice-filled circle plus two rings).
class SplashLatticePainter extends CustomPainter {
  const SplashLatticePainter();

  static const _emerald = AppColors.deepEmerald;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 400, size.height / 400);
    const center = Offset(200, 200);

    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..color = _emerald;
    final fill = Paint()..color = _emerald;

    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: 190)),
    );
    for (var x = 0.0; x < 400; x += 40) {
      for (var y = 0.0; y < 400; y += 40) {
        final diamond = Path()
          ..moveTo(x + 20, y)
          ..lineTo(x + 40, y + 20)
          ..lineTo(x + 20, y + 40)
          ..lineTo(x, y + 20)
          ..close();
        canvas.drawPath(diamond, stroke..strokeWidth = 0.6);
        canvas.drawCircle(Offset(x + 20, y + 20), 2.5, fill);
        stroke.strokeWidth = 0.4;
        _dashedLine(
          canvas,
          Offset(x + 20, y),
          Offset(x + 20, y + 40),
          2,
          2,
          stroke,
        );
        _dashedLine(
          canvas,
          Offset(x, y + 20),
          Offset(x + 40, y + 20),
          2,
          2,
          stroke,
        );
      }
    }
    canvas.restore();

    _dashedCircle(canvas, center, 140, 4, 6, stroke..strokeWidth = 1);
    canvas.drawCircle(
      center,
      90,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = AppColors.warmAmber,
    );
  }

  void _dashedLine(
    Canvas canvas,
    Offset from,
    Offset to,
    double dash,
    double gap,
    Paint paint,
  ) {
    final total = (to - from).distance;
    final dir = (to - from) / total;
    for (var d = 0.0; d < total; d += dash + gap) {
      canvas.drawLine(
        from + dir * d,
        from + dir * math.min(d + dash, total),
        paint,
      );
    }
  }

  void _dashedCircle(
    Canvas canvas,
    Offset center,
    double radius,
    double dash,
    double gap,
    Paint paint,
  ) {
    final rect = Rect.fromCircle(center: center, radius: radius);
    final circumference = 2 * math.pi * radius;
    for (var d = 0.0; d < circumference; d += dash + gap) {
      canvas.drawArc(rect, d / radius, dash / radius, false, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
