import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nilah welcome screen (onboarding screen 1).
///
/// Everything is drawn in code (gradient, lotus, petals, branches),
/// so no image assets are required.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.onBegin});

  /// Called when the user taps "Let's begin".
  final VoidCallback? onBegin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;

  static const _plum = Color(0xFF8B5278);
  static const _headline = Color(0xFF7A4A6E);
  static const _subtitle = Color(0xFF8C6483);

  static const _petals = <_PetalSpec>[
    _PetalSpec(-0.80, -0.72, 18, 0.5, Color(0xFFF4A6C6), 0.0),
    _PetalSpec(0.58, -0.42, 22, -0.6, Color(0xFFF08FB5), 1.1),
    _PetalSpec(-0.92, -0.28, 22, 2.5, Color(0xFFC9A6E8), 2.0),
    _PetalSpec(-0.74, 0.02, 20, 0.8, Color(0xFFF4A6C6), 0.6),
    _PetalSpec(0.90, 0.22, 18, 0.4, Color(0xFFF4A6C6), 1.7),
    _PetalSpec(-0.55, 0.45, 16, 1.2, Color(0xFFF4A6C6), 2.6),
    _PetalSpec(0.50, 0.52, 20, 2.2, Color(0xFFC9A6E8), 0.3),
    _PetalSpec(-1.02, 0.58, 40, -0.3, Color(0xFFF4A6C6), 1.4),
    _PetalSpec(0.98, 0.80, 44, 0.9, Color(0xFFF4A6C6), 2.2),
  ];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFDE8EC), // soft peach-pink
              Color(0xFFF1E3F7), // lavender mist
              Color(0xFFE9DDF9), // lavender
              Color(0xFFFCEBE0), // peach
            ],
            stops: [0.0, 0.38, 0.62, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Corner branches
            const Positioned(
              top: 0,
              right: 0,
              child: _Branch(width: 150, height: 230),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi,
                child: const _Branch(width: 140, height: 190),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.scale(
                scaleY: -1,
                child: const _Branch(width: 120, height: 150),
              ),
            ),

            // Floating petals
            for (final p in _petals)
              Align(
                alignment: Alignment(p.x, p.y),
                child: AnimatedBuilder(
                  animation: _float,
                  builder: (context, child) {
                    final t = _float.value * 2 * math.pi + p.phase;
                    return Transform.translate(
                      offset: Offset(math.sin(t) * 5, math.sin(t * 1.3) * 9),
                      child: Transform.rotate(
                        angle: p.rotation + math.sin(t) * 0.12,
                        child: child,
                      ),
                    );
                  },
                  child: CustomPaint(
                    size: Size(p.size, p.size * 1.3),
                    painter: _SmallPetalPainter(p.color),
                  ),
                ),
              ),

            // Main content
            SafeArea(
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const SizedBox(height: 28),
                        const _Logo(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: AnimatedBuilder(
                                  animation: _float,
                                  builder: (context, _) {
                                    final bob =
                                        math.sin(_float.value * 2 * math.pi) *
                                            4;
                                    return Transform.translate(
                                      offset: Offset(0, bob),
                                      child: CustomPaint(
                                        painter: _LotusPainter(),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        const Text(
                          'Your body has its\nown rhythm.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 36,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: _headline,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          "We're here to help you understand it,\n"
                              'one gentle step at a time.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color: _subtitle,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          height: 62,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(31),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x558B5278),
                                  blurRadius: 22,
                                  offset: Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ElevatedButton(
                              onPressed: widget.onBegin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _plum,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: const StadiumBorder(),
                                textStyle: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Let's begin"),
                                  SizedBox(width: 10),
                                  Icon(Icons.arrow_forward, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          'A little space just for you 🌷',
                          style: TextStyle(fontSize: 14, color: _subtitle),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo
// ---------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 44,
          height: 34,
          child: CustomPaint(painter: _MiniLotusPainter()),
        ),
        SizedBox(height: 4),
        Text(
          'nilah',
          style: TextStyle(
            fontFamily: 'serif',
            fontSize: 54,
            height: 1.0,
            fontWeight: FontWeight.w500,
            color: Color(0xFF7A4A6E),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Painting helpers
// ---------------------------------------------------------------------------

/// A petal shape with its base at (0, 0) and its tip at (0, -h).
Path _petalPath(double w, double h) {
  return Path()
    ..moveTo(0, 0)
    ..cubicTo(w * 0.95, -h * 0.25, w * 0.55, -h * 0.85, 0, -h)
    ..cubicTo(-w * 0.55, -h * 0.85, -w * 0.95, -h * 0.25, 0, 0)
    ..close();
}

void _drawPetal(
    Canvas canvas, {
      required Offset base,
      required double angle,
      required double w,
      required double h,
      required Color bottom,
      required Color top,
    }) {
  canvas.save();
  canvas.translate(base.dx, base.dy);
  canvas.rotate(angle);
  final paint = Paint()
    ..shader = LinearGradient(
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
      colors: [bottom, top],
    ).createShader(Rect.fromLTWH(-w, -h, w * 2, h));
  canvas.drawPath(_petalPath(w, h), paint);
  canvas.restore();
}

double _rad(double deg) => deg * math.pi / 180;

// ---------------------------------------------------------------------------
// Big lotus
// ---------------------------------------------------------------------------

class _LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final base = Offset(s * 0.5, s * 0.80);

    // Soft glow behind the flower
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.52),
      s * 0.48,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x66FFF3D6), Color(0x00FFF3D6)],
        ).createShader(
          Rect.fromCircle(center: Offset(s * 0.5, s * 0.52), radius: s * 0.48),
        ),
    );

    // Ground shadow
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(s * 0.5, s * 0.84),
        width: s * 0.5,
        height: s * 0.07,
      ),
      Paint()
        ..color = const Color(0x33E9A36E)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );

    // Outer petals (lavender)
    for (final a in [-80.0, 80.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.26,
        h: s * 0.58,
        bottom: const Color(0xFFE6B8DC),
        top: const Color(0xFFB993E6),
      );
    }

    // Middle-outer petals (pink-lavender)
    for (final a in [-55.0, 55.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.26,
        h: s * 0.60,
        bottom: const Color(0xFFF8C9DA),
        top: const Color(0xFFD9A0D6),
      );
    }

    // Middle petals (pink)
    for (final a in [-30.0, 30.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.25,
        h: s * 0.60,
        bottom: const Color(0xFFFDE0E0),
        top: const Color(0xFFF2A6C4),
      );
    }

    // Back-centre petal
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: s * 0.24,
      h: s * 0.62,
      bottom: const Color(0xFFFFEFE6),
      top: const Color(0xFFF6B7CC),
    );

    // Stamens
    final stamenPaint = Paint()..color = const Color(0xFFF2B35E);
    final stamenTip = Paint()..color = const Color(0xFFFFD58A);
    for (var i = -4; i <= 4; i++) {
      final x = s * 0.5 + i * s * 0.018;
      final y = s * 0.43 + i.abs() * s * 0.012;
      canvas.drawCircle(Offset(x, y), s * 0.011, stamenPaint);
      canvas.drawCircle(Offset(x, y - s * 0.012), s * 0.007, stamenTip);
    }

    // Front petals (cream)
    for (final a in [-20.0, 20.0]) {
      _drawPetal(
        canvas,
        base: Offset(s * 0.5, s * 0.82),
        angle: _rad(a),
        w: s * 0.27,
        h: s * 0.46,
        bottom: const Color(0xFFFFF4EC),
        top: const Color(0xFFFBD3DF),
      );
    }
    _drawPetal(
      canvas,
      base: Offset(s * 0.5, s * 0.84),
      angle: 0,
      w: s * 0.26,
      h: s * 0.40,
      bottom: const Color(0xFFFFF6EF),
      top: const Color(0xFFFDE2E6),
    );

    // Low side petals pointing outward
    for (final a in [-100.0, 100.0]) {
      _drawPetal(
        canvas,
        base: Offset(s * 0.5, s * 0.82),
        angle: _rad(a),
        w: s * 0.15,
        h: s * 0.40,
        bottom: const Color(0xFFF8C9DA),
        top: const Color(0xFFD7A6E4),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Small logo lotus (3 petals)
// ---------------------------------------------------------------------------

class _MiniLotusPainter extends CustomPainter {
  const _MiniLotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height);
    final h = size.height * 0.95;
    final w = size.width * 0.32;

    _drawPetal(
      canvas,
      base: base,
      angle: _rad(-48),
      w: w,
      h: h * 0.85,
      bottom: const Color(0xFFF4A6C6),
      top: const Color(0xFFE79CBD),
    );
    _drawPetal(
      canvas,
      base: base,
      angle: _rad(48),
      w: w,
      h: h * 0.85,
      bottom: const Color(0xFFF4A6C6),
      top: const Color(0xFFE79CBD),
    );
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: w,
      h: h,
      bottom: const Color(0xFFB27AB4),
      top: const Color(0xFFC995C3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Floating petals
// ---------------------------------------------------------------------------

class _PetalSpec {
  const _PetalSpec(
      this.x,
      this.y,
      this.size,
      this.rotation,
      this.color,
      this.phase,
      );

  final double x; // Alignment x (-1..1)
  final double y; // Alignment y (-1..1)
  final double size;
  final double rotation;
  final Color color;
  final double phase;
}

class _SmallPetalPainter extends CustomPainter {
  const _SmallPetalPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.translate(size.width / 2, size.height);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [
          color.withAlpha(150),
          color.withAlpha(235),
        ],
      ).createShader(Rect.fromLTWH(-size.width, -size.height, size.width * 2, size.height));
    canvas.drawPath(_petalPath(size.width * 0.9, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmallPetalPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ---------------------------------------------------------------------------
// Decorative corner branch
// ---------------------------------------------------------------------------

class _Branch extends StatelessWidget {
  const _Branch({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: const _BranchPainter(),
      ),
    );
  }
}

/// Draws a thin curved stem with outlined leaves,
/// hanging from the top-right corner of its box.
class _BranchPainter extends CustomPainter {
  const _BranchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = const Color(0xFFC79BD0).withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.3
      ..strokeCap = StrokeCap.round;

    final stem = Path()
      ..moveTo(w * 1.02, -h * 0.02)
      ..cubicTo(w * 0.75, h * 0.18, w * 0.30, h * 0.40, w * 0.18, h * 0.95);
    canvas.drawPath(stem, stroke);

    final metric = stem.computeMetrics().first;
    const fractions = [0.18, 0.34, 0.50, 0.66, 0.82];
    for (var i = 0; i < fractions.length; i++) {
      final tangent =
      metric.getTangentForOffset(metric.length * fractions[i]);
      if (tangent == null) continue;
      final side = i.isEven ? 1.0 : -1.0;
      final leafLen = 38.0 - i * 3;

      canvas.save();
      canvas.translate(tangent.position.dx, tangent.position.dy);
      canvas.rotate(-tangent.angle + side * 0.9 + math.pi);
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(leafLen * 0.5, -leafLen * 0.32, leafLen, 0)
        ..quadraticBezierTo(leafLen * 0.5, leafLen * 0.32, 0, 0);
      canvas.drawPath(
        leaf,
        Paint()
          ..color = const Color(0xFFE6C6EC).withAlpha(60)
          ..style = PaintingStyle.fill,
      );
      canvas.drawPath(leaf, stroke);
      canvas.restore();
    }

    // Little buds near the top
    final bud = Paint()..color = const Color(0xFFC79BD0).withAlpha(170);
    canvas.drawCircle(Offset(w * 0.12, h * 0.30), 3, bud);
    canvas.drawCircle(Offset(w * 0.06, h * 0.34), 2.2, bud);
    canvas.drawCircle(Offset(w * 0.16, h * 0.36), 2.2, bud);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}