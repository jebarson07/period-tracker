import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

/// Luna onboarding screen 3: "Welcome, `<name>`!" + last period date.
///
/// Pass the name typed on the previous screen. If it is empty
/// (the user tapped "Skip for now"), the greeting says "friend".
class CycleSetupScreen extends StatefulWidget {
  const CycleSetupScreen({
    super.key,
    this.name = '',
    this.onContinue,
    this.onLater,
  });

  /// Name entered on screen 2.
  final String name;

  /// Called with the chosen date when the user taps Continue.
  final ValueChanged<DateTime>? onContinue;

  /// Called when the user taps "I don't remember / I'll do this later".
  final VoidCallback? onLater;

  @override
  State<CycleSetupScreen> createState() => _CycleSetupScreenState();
}

class _CycleSetupScreenState extends State<CycleSetupScreen>
    with TickerProviderStateMixin {
  late final AnimationController _intro;
  late final AnimationController _float;
  DateTime? _selected;
  bool _showError = false;

  static const _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const _petals = <_PetalSpec>[
    _PetalSpec(-0.80, -0.62, 24, 0.9, 0.0),
    _PetalSpec(0.92, -0.58, 20, -0.6, 1.3),
    _PetalSpec(-0.95, -0.18, 26, 2.3, 2.0),
    _PetalSpec(0.88, 0.05, 22, 0.4, 0.7),
    _PetalSpec(-0.82, 0.30, 30, 0.8, 1.6),
    _PetalSpec(0.92, 0.28, 34, -0.5, 2.5),
    _PetalSpec(-0.88, 0.80, 28, 0.6, 0.4),
    _PetalSpec(0.90, 0.84, 28, -0.9, 1.1),
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
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _intro.dispose();
    _float.dispose();
    super.dispose();
  }

  String _format(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selected ?? today,
      firstDate: DateTime(today.year - 1, today.month, today.day),
      lastDate: today,
      helpText: 'Last period start date',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: AppColors.background,
              onSurface: AppColors.text,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selected = picked;
        _showError = false;
      });
    }
  }

  void _continue() {
    final date = _selected;
    if (date == null) {
      setState(() => _showError = true);
      return;
    }
    widget.onContinue?.call(date);
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _intro, curve: Curves.easeOutCubic));

    final name = widget.name.trim().isEmpty ? 'friend' : widget.name.trim();

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFBEAF2),
              AppColors.background,
              Color(0xFFF9DEEB),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Decorative branches
            const Positioned(
              top: 0,
              right: 0,
              child: _Branch(width: 130, height: 190),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Transform.rotate(
                angle: math.pi,
                child: const _Branch(width: 120, height: 170),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Transform.scale(
                scaleY: -1,
                child: const _Branch(width: 100, height: 150),
              ),
            ),

            // Soft waves at the bottom
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

            SafeArea(
              child: FadeTransition(
                opacity: fade,
                child: SlideTransition(
                  position: slide,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 14),
                        const _Logo(),
                        const SizedBox(height: 26),

                        // Greeting with the name from screen 2
                        _WelcomeHeading(name: name),
                        const SizedBox(height: 6),
                        const Text(
                          "We're happy you're here.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 19,
                            color: AppColors.text,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Lotus on water
                        SizedBox(
                          height: 200,
                          child: FittedBox(
                            fit: BoxFit.contain,
                            child: SizedBox(
                              width: 360,
                              height: 230,
                              child: AnimatedBuilder(
                                animation: _float,
                                builder: (context, _) {
                                  final bob =
                                      math.sin(_float.value * 2 * math.pi) * 3;
                                  return Transform.translate(
                                    offset: Offset(0, bob),
                                    child: CustomPaint(
                                      painter: _LotusScenePainter(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        const Text(
                          'When did your\nlast period start?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            height: 1.2,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'This helps Luna understand your cycle\n'
                              'and estimate your next period.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.5,
                            height: 1.5,
                            color: AppColors.textMuted,
                          ),
                        ),
                        const SizedBox(height: 22),

                        _dateCard(),
                        if (_showError)
                          const Padding(
                            padding: EdgeInsets.only(top: 10),
                            child: Text(
                              "Pick a date, or choose \"I'll do this later\" 🌸",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFFB3426B),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: _continueButton(),
                        ),
                        const SizedBox(height: 14),

                        TextButton(
                          onPressed: widget.onLater,
                          style: TextButton.styleFrom(
                            foregroundColor: AppColors.text,
                            textStyle: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              decoration: TextDecoration.underline,
                              decorationColor:
                              AppColors.primary.withAlpha(120),
                            ),
                          ),
                          child: const Text(
                            "I don't remember / I'll do this later",
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColors.textMuted,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Your answers help us give better suggestions,\n'
                                  'but are not medical advice.',
                              style: TextStyle(
                                fontSize: 12.5,
                                height: 1.45,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),
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

  Widget _dateCard() {
    final selected = _selected;
    return Semantics(
      button: true,
      label: 'Select your last period date',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F98577F),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: const Color(0xF2FFFFFF),
          borderRadius: BorderRadius.circular(28),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: _pickDate,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 22, 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      const _CalendarClockIcon(),
                      Expanded(
                        child: Text(
                          selected == null
                              ? 'Select your last period date'
                              : _format(selected),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: selected == null
                                ? FontWeight.w500
                                : FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 30,
                        color: AppColors.text,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFFEBD3E4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    selected == null
                        ? 'Example: ${_format(DateTime.now())}'
                        : 'Tap to change',
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _continueButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(30),
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
          borderRadius: BorderRadius.circular(30),
          onTap: _continue,
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimary,
                  ),
                ),
                SizedBox(width: 12),
                Icon(Icons.arrow_forward, size: 24, color: AppColors.onPrimary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Welcome heading ("Welcome, Halin! <heart>")
// ---------------------------------------------------------------------------

class _WelcomeHeading extends StatelessWidget {
  const _WelcomeHeading({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Welcome, ',
                  style: TextStyle(fontWeight: FontWeight.w400),
                ),
                TextSpan(
                  text: '$name!',
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            style: const TextStyle(
              fontSize: 33,
              height: 1.1,
              color: AppColors.text,
            ),
          ),
          const SizedBox(width: 6),
          const SizedBox(
            width: 46,
            height: 42,
            child: CustomPaint(painter: _HeartDoodlePainter()),
          ),
        ],
      ),
    );
  }
}

class _HeartDoodlePainter extends CustomPainter {
  const _HeartDoodlePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Outline heart, tilted a little
    canvas.save();
    canvas.translate(size.width * 0.52, size.height * 0.62);
    canvas.rotate(0.14);
    canvas.drawPath(_heartPath(0, 0, 26, 24), stroke);
    canvas.restore();

    // Little sparks
    final spark = Paint()
      ..color = AppColors.text
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.10, size.height * 0.20),
      Offset(size.width * 0.18, size.height * 0.30),
      spark,
    );
    canvas.drawLine(
      Offset(size.width * 0.26, size.height * 0.04),
      Offset(size.width * 0.30, size.height * 0.16),
      spark,
    );
    canvas.drawLine(
      Offset(size.width * 0.96, size.height * 0.24),
      Offset(size.width * 0.84, size.height * 0.30),
      spark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Calendar + clock icon
// ---------------------------------------------------------------------------

class _CalendarClockIcon extends StatelessWidget {
  const _CalendarClockIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 46,
      height: 46,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Icon(
              Icons.calendar_today_outlined,
              size: 38,
              color: AppColors.primary,
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.schedule,
                size: 20,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
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
        SizedBox(height: 2),
        Text(
          'luna',
          style: TextStyle(
            fontSize: 54,
            height: 1.0,
            fontWeight: FontWeight.w300,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'PERIOD TRACKER',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            letterSpacing: 5.5,
          ),
        ),
      ],
    );
  }
}

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
      bottom: const Color(0xFFB27AB4),
      top: const Color(0xFF98577F),
    );
    _drawPetal(
      canvas,
      base: base,
      angle: _rad(48),
      w: w,
      h: h * 0.85,
      bottom: const Color(0xFFB27AB4),
      top: const Color(0xFF98577F),
    );
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: w,
      h: h,
      bottom: const Color(0xFFF4A6C6),
      top: const Color(0xFFC995C3),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
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

Path _heartPath(double cx, double cy, double w, double h) {
  return Path()
    ..moveTo(cx, cy + h / 2)
    ..cubicTo(cx - w * 0.75, cy + h * 0.05, cx - w * 0.55, cy - h * 0.6, cx,
        cy - h * 0.2)
    ..cubicTo(cx + w * 0.55, cy - h * 0.6, cx + w * 0.75, cy + h * 0.05, cx,
        cy + h / 2)
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

double _rad(double deg) => deg * math.pi / 180;

// ---------------------------------------------------------------------------
// Lotus on water, with sparkles and ripples
// ---------------------------------------------------------------------------

class _LotusScenePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.height / 0.98; // lotus scale
    final cx = size.width / 2;

    // Soft pink pool + ripples
    final pool = Offset(cx, s * 0.85);
    canvas.drawOval(
      Rect.fromCenter(center: pool, width: s * 1.5, height: s * 0.18),
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x55F4A6C6), Color(0x00F4A6C6)],
        ).createShader(
          Rect.fromCenter(center: pool, width: s * 1.5, height: s * 0.18),
        ),
    );
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    const rings = <List<double>>[
      [1.50, 0.17, 0x33],
      [1.15, 0.13, 0x44],
      [0.80, 0.09, 0x55],
    ];
    for (final r in rings) {
      ripple.color = Color(0xFFC9A6E8).withAlpha(r[2].toInt());
      canvas.drawOval(
        Rect.fromCenter(center: pool, width: s * r[0], height: s * r[1]),
        ripple,
      );
    }

    // Lotus
    canvas.save();
    canvas.translate(cx - s / 2, 0);

    final base = Offset(s * 0.5, s * 0.78);

    // Warm glow
    final glowCenter = Offset(s * 0.5, s * 0.50);
    canvas.drawCircle(
      glowCenter,
      s * 0.50,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0x88FFF1D8), Color(0x00FFF1D8)],
        ).createShader(Rect.fromCircle(center: glowCenter, radius: s * 0.50)),
    );

    // Wide outer petals (lavender)
    for (final a in [-82.0, 82.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: s * 0.30,
        h: s * 0.60,
        bottom: const Color(0xDDE4C8F2),
        top: const Color(0xDDB48CE4),
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
        bottom: const Color(0xDDFBD3E3),
        top: const Color(0xDDE3A8D6),
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
        bottom: const Color(0xDDFFE3E9),
        top: const Color(0xDDF6A0C4),
      );
    }

    // Back-centre petal
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: s * 0.25,
      h: s * 0.64,
      bottom: const Color(0xDDFFF0EA),
      top: const Color(0xDDF8B4CF),
    );

    // Glowing stamens
    canvas.drawCircle(
      Offset(s * 0.5, s * 0.44),
      s * 0.06,
      Paint()
        ..color = const Color(0x88FFD58A)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    final stamen = Paint()..color = const Color(0xFFF2B35E);
    for (var i = -2; i <= 2; i++) {
      canvas.drawCircle(
        Offset(s * 0.5 + i * s * 0.016, s * 0.45 + i.abs() * s * 0.008),
        s * 0.008,
        stamen,
      );
    }

    // Front cream petals
    final front = Offset(s * 0.5, s * 0.82);
    for (final a in [-22.0, 22.0]) {
      _drawPetal(
        canvas,
        base: front,
        angle: _rad(a),
        w: s * 0.27,
        h: s * 0.46,
        bottom: const Color(0xEEFFF6EF),
        top: const Color(0xEEFBD6E2),
      );
    }
    _drawPetal(
      canvas,
      base: Offset(s * 0.5, s * 0.84),
      angle: 0,
      w: s * 0.26,
      h: s * 0.40,
      bottom: const Color(0xF5FFF7F1),
      top: const Color(0xF5FDE4E8),
    );

    // Low side petals pointing outward
    for (final a in [-104.0, 104.0]) {
      _drawPetal(
        canvas,
        base: front,
        angle: _rad(a),
        w: s * 0.15,
        h: s * 0.42,
        bottom: const Color(0xDDF4D0EA),
        top: const Color(0xDDC9A0E6),
      );
    }
    canvas.restore();

    // Sparkles around the flower
    const sparkleColor = Color(0xCCF08FB5);
    _drawSparkle(canvas, Offset(cx - s * 0.62, s * 0.30), 7, sparkleColor);
    _drawSparkle(canvas, Offset(cx + s * 0.64, s * 0.34), 7, sparkleColor);
    _drawSparkle(canvas, Offset(cx - s * 0.74, s * 0.50), 5, sparkleColor);
    _drawSparkle(canvas, Offset(cx + s * 0.52, s * 0.10), 4, sparkleColor);
    _drawSparkle(canvas, Offset(cx - s * 0.46, s * 0.06), 4, sparkleColor);
    _drawSparkle(canvas, Offset(cx - s * 0.80, s * 0.72), 4, sparkleColor);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Background waves
// ---------------------------------------------------------------------------

class _WavesPainter extends CustomPainter {
  const _WavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final wave1 = Path()
      ..moveTo(0, h * 0.90)
      ..cubicTo(w * 0.25, h * 0.85, w * 0.55, h * 0.95, w, h * 0.87)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave1,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0x44E9DDF9), Color(0x66D9C2F0)],
        ).createShader(Rect.fromLTWH(0, h * 0.85, w, h * 0.15)),
    );

    final wave2 = Path()
      ..moveTo(0, h * 0.95)
      ..cubicTo(w * 0.30, h * 0.91, w * 0.65, h * 0.99, w, h * 0.93)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(
      wave2,
      Paint()..color = const Color(0x44E0C8F2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Floating petals
// ---------------------------------------------------------------------------

class _PetalSpec {
  const _PetalSpec(this.x, this.y, this.size, this.rotation, this.phase);

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
        colors: [color.withAlpha(130), color.withAlpha(225)],
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

/// Thin curved stem with outlined leaves, hanging from the top-right corner.
class _BranchPainter extends CustomPainter {
  const _BranchPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final stroke = Paint()
      ..color = const Color(0xFFC79BD0).withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final stem = Path()
      ..moveTo(w * 1.02, -h * 0.02)
      ..cubicTo(w * 0.75, h * 0.18, w * 0.30, h * 0.40, w * 0.18, h * 0.95);
    canvas.drawPath(stem, stroke);

    final metric = stem.computeMetrics().first;
    const fractions = [0.18, 0.34, 0.50, 0.66, 0.82];
    for (var i = 0; i < fractions.length; i++) {
      final tangent = metric.getTangentForOffset(metric.length * fractions[i]);
      if (tangent == null) continue;
      final side = i.isEven ? 1.0 : -1.0;
      final leafLen = 36.0 - i * 3;

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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}