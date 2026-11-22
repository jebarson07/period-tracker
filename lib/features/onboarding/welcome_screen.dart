import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Luna welcome screen (onboarding screen 1).
///
/// Order: logo -> lotus -> main message -> supporting message -> button.
/// Everything is drawn in code, so no image assets are required.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.onBegin});

  /// Called when the user taps "Let's Begin".
  final VoidCallback? onBegin;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;

  static const _petals = <_PetalSpec>[
    _PetalSpec(0.84, -0.86, 22, 0.7, 0.0),
    _PetalSpec(-0.92, -0.55, 24, -0.9, 1.2),
    _PetalSpec(0.95, -0.22, 26, 0.5, 2.1),
    _PetalSpec(-0.90, 0.05, 30, 2.4, 0.8),
    _PetalSpec(0.90, 0.30, 20, 0.3, 1.7),
    _PetalSpec(-0.96, 0.70, 34, 0.9, 1.5),
  ];

  @override
  void initState() {
    super.initState();
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    // Slow, calm loop (10 seconds per cycle)
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
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
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    final width = MediaQuery.of(context).size.width;
    final buttonWidth = math.max(240.0, width * 0.68);

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDEFF3),
              AppColors.background,
              Color(0xFFF1E4F6),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Soft glow near the top
            Positioned(
              top: -60,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 300,
                  decoration: const BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.9,
                      colors: [Color(0x80FFFFFF), Color(0x00FFFFFF)],
                    ),
                  ),
                ),
              ),
            ),

            // Soft waves + sparkles at the bottom
            const Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _WavesPainter()),
              ),
            ),

            // Gently floating petals
            for (final p in _petals)
              Align(
                alignment: Alignment(p.x, p.y),
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _float,
                    builder: (context, child) {
                      final t = _float.value * 2 * math.pi + p.phase;
                      return Transform.translate(
                        offset: Offset(math.sin(t) * 3, math.sin(t) * 5),
                        child: Transform.rotate(
                          angle: p.rotation + math.sin(t) * 0.06,
                          child: child,
                        ),
                      );
                    },
                    child: CustomPaint(
                      size: Size(p.size, p.size * 1.3),
                      painter: const _SmallPetalPainter(AppColors.period),
                    ),
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

                        // 1. Logo
                        const _Logo(),

                        // 2. Lotus (slow, gentle float)
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: FittedBox(
                              fit: BoxFit.contain,
                              child: SizedBox(
                                width: 340,
                                height: 300,
                                child: AnimatedBuilder(
                                  animation: _float,
                                  builder: (context, _) {
                                    final bob =
                                        math.sin(_float.value * 2 * math.pi) *
                                            3;
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

                        // 3. Main message
                        const Text(
                          'Your body has its\nown rhythm.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontSize: 32,
                            height: 1.2,
                            fontWeight: FontWeight.w500,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 4. Supporting message
                        const Text(
                          "We're here to help you understand it.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.5,
                            height: 1.5,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // 5. Let's Begin
                        _BeginButton(
                          width: buttonWidth,
                          onTap: widget.onBegin,
                        ),
                        const SizedBox(height: 32),
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
// Button
// ---------------------------------------------------------------------------

class _BeginButton extends StatelessWidget {
  const _BeginButton({required this.width, required this.onTap});

  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 58,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(29),
        boxShadow: const [
          BoxShadow(
            color: Color(0x5598577F),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: onTap,
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Let's Begin",
                  style: TextStyle(
                    fontSize: 17.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 21, color: AppColors.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Logo (sparkle + leaves + wordmark + tagline)
// ---------------------------------------------------------------------------

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          height: 72,
          child: CustomPaint(painter: _LogoMarkPainter()),
        ),
        SizedBox(height: 2),
        Text(
          'luna',
          style: TextStyle(
            fontSize: 62,
            height: 1.0,
            fontWeight: FontWeight.w400,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'PERIOD TRACKER',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF9B7FC2),
            letterSpacing: 4.2,
          ),
        ),
      ],
    );
  }
}

class _LogoMarkPainter extends CustomPainter {
  const _LogoMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Four-point sparkle above the leaves
    _drawSparkle(
      canvas,
      Offset(w * 0.5, h * 0.10),
      9,
      AppColors.period,
    );

    // Left leaf (pink -> lavender)
    _drawLeaf(
      canvas,
      base: Offset(w * 0.52, h * 0.98),
      angle: _rad(-38),
      leafW: w * 0.20,
      leafH: h * 0.80,
      bottom: AppColors.period,
      top: const Color(0xFFB890E2),
    );

    // Right leaf (lavender -> purple)
    _drawLeaf(
      canvas,
      base: Offset(w * 0.52, h * 0.98),
      angle: _rad(38),
      leafW: w * 0.20,
      leafH: h * 0.80,
      bottom: const Color(0xFFC9A6E8),
      top: const Color(0xFF8F68D2),
    );

    // Thin curl joining the leaves down to the wordmark
    final curl = Path()
      ..moveTo(w * 0.52, h * 0.98)
      ..cubicTo(w * 0.52, h * 0.70, w * 0.50, h * 0.55, w * 0.55, h * 0.40);
    canvas.drawPath(
      curl,
      Paint()
        ..color = const Color(0xFFB79AD6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawLeaf(
      Canvas canvas, {
        required Offset base,
        required double angle,
        required double leafW,
        required double leafH,
        required Color bottom,
        required Color top,
      }) {
    canvas.save();
    canvas.translate(base.dx, base.dy);
    canvas.rotate(angle);
    final path = Path()
      ..moveTo(0, 0)
      ..cubicTo(leafW * 1.5, -leafH * 0.25, leafW * 1.0, -leafH * 0.85, 0,
          -leafH)
      ..cubicTo(-leafW * 1.0, -leafH * 0.85, -leafW * 1.5, -leafH * 0.25, 0,
          0)
      ..close();
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [bottom, top],
        ).createShader(Rect.fromLTWH(-leafW * 2, -leafH, leafW * 4, leafH)),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

void _drawSparkle(Canvas canvas, Offset c, double r, Color color) {
  final k = r * 0.16;
  final path = Path()
    ..moveTo(c.dx, c.dy - r)
    ..quadraticBezierTo(c.dx + k, c.dy - k, c.dx + r, c.dy)
    ..quadraticBezierTo(c.dx + k, c.dy + k, c.dx, c.dy + r)
    ..quadraticBezierTo(c.dx - k, c.dy + k, c.dx - r, c.dy)
    ..quadraticBezierTo(c.dx - k, c.dy - k, c.dx, c.dy - r)
    ..close();
  canvas.drawPath(path, Paint()..color = color);
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
// Background waves + sparkles
// ---------------------------------------------------------------------------

class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Lavender wave (secondary colour)
    final wave1 = Path()
      ..moveTo(0, h * 0.78)
      ..cubicTo(w * 0.25, h * 0.70, w * 0.55, h * 0.86, w, h * 0.74)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave1,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x55E9DDF9), Color(0x33E9DDF9)],
        ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.35)),
    );

    // Warm accent wave
    final wave2 = Path()
      ..moveTo(0, h * 0.88)
      ..cubicTo(w * 0.30, h * 0.82, w * 0.65, h * 0.95, w, h * 0.84)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave2,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x66FBD8C6), Color(0x33F4A6C6)],
        ).createShader(Rect.fromLTWH(0, h * 0.80, w, h * 0.20)),
    );

    // Tiny sparkles
    final dot = Paint()..color = const Color(0x66FFFFFF);
    const dots = <List<double>>[
      [0.12, 0.30, 2.5],
      [0.86, 0.22, 2.0],
      [0.20, 0.62, 3.0],
      [0.78, 0.52, 2.5],
      [0.62, 0.20, 1.8],
      [0.90, 0.78, 3.0],
      [0.08, 0.86, 2.5],
    ];
    for (final d in dots) {
      canvas.drawCircle(Offset(w * d[0], h * d[1]), d[2], dot);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Soft watercolor lotus
// ---------------------------------------------------------------------------

class _LotusPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    final base = Offset(s * 0.5, s * 0.78);

    // Warm glow behind the flower
    final glowCenter = Offset(s * 0.5, s * 0.50);
    canvas.drawCircle(
      glowCenter,
      s * 0.50,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x88FFF1D8), Color(0x00FFF1D8)],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: s * 0.50)),
    );

    // Thin stem
    final stem = Path()
      ..moveTo(base.dx, base.dy)
      ..quadraticBezierTo(
        base.dx - s * 0.03,
        base.dy + s * 0.10,
        base.dx - s * 0.08,
        base.dy + s * 0.17,
      );
    canvas.drawPath(
      stem,
      Paint()
        ..color = const Color(0x66B79AD6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Wide outer petals (lavender)
    for (final a in [-82.0, 82.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.30,
        h: s * 0.60,
        bottom: const Color(0xCCE4C8F2),
        top: const Color(0xCCA98BE2),
      );
    }

    // Pink-lavender petals
    for (final a in [-56.0, 56.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.27,
        h: s * 0.62,
        bottom: const Color(0xCCFBD3E3),
        top: const Color(0xCCE3A8D6),
      );
    }

    // Pink petals
    for (final a in [-30.0, 30.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.26,
        h: s * 0.62,
        bottom: const Color(0xCCFFE3E9),
        top: const Color(0xCCF6A9C9),
      );
    }

    // Back-centre petal
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: s * 0.25,
      h: s * 0.64,
      bottom: const Color(0xCCFFF0EA),
      top: const Color(0xCCF8BED4),
    );

    // Glowing stamens
    final glow = Paint()
      ..color = const Color(0x88FFD58A)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(s * 0.5, s * 0.44), s * 0.07, glow);
    final stamen = Paint()..color = const Color(0xFFF2B35E);
    final tip = Paint()..color = const Color(0xFFFFE0A0);
    for (var i = -4; i <= 4; i++) {
      final x = s * 0.5 + i * s * 0.019;
      final y = s * 0.45 + i.abs() * s * 0.011;
      canvas.drawCircle(Offset(x, y), s * 0.010, stamen);
      canvas.drawCircle(Offset(x, y - s * 0.011), s * 0.006, tip);
    }

    // Front cream petals
    final front = Offset(s * 0.5, s * 0.80);
    for (final a in [-22.0, 22.0]) {
      _drawPetal(
        canvas,
        base: front,
        angle: _rad(a),
        w: s * 0.27,
        h: s * 0.46,
        bottom: const Color(0xE6FFF6EF),
        top: const Color(0xE6FBD6E2),
      );
    }
    _drawPetal(
      canvas,
      base: Offset(s * 0.5, s * 0.82),
      angle: 0,
      w: s * 0.26,
      h: s * 0.40,
      bottom: const Color(0xF2FFF7F1),
      top: const Color(0xF2FDE4E8),
    );

    // Low side petals pointing outward
    for (final a in [-104.0, 104.0]) {
      _drawPetal(
        canvas,
        base: front,
        angle: _rad(a),
        w: s * 0.15,
        h: s * 0.42,
        bottom: const Color(0xCCF9D2E2),
        top: const Color(0xCCD2A6E6),
      );
    }
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
      this.phase,
      );

  final double x;
  final double y;
  final double size;
  final double rotation;
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
        colors: [color.withAlpha(130), color.withAlpha(220)],
      ).createShader(
        Rect.fromLTWH(-size.width, -size.height, size.width * 2, size.height),
      );
    canvas.drawPath(_petalPath(size.width * 0.9, size.height), paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmallPetalPainter oldDelegate) =>
      oldDelegate.color != color;
}