import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Nilah onboarding screen 2: "What should I call you?"
///
/// The illustration is drawn in code. To use your own artwork instead,
/// add a PNG at [_illustrationAsset] and declare it in pubspec.yaml.
class NameScreen extends StatefulWidget {
  const NameScreen({
    super.key,
    this.onContinue,
    this.onSkip,
    this.onBack,
  });

  /// Called with the trimmed name when the user taps Continue.
  final ValueChanged<String>? onContinue;

  /// Called when the user taps "Skip for now".
  final VoidCallback? onSkip;

  /// Called when the user taps the back arrow. Defaults to Navigator.pop.
  final VoidCallback? onBack;

  @override
  State<NameScreen> createState() => _NameScreenState();
}

const String _illustrationAsset = 'assets/images/name_girl.png';

class _NameScreenState extends State<NameScreen>
    with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  late final AnimationController _float;
  bool _showError = false;

  static const _plum = Color(0xFF7A4A6E);
  static const _subtitle = Color(0xFF8C6483);
  static const _purple = Color(0xFFA06BD6);

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    _float.dispose();
    super.dispose();
  }

  void _continue() {
    final name = _controller.text.trim();
    if (name.isEmpty) {
      setState(() => _showError = true);
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onContinue?.call(name);
  }

  void _back() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else {
      Navigator.maybePop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFDEFF3),
                Color(0xFFFFF3F1),
                Color(0xFFFCEFEA),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Soft lavender glow on the edges
              Positioned(
                left: -80,
                top: 120,
                child: _glow(const Color(0x33C9A6E8), 220),
              ),
              Positioned(
                right: -90,
                bottom: 160,
                child: _glow(const Color(0x33F4A6C6), 240),
              ),

              // Bottom corner flowers
              const Positioned(
                left: 0,
                bottom: 0,
                child: _CornerFlowers(width: 120, height: 130),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Transform.scale(
                  scaleX: -1,
                  child: const _CornerFlowers(width: 90, height: 100),
                ),
              ),

              // Floating petals
              _petal(const Alignment(-0.78, -0.42), 20, 0.6, 0.0),
              _petal(const Alignment(0.95, 0.00), 22, -0.8, 1.4),
              _petal(const Alignment(0.80, 0.82), 20, 0.5, 2.6),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _BackButton(onTap: _back),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        height: 160,
                        child: AnimatedBuilder(
                          animation: _float,
                          builder: (context, child) {
                            final bob =
                                math.sin(_float.value * 2 * math.pi) * 3;
                            return Transform.translate(
                              offset: Offset(0, bob),
                              child: child,
                            );
                          },
                          child: Image.asset(
                            _illustrationAsset,
                            height: 160,
                            errorBuilder: (_, __, ___) => const SizedBox(
                              width: 210,
                              height: 160,
                              child: CustomPaint(painter: _GirlPainter()),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'What should\nI call you?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'serif',
                          fontSize: 35,
                          height: 1.2,
                          fontWeight: FontWeight.w500,
                          color: _plum,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'This is your personal space.\n'
                            'Choose the name you feel\n'
                            'comfortable with.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15.5,
                          height: 1.5,
                          color: _subtitle,
                        ),
                      ),
                      const SizedBox(height: 34),
                      _nameField(),
                      if (_showError)
                        const Padding(
                          padding: EdgeInsets.only(top: 8),
                          child: Text(
                            'Tell me what to call you 🌸',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFFC0508A),
                            ),
                          ),
                        ),
                      const SizedBox(height: 26),
                      _continueButton(),
                      const SizedBox(height: 22),
                      TextButton(
                        onPressed: widget.onSkip,
                        style: TextButton.styleFrom(
                          foregroundColor: _purple,
                          textStyle: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        child: const Text('Skip for now'),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _glow(Color color, double size) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withAlpha(0)],
          ),
        ),
      ),
    );
  }

  Widget _petal(Alignment a, double size, double rotation, double phase) {
    return Align(
      alignment: a,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _float,
          builder: (context, child) {
            final t = _float.value * 2 * math.pi + phase;
            return Transform.translate(
              offset: Offset(math.sin(t) * 4, math.sin(t * 1.3) * 8),
              child: Transform.rotate(
                angle: rotation + math.sin(t) * 0.12,
                child: child,
              ),
            );
          },
          child: CustomPaint(
            size: Size(size, size * 1.3),
            painter: const _SmallPetalPainter(Color(0xFFF4A6C6)),
          ),
        ),
      ),
    );
  }

  Widget _nameField() {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0x99FFFFFF),
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: const Color(0xFFD5BDEB), width: 1.3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14A06BD6),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: _controller,
        focusNode: _focus,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        maxLength: 30,
        onChanged: (_) {
          if (_showError) setState(() => _showError = false);
        },
        onSubmitted: (_) => _continue(),
        cursorColor: _purple,
        style: const TextStyle(fontSize: 16, color: _plum),
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
          hintText: 'Enter your name',
          hintStyle: TextStyle(fontSize: 15.5, color: Color(0xFFA18AA0)),
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 6),
            child: Icon(Icons.person_outline_rounded,
                size: 26, color: Color(0xFF8B5278)),
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 17),
        ),
      ),
    );
  }

  Widget _continueButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xFFA98BEB), Color(0xFFF5A3D1)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x55A98BEB),
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: _continue,
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 21, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Back button
// ---------------------------------------------------------------------------

class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xCCFFFFFF),
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: const Color(0x33A06BD6),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFEBD9F2)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22A06BD6),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Icon(
            Icons.arrow_back,
            size: 20,
            color: Color(0xFF7A4A6E),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painting helpers
// ---------------------------------------------------------------------------

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
        colors: [color.withAlpha(150), color.withAlpha(235)],
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
// Bottom corner flowers
// ---------------------------------------------------------------------------

class _CornerFlowers extends StatelessWidget {
  const _CornerFlowers({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        size: Size(width, height),
        painter: const _CornerFlowersPainter(),
      ),
    );
  }
}

class _CornerFlowersPainter extends CustomPainter {
  const _CornerFlowersPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final leafFill = Paint()..color = const Color(0xFFDCC6F0).withAlpha(120);
    final leafLine = Paint()
      ..color = const Color(0xFFC79BD0).withAlpha(150)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    // Leaves fanning up from the bottom-left corner
    final leaves = <List<double>>[
      [w * 0.12, h, -0.10, h * 0.55],
      [w * 0.30, h, 0.18, h * 0.70],
      [w * 0.50, h, 0.45, h * 0.45],
      [w * 0.04, h, -0.45, h * 0.40],
    ];
    for (final l in leaves) {
      canvas.save();
      canvas.translate(l[0], l[1]);
      canvas.rotate(l[2]);
      final len = l[3];
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.28, -len * 0.5, 0, -len)
        ..quadraticBezierTo(-len * 0.28, -len * 0.5, 0, 0);
      canvas.drawPath(leaf, leafFill);
      canvas.drawPath(leaf, leafLine);
      canvas.restore();
    }

    // Stem with a pink bud
    final stem = Path()
      ..moveTo(w * 0.40, h)
      ..quadraticBezierTo(w * 0.52, h * 0.65, w * 0.62, h * 0.38);
    canvas.drawPath(stem, leafLine);

    final bud = Paint()..color = const Color(0xFFF4A6C6);
    canvas.drawCircle(Offset(w * 0.62, h * 0.34), 7, bud);
    canvas.drawCircle(
      Offset(w * 0.62, h * 0.34),
      3,
      Paint()..color = const Color(0xFFFBD3DF),
    );
    canvas.drawCircle(Offset(w * 0.72, h * 0.50), 4.5, bud);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Girl hugging a heart (fallback illustration)
// ---------------------------------------------------------------------------

class _GirlPainter extends CustomPainter {
  const _GirlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    // Design space is 210 x 160; scale to the actual size.
    canvas.save();
    canvas.scale(size.width / 210, size.height / 160);

    const hair = Color(0xFF6B4044);
    const skin = Color(0xFFFFE1D0);
    const ink = Color(0xFF5A3A40);

    // Floating hearts
    final miniHeart = Paint()..color = const Color(0xFFF58FB0);
    canvas.drawPath(_heartPath(46, 30, 20, 18), miniHeart);
    canvas.drawPath(
      _heartPath(168, 24, 18, 16),
      Paint()..color = const Color(0xFFF7A4C0),
    );
    canvas.drawPath(
      _heartPath(152, 56, 8, 7),
      Paint()..color = const Color(0xFFF9BFD3),
    );
    canvas.drawPath(
      _heartPath(60, 58, 7, 6),
      Paint()..color = const Color(0xFFF9BFD3),
    );

    // Side leaves
    final leafFill = Paint()..color = const Color(0xFFD7C0EE).withAlpha(150);
    final leafLine = Paint()
      ..color = const Color(0xFFB88FD0).withAlpha(170)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final l in <List<double>>[
      [34, 134, -0.35, 44],
      [46, 138, 0.05, 36],
      [176, 134, 0.35, 44],
      [164, 138, -0.05, 36],
    ]) {
      canvas.save();
      canvas.translate(l[0], l[1]);
      canvas.rotate(l[2]);
      final len = l[3];
      final leaf = Path()
        ..moveTo(0, 0)
        ..quadraticBezierTo(len * 0.3, -len * 0.5, 0, -len)
        ..quadraticBezierTo(-len * 0.3, -len * 0.5, 0, 0);
      canvas.drawPath(leaf, leafFill);
      canvas.drawPath(leaf, leafLine);
      canvas.restore();
    }

    // Hair (back)
    final hairPaint = Paint()..color = hair;
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(60, 26, 150, 122),
        topLeft: const Radius.circular(46),
        topRight: const Radius.circular(46),
        bottomLeft: const Radius.circular(18),
        bottomRight: const Radius.circular(18),
      ),
      hairPaint,
    );

    // Shirt / shoulders
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(66, 110, 144, 160),
        topLeft: const Radius.circular(26),
        topRight: const Radius.circular(26),
      ),
      Paint()..color = const Color(0xFFFFEBDD),
    );

    // Face
    canvas.drawOval(
      const Rect.fromLTRB(76, 44, 134, 106),
      Paint()..color = skin,
    );

    // Bangs
    final bangs = Path()
      ..moveTo(72, 74)
      ..cubicTo(72, 36, 100, 30, 118, 38)
      ..cubicTo(134, 44, 140, 60, 138, 76)
      ..cubicTo(130, 62, 120, 56, 106, 56)
      ..cubicTo(92, 56, 80, 62, 72, 74)
      ..close();
    canvas.drawPath(bangs, hairPaint);

    // Eyes (closed, happy)
    final eye = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      const Rect.fromLTWH(85, 72, 13, 9),
      0.2,
      2.7,
      false,
      eye,
    );
    canvas.drawArc(
      const Rect.fromLTWH(112, 72, 13, 9),
      0.2,
      2.7,
      false,
      eye,
    );

    // Blush + smile
    final blush = Paint()..color = const Color(0xFFF7A9B8).withAlpha(140);
    canvas.drawOval(const Rect.fromLTWH(80, 84, 12, 7), blush);
    canvas.drawOval(const Rect.fromLTWH(118, 84, 12, 7), blush);
    canvas.drawArc(
      const Rect.fromLTWH(99, 86, 12, 8),
      0.3,
      2.5,
      false,
      Paint()
        ..color = const Color(0xFFD9707F)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round,
    );

    // Big heart being hugged
    final heart = _heartPath(105, 132, 82, 70);
    canvas.drawPath(
      heart,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA9C6), Color(0xFFF2709F)],
        ).createShader(const Rect.fromLTWH(64, 100, 82, 70)),
    );
    // Heart highlight
    canvas.drawOval(
      const Rect.fromLTWH(78, 112, 14, 8),
      Paint()..color = Colors.white.withAlpha(110),
    );

    // Hands wrapped around the heart
    final hand = Paint()..color = skin;
    canvas.drawOval(const Rect.fromLTWH(60, 116, 20, 14), hand);
    canvas.drawOval(const Rect.fromLTWH(130, 116, 20, 14), hand);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}