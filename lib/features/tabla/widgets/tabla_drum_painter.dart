import 'dart:math';
import 'package:flutter/material.dart';

class BayanDrumPainter extends CustomPainter {
  final bool isHit;
  final double rippleRadius;

  BayanDrumPainter({required this.isHit, required this.rippleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 1. Draw Woven Base Cushion (Bira)
    final biraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.16
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFE53170),
          Color(0xFFFF8906),
          Color(0xFF7F5AF0),
          Color(0xFF00E5FF),
          Color(0xFFE53170),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.92, biraPaint);

    // 2. Draw Metallic Copper/Chrome Bowl Shell
    final shellGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3), // Specular light offset
      radius: 0.9,
      colors: const [
        Color(0xFF6B5848),
        Color(0xFF3D2F24),
        Color(0xFF1E1712),
        Color(0xFF0F0C09),
      ],
      stops: const [0.0, 0.4, 0.8, 1.0],
    );
    final shellPaint = Paint()..shader = shellGradient.createShader(Rect.fromCircle(center: center, radius: radius * 0.84));
    canvas.drawCircle(center, radius * 0.84, shellPaint);

    // 3. Draw Braided Leather Rim (Gaja)
    final gajaPaint = Paint()
      ..color = const Color(0xFF2A211A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.07;
    canvas.drawCircle(center, radius * 0.82, gajaPaint);

    // 4. Draw Cream Leather Ring (Maidan)
    final maidanGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 0.8,
      colors: const [
        Color(0xFFF3E7D3),
        Color(0xFFE2D0B6),
        Color(0xFFC7B195),
      ],
    );
    final maidanPaint = Paint()..shader = maidanGradient.createShader(Rect.fromCircle(center: center, radius: radius * 0.78));
    canvas.drawCircle(center, radius * 0.78, maidanPaint);

    // 5. Draw Black Iron-Dust Siyahi (Slightly off-center for Bayan bass modulation)
    final siyahiCenter = Offset(center.dx - radius * 0.08, center.dy - radius * 0.05);
    final siyahiRadius = radius * 0.44;

    final siyahiGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 0.7,
      colors: const [
        Color(0xFF2C2B30),
        Color(0xFF16151A),
        Color(0xFF0A0A0D),
      ],
    );
    final siyahiPaint = Paint()..shader = siyahiGradient.createShader(Rect.fromCircle(center: siyahiCenter, radius: siyahiRadius));
    canvas.drawCircle(siyahiCenter, siyahiRadius, siyahiPaint);

    // Siyahi concentric texture line
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(siyahiCenter, siyahiRadius * 0.65, ringPaint);

    // 6. Touch Ripple Glow Animation
    if (isHit) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFB8500).withValues(alpha: (1.0 - rippleRadius).clamp(0.0, 0.8))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(center, radius * (0.3 + rippleRadius * 0.5), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BayanDrumPainter oldDelegate) {
    return oldDelegate.isHit != isHit || oldDelegate.rippleRadius != rippleRadius;
  }
}

class DayanDrumPainter extends CustomPainter {
  final bool isHit;
  final double rippleRadius;

  DayanDrumPainter({required this.isHit, required this.rippleRadius});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;

    // 1. Draw Base Cushion (Bira)
    final biraPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.16
      ..shader = const SweepGradient(
        colors: [
          Color(0xFFFFB703),
          Color(0xFFFB8500),
          Color(0xFFE53170),
          Color(0xFF7F5AF0),
          Color(0xFFFFB703),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius * 0.92, biraPaint);

    // 2. Draw Wooden Cylinder Shell (Rosewood / Sheesham)
    final woodGradient = RadialGradient(
      center: const Alignment(-0.3, -0.3),
      radius: 0.9,
      colors: const [
        Color(0xFF8D5B3A),
        Color(0xFF5C3A21),
        Color(0xFF362011),
      ],
    );
    final woodPaint = Paint()..shader = woodGradient.createShader(Rect.fromCircle(center: center, radius: radius * 0.84));
    canvas.drawCircle(center, radius * 0.84, woodPaint);

    // 3. Draw Rim Ring (Chanti)
    final chantiPaint = Paint()
      ..color = const Color(0xFFF7EBE0)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.78, chantiPaint);

    // 4. Draw Puri Leather Ring
    final puriPaint = Paint()
      ..color = const Color(0xFFDEC5A5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.65, puriPaint);

    // 5. Draw Center Black Siyahi
    final siyahiRadius = radius * 0.38;
    final siyahiGradient = RadialGradient(
      center: const Alignment(-0.2, -0.2),
      radius: 0.7,
      colors: const [
        Color(0xFF2C2B30),
        Color(0xFF16151A),
        Color(0xFF070709),
      ],
    );
    final siyahiPaint = Paint()..shader = siyahiGradient.createShader(Rect.fromCircle(center: center, radius: siyahiRadius));
    canvas.drawCircle(center, siyahiRadius, siyahiPaint);

    // Concentric ring detail
    final ringPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, siyahiRadius * 0.6, ringPaint);

    // 6. Touch Ripple Glow Animation
    if (isHit) {
      final glowPaint = Paint()
        ..color = const Color(0xFFFFB703).withValues(alpha: (1.0 - rippleRadius).clamp(0.0, 0.8))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;
      canvas.drawCircle(center, radius * (0.3 + rippleRadius * 0.5), glowPaint);
    }
  }

  @override
  bool shouldRepaint(covariant DayanDrumPainter oldDelegate) {
    return oldDelegate.isHit != isHit || oldDelegate.rippleRadius != rippleRadius;
  }
}
