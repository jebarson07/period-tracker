import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/widgets/luna_bottom_nav_bar.dart';
import '../onboarding/home_screen.dart';
import '../onboarding/period_calendar_screen.dart';

/// Luna Care Home Screen: Premium 2.5D Kawaii Cartoon Wellness Dashboard.
class CareHomeScreen extends StatefulWidget {
  const CareHomeScreen({
    super.key,
    this.name = '',
    this.lastPeriodStart,
    this.cycleLength = 28,
    this.periodLength = 5,
  });

  final String name;
  final DateTime? lastPeriodStart;
  final int cycleLength;
  final int periodLength;

  @override
  State<CareHomeScreen> createState() => _CareHomeScreenState();
}

class _CareHomeScreenState extends State<CareHomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float;
  int _tab = 2; // Care tab is index 2

  // 2.5D Color System
  static const Color _primaryPink = Color(0xFFF5A6C8);
  static const Color _lightPink = Color(0xFFFCE4EF);
  static const Color _darkText = Color(0xFF704B69);
  static const Color _secondaryText = Color(0xFF987A96);

  @override
  void initState() {
    super.initState();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon 🌸'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: _primaryPink,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
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
              _lightPink,
              Color(0xFFF9E0EE),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildHeroBanner(),
                      const SizedBox(height: 20),
                      _buildGridCards(),
                      const SizedBox(height: 20),
                      _buildTodayTipCard(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              _bottomNav(),
            ],
          ),
        ),
      ),
    );
  }

  // ----- Header ------------------------------------------------------------

  Widget _buildHeader() {
    return Stack(
      children: [
        Align(
          alignment: Alignment.center,
          child: Column(
            children: const [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Luna Care',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: _darkText,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text('✨', style: TextStyle(fontSize: 22)),
                ],
              ),
              SizedBox(height: 2),
              Text(
                'Your personal period wellness companion',
                style: TextStyle(
                  fontSize: 13.5,
                  color: _secondaryText,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 0,
          top: 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _darkText.withValues(alpha: 0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => _soon('Care Favorites'),
                child: const Padding(
                  padding: EdgeInsets.all(9),
                  child: Icon(
                    Icons.favorite_border_rounded,
                    color: _primaryPink,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ----- Hero Banner -------------------------------------------------------

  Widget _buildHeroBanner() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFDE4EF),
            Color(0xFFF8D3E4),
            Color(0xFFF5C7DD),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF5B8D3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkText.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Take care\nof yourself ',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: _darkText,
                          height: 1.15,
                        ),
                      ),
                    ),
                    Text('💗', style: TextStyle(fontSize: 18)),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  'Nutrition, gentle movement, daily care and knowledge – all in one place.',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: _secondaryText,
                    fontWeight: FontWeight.w500,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            flex: 2,
            child: SizedBox(
              height: 115,
              child: _AssetOrPaint(
                assetPath: 'assets/images/care/luna_hero.png',
                painter: const _HeroGirlPainter(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Grid Feature Cards ------------------------------------------------

  Widget _buildGridCards() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _FeatureCard(
                title: 'Diet & Nutrition',
                subtitle: 'Eat well, feel supported',
                bgGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF5F8), Color(0xFFFCEAF1)],
                ),
                borderColor: const Color(0xFFF8D0E1),
                badgeIcon: Icons.restaurant_rounded,
                badgeColor: _primaryPink,
                assetPath: 'assets/images/care/diet_nutrition.png',
                painter: const _DietIllustrationPainter(),
                btnColor: const Color(0xFFFCD1E3),
                btnTextColor: const Color(0xFFD65D9B),
                onTap: () => _soon('Diet & Nutrition'),
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                title: 'Daily Care Tips',
                subtitle: 'Little habits, every day',
                bgGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8F2), Color(0xFFFFEAD9)],
                ),
                borderColor: const Color(0xFFFFD7B8),
                badgeIcon: Icons.favorite_rounded,
                badgeColor: const Color(0xFFF2994A),
                assetPath: 'assets/images/care/daily_care.png',
                painter: const _CareTipsIllustrationPainter(),
                btnColor: const Color(0xFFFFDFC2),
                btnTextColor: const Color(0xFFD36F1A),
                onTap: () => _soon('Daily Care Tips'),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            children: [
              _FeatureCard(
                title: 'Pain Relief Yoga',
                subtitle: 'Move gently, relax',
                bgGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7F0FB), Color(0xFFEDE0F8)],
                ),
                borderColor: const Color(0xFFDFC7F3),
                badgeIcon: Icons.self_improvement_rounded,
                badgeColor: const Color(0xFF9B72DC),
                assetPath: 'assets/images/care/yoga_butterfly.png',
                painter: const _YogaIllustrationPainter(),
                btnColor: const Color(0xFFE6D0FA),
                btnTextColor: const Color(0xFF8B53C6),
                onTap: () => _soon('Pain Relief Yoga'),
              ),
              const SizedBox(height: 16),
              _FeatureCard(
                title: 'Learn About Periods',
                subtitle: 'Understand your body',
                bgGradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFCEDF3), Color(0xFFF9D9E7)],
                ),
                borderColor: const Color(0xFFF4BFD8),
                badgeIcon: Icons.menu_book_rounded,
                badgeColor: const Color(0xFFD86A9E),
                assetPath: 'assets/images/care/learn_periods.png',
                painter: const _EducationIllustrationPainter(),
                btnColor: const Color(0xFFF7C8DF),
                btnTextColor: const Color(0xFFC94B8A),
                onTap: () => _soon('Learn About Periods'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ----- Today's Care Tip Card ---------------------------------------------

  Widget _buildTodayTipCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFDF7),
            Color(0xFFFFF3E4),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE0B2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _darkText.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFFFECC8),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFF2994A).withValues(alpha: 0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.lightbulb_rounded,
              color: Color(0xFFF2994A),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Today's Care Tip 🌷",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: _darkText,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'A warm compress may help ease menstrual cramps. Take time to rest when you need it.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: _secondaryText,
                    fontWeight: FontWeight.w500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 56,
            height: 48,
            child: _AssetOrPaint(
              assetPath: 'assets/images/care/care_tip_sleeping_cat.png',
              painter: const _SleepingCatPainter(),
            ),
          ),
        ],
      ),
    );
  }

  // ----- Bottom Navigation Bar ---------------------------------------------

  Widget _bottomNav() {
    return LunaBottomNavBar(
      selectedTab: _tab,
      onTabSelected: (i) {
        setState(() => _tab = i);
        if (i == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                name: widget.name,
                lastPeriodStart: widget.lastPeriodStart,
                cycleLength: widget.cycleLength,
                periodLength: widget.periodLength,
              ),
            ),
            (route) => false,
          );
        } else if (i == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PeriodCalendarScreen(
                name: widget.name,
                lastPeriodStart: widget.lastPeriodStart,
                cycleLength: widget.cycleLength,
                periodLength: widget.periodLength,
              ),
            ),
          );
        } else if (i > 2) {
          _soon(LunaBottomNavBar.items[i].$2);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Helper Widget for Asset Image or High-Detail CustomPaint Fallback
// ---------------------------------------------------------------------------

class _AssetOrPaint extends StatelessWidget {
  const _AssetOrPaint({
    required this.assetPath,
    required this.painter,
  });

  final String assetPath;
  final CustomPainter painter;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return CustomPaint(painter: painter);
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable 2.5D Feature Card Component
// ---------------------------------------------------------------------------

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.bgGradient,
    required this.borderColor,
    required this.badgeIcon,
    required this.badgeColor,
    required this.assetPath,
    required this.painter,
    required this.btnColor,
    required this.btnTextColor,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final LinearGradient bgGradient;
  final Color borderColor;
  final IconData badgeIcon;
  final Color badgeColor;
  final String assetPath;
  final CustomPainter painter;
  final Color btnColor;
  final Color btnTextColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: bgGradient,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF704B69).withValues(alpha: 0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: badgeColor.withValues(alpha: 0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(badgeIcon, size: 16, color: badgeColor),
              ),
            ),
            SizedBox(
              height: 88,
              width: double.infinity,
              child: _AssetOrPaint(
                assetPath: assetPath,
                painter: painter,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w800,
                color: Color(0xFF704B69),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF987A96),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6.5),
              decoration: BoxDecoration(
                color: btnColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: btnTextColor.withValues(alpha: 0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Explore ',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: btnTextColor,
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 13,
                    color: btnTextColor,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// High-Fidelity 2.5D Custom Painters
// ---------------------------------------------------------------------------

class _HeroGirlPainter extends CustomPainter {
  const _HeroGirlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);

    final leafStemPaint = Paint()
      ..color = const Color(0xFF7CB342)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final leftPath = Path()
      ..moveTo(center.dx - 20, center.dy + 35)
      ..quadraticBezierTo(center.dx - 45, center.dy, center.dx - 35, center.dy - 35);
    canvas.drawPath(leftPath, leafStemPaint);

    final leafFill = Paint()..color = const Color(0xFF81C784);
    canvas.drawCircle(Offset(center.dx - 40, center.dy - 20), 7, leafFill);
    canvas.drawCircle(Offset(center.dx - 30, center.dy - 30), 8, leafFill);

    final rightPath = Path()
      ..moveTo(center.dx + 20, center.dy + 35)
      ..quadraticBezierTo(center.dx + 45, center.dy, center.dx + 35, center.dy - 35);
    canvas.drawPath(rightPath, leafStemPaint);
    canvas.drawCircle(Offset(center.dx + 40, center.dy - 20), 7, leafFill);
    canvas.drawCircle(Offset(center.dx + 30, center.dy - 30), 8, leafFill);

    _drawMiniHeart(canvas, Offset(center.dx - 30, center.dy - 45), 6, const Color(0xFFFF80AB));
    _drawMiniHeart(canvas, Offset(center.dx + 25, center.dy - 40), 7, const Color(0xFFFF4081));

    final skinPaint = Paint()..color = const Color(0xFFFFD180);
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 22, skinPaint);

    final hairPaint = Paint()..color = const Color(0xFF6D3220);
    canvas.drawCircle(Offset(center.dx, center.dy - 24), 24, hairPaint);
    canvas.drawCircle(Offset(center.dx + 12, center.dy - 42), 11, hairPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF4E2619)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final leftEye = Path()..addArc(Rect.fromLTWH(center.dx - 12, center.dy - 25, 8, 6), math.pi, -math.pi);
    final rightEye = Path()..addArc(Rect.fromLTWH(center.dx + 4, center.dy - 25, 8, 6), math.pi, -math.pi);
    canvas.drawPath(leftEye, linePaint);
    canvas.drawPath(rightEye, linePaint);

    canvas.drawArc(Rect.fromLTWH(center.dx - 12, center.dy - 31, 8, 4), math.pi, -math.pi, false, linePaint);
    canvas.drawArc(Rect.fromLTWH(center.dx + 4, center.dy - 31, 8, 4), math.pi, -math.pi, false, linePaint);
    canvas.drawArc(Rect.fromLTWH(center.dx - 4, center.dy - 14, 8, 6), 0, math.pi, false, linePaint);

    final blush = Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.6);
    canvas.drawCircle(Offset(center.dx - 10, center.dy - 16), 4, blush);
    canvas.drawCircle(Offset(center.dx + 10, center.dy - 16), 4, blush);

    final hSize = 22.0;
    final hCenter = Offset(center.dx, center.dy + 14);
    final heartPath = Path();
    heartPath.moveTo(hCenter.dx, hCenter.dy + hSize * 0.6);
    heartPath.cubicTo(
      hCenter.dx - hSize * 1.1, hCenter.dy + hSize * 0.1,
      hCenter.dx - hSize * 0.7, hCenter.dy - hSize * 0.8,
      hCenter.dx, hCenter.dy - hSize * 0.3,
    );
    heartPath.cubicTo(
      hCenter.dx + hSize * 0.7, hCenter.dy - hSize * 0.8,
      hCenter.dx + hSize * 1.1, hCenter.dy + hSize * 0.1,
      hCenter.dx, hCenter.dy + hSize * 0.6,
    );

    final heartPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF80AB), Color(0xFFF48FB1), Color(0xFFEC407A)],
      ).createShader(Rect.fromCircle(center: hCenter, radius: hSize));
    canvas.drawPath(heartPath, heartPaint);

    final armPaint = Paint()
      ..color = const Color(0xFFFFD180)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromLTWH(hCenter.dx - 19, hCenter.dy - 10, 38, 20), 0, math.pi, false, armPaint);
  }

  void _drawMiniHeart(Canvas canvas, Offset center, double size, Color color) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.6);
    path.cubicTo(
      center.dx - size, center.dy,
      center.dx - size * 0.5, center.dy - size,
      center.dx, center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5, center.dy - size,
      center.dx + size, center.dy,
      center.dx, center.dy + size * 0.6,
    );
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _DietIllustrationPainter extends CustomPainter {
  const _DietIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);

    final leafPaint = Paint()..color = const Color(0xFF81C784);
    canvas.drawCircle(Offset(center.dx + 28, center.dy + 8), 5, leafPaint);
    canvas.drawCircle(Offset(center.dx + 32, center.dy + 2), 6, leafPaint);

    final bowlPath = Path()
      ..addArc(Rect.fromLTWH(center.dx - 32, center.dy - 12, 64, 38), 0, math.pi);
    final bowlPaint = Paint()..color = const Color(0xFFFDEAF2);
    canvas.drawPath(bowlPath, bowlPaint);
    canvas.drawPath(bowlPath, Paint()..color = const Color(0xFFE882B4)..style = PaintingStyle.stroke..strokeWidth = 1.8);

    final greensPaint = Paint()..color = const Color(0xFF66BB6A);
    canvas.drawCircle(Offset(center.dx - 18, center.dy - 16), 11, greensPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 13, greensPaint);
    canvas.drawCircle(Offset(center.dx + 16, center.dy - 15), 10, greensPaint);

    canvas.drawCircle(Offset(center.dx - 16, center.dy - 10), 10, Paint()..color = const Color(0xFFFF5252));
    canvas.drawCircle(Offset(center.dx, center.dy - 12), 12, Paint()..color = const Color(0xFFFFA726));
    canvas.drawCircle(Offset(center.dx + 14, center.dy - 8), 9, Paint()..color = const Color(0xFFFFEE58));

    final berryPaint = Paint()..color = const Color(0xFF5C6BC0);
    canvas.drawCircle(Offset(center.dx - 6, center.dy - 6), 5, berryPaint);
    canvas.drawCircle(Offset(center.dx + 4, center.dy - 4), 5, berryPaint);

    final sparklePaint = Paint()..color = const Color(0xFFFFD54F);
    canvas.drawRect(Rect.fromLTWH(center.dx - 28, center.dy - 25, 3, 7), sparklePaint);
    canvas.drawRect(Rect.fromLTWH(center.dx - 32, center.dy - 21, 7, 3), sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _YogaIllustrationPainter extends CustomPainter {
  const _YogaIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);

    final plantPaint = Paint()..color = const Color(0xFFB39DDB);
    canvas.drawCircle(Offset(center.dx - 32, center.dy - 10), 8, plantPaint);
    canvas.drawCircle(Offset(center.dx + 32, center.dy - 10), 8, plantPaint);

    final matPaint = Paint()..color = const Color(0xFFF48FB1);
    canvas.drawRRect(RRect.fromLTRBR(center.dx - 34, center.dy + 18, center.dx + 34, center.dy + 24, const Radius.circular(5)), matPaint);

    final skinPaint = Paint()..color = const Color(0xFFFFD180);
    canvas.drawCircle(Offset(center.dx, center.dy - 18), 12, skinPaint);

    final hairPaint = Paint()..color = const Color(0xFF5D4037);
    canvas.drawCircle(Offset(center.dx, center.dy - 20), 13, hairPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 32), 6, hairPaint);
    canvas.drawCircle(Offset(center.dx, center.dy - 26), 4, Paint()..color = const Color(0xFFF48FB1));

    final linePaint = Paint()
      ..color = const Color(0xFF3E2723)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    canvas.drawArc(Rect.fromLTWH(center.dx - 6, center.dy - 20, 5, 4), math.pi, -math.pi, false, linePaint);
    canvas.drawArc(Rect.fromLTWH(center.dx + 1, center.dy - 20, 5, 4), math.pi, -math.pi, false, linePaint);

    final topPaint = Paint()..color = const Color(0xFF9B72DC);
    canvas.drawRRect(RRect.fromLTRBR(center.dx - 9, center.dy - 6, center.dx + 9, center.dy + 10, const Radius.circular(6)), topPaint);
    canvas.drawCircle(Offset(center.dx, center.dy + 2), 3, Paint()..color = const Color(0xFFF48FB1));

    final legPaint = Paint()..color = const Color(0xFF7B1FA2);
    canvas.drawCircle(Offset(center.dx - 16, center.dy + 14), 7.5, legPaint);
    canvas.drawCircle(Offset(center.dx + 16, center.dy + 14), 7.5, legPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CareTipsIllustrationPainter extends CustomPainter {
  const _CareTipsIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.55);

    final flowerPaint = Paint()..color = const Color(0xFFFF80AB);
    canvas.drawCircle(Offset(center.dx - 32, center.dy + 5), 5, flowerPaint);
    canvas.drawCircle(Offset(center.dx + 30, center.dy + 8), 5, flowerPaint);

    final bottlePaint = Paint()..color = const Color(0xFFFF7043);
    canvas.drawRRect(RRect.fromLTRBR(center.dx + 2, center.dy - 15, center.dx + 26, center.dy + 18, const Radius.circular(9)), bottlePaint);
    canvas.drawRect(Rect.fromLTWH(center.dx + 10, center.dy - 20, 8, 5), Paint()..color = const Color(0xFFF2994A));

    final cupPaint = Paint()..color = const Color(0xFFFFF0F5);
    canvas.drawRRect(RRect.fromLTRBR(center.dx - 28, center.dy - 10, center.dx - 4, center.dy + 18, const Radius.circular(9)), cupPaint);
    canvas.drawPath(
      Path()..addRRect(RRect.fromLTRBR(center.dx - 28, center.dy - 10, center.dx - 4, center.dy + 18, const Radius.circular(9))),
      Paint()..color = const Color(0xFFFF80AB)..style = PaintingStyle.stroke..strokeWidth = 1.5,
    );
    canvas.drawCircle(Offset(center.dx - 16, center.dy + 4), 4, Paint()..color = const Color(0xFFFF80AB));

    final steamPaint = Paint()
      ..color = const Color(0xFFF2994A).withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    final path = Path()
      ..moveTo(center.dx - 16, center.dy - 12)
      ..quadraticBezierTo(center.dx - 20, center.dy - 18, center.dx - 16, center.dy - 24);
    canvas.drawPath(path, steamPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EducationIllustrationPainter extends CustomPainter {
  const _EducationIllustrationPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.5);

    final mainPaint = Paint()..color = const Color(0xFFEC407A);

    canvas.drawCircle(center, 13, mainPaint);

    canvas.drawCircle(Offset(center.dx - 22, center.dy - 10), 9, mainPaint);
    canvas.drawCircle(Offset(center.dx + 22, center.dy - 10), 9, mainPaint);

    final armPath = Path()
      ..moveTo(center.dx - 22, center.dy - 10)
      ..quadraticBezierTo(center.dx, center.dy - 4, center.dx + 22, center.dy - 10);
    canvas.drawPath(armPath, Paint()..color = const Color(0xFFEC407A)..style = PaintingStyle.stroke..strokeWidth = 7..strokeCap = StrokeCap.round);

    final flowerPaint = Paint()..color = const Color(0xFFFF80AB);
    canvas.drawCircle(Offset(center.dx - 28, center.dy + 12), 6, flowerPaint);
    canvas.drawCircle(Offset(center.dx + 28, center.dy + 12), 6, flowerPaint);
    canvas.drawCircle(Offset(center.dx - 28, center.dy + 12), 2, Paint()..color = const Color(0xFFFFEB3B));
    canvas.drawCircle(Offset(center.dx + 28, center.dy + 12), 2, Paint()..color = const Color(0xFFFFEB3B));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SleepingCatPainter extends CustomPainter {
  const _SleepingCatPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.5, h * 0.6);

    final catPaint = Paint()..color = const Color(0xFFFFCC80);
    canvas.drawOval(Rect.fromLTWH(center.dx - 18, center.dy - 10, 36, 20), catPaint);

    canvas.drawCircle(Offset(center.dx + 12, center.dy - 4), 10, catPaint);

    final earPath = Path()
      ..moveTo(center.dx + 8, center.dy - 12)
      ..lineTo(center.dx + 12, center.dy - 18)
      ..lineTo(center.dx + 16, center.dy - 12);
    canvas.drawPath(earPath, catPaint);

    final eyePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(Rect.fromLTWH(center.dx + 12, center.dy - 5, 5, 4), 0, math.pi, false, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
