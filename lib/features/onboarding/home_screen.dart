import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/services/cycle_calculation_service.dart';
import '../../core/widgets/luna_bottom_nav_bar.dart';
import '../care/care_home_screen.dart';
import 'period_calendar_screen.dart';

// ---------------------------------------------------------------------------
// Date helpers
// ---------------------------------------------------------------------------

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

/// Whole days from [a] to [b] (DST-safe).
int _daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

DateTime _startOfWeek(DateTime d) => _addDays(d, -(d.weekday % 7)); // Sunday

const _monthsFull = [
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

const _monthsShort = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

const _weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

const _hotPink = Color(0xFFEE6FA0);

// ---------------------------------------------------------------------------
// Home screen
// ---------------------------------------------------------------------------

/// Luna home dashboard.
///
/// The cycle wheel follows the day selected in the weekly calendar.
/// All cycle numbers are estimates calculated from [lastPeriodStart].
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.name = '',
    this.lastPeriodStart,
    this.cycleLength = 28,
    this.periodLength = 5,
  });

  final String name;

  /// First day of the last period. If null, the wheel shows a gentle prompt.
  final DateTime? lastPeriodStart;

  final int cycleLength;
  final int periodLength;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late final DateTime _today;
  late DateTime _selected;
  late DateTime _weekStart;
  late final AnimationController _float;
  int _tab = 0;

  static const _petals = <_PetalSpec>[
    _PetalSpec(-0.92, -0.20, 26, 0.9, 0.0),
    _PetalSpec(0.94, -0.10, 22, -0.6, 1.3),
    _PetalSpec(-0.95, 0.35, 30, 2.3, 2.0),
    _PetalSpec(0.92, 0.45, 26, 0.4, 0.7),
    _PetalSpec(0.90, -0.62, 20, 0.8, 1.6),
  ];

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    _selected = _today;
    _weekStart = _startOfWeek(_today);
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

  // ----- cycle maths (estimates) -------------------------------------------

  CycleStats get _stats => CycleCalculationService.instance.calculateStats(
        records: PeriodRecordsRepository.instance.records,
        onboardingLastPeriodStart: widget.lastPeriodStart,
        onboardingCycleLength: widget.cycleLength,
        onboardingPeriodLength: widget.periodLength,
        referenceDate: _today,
      );

  int get _activeCycleLength => _stats.averageCycleLength ?? widget.cycleLength;
  int get _activePeriodLength => _stats.averagePeriodDuration ?? widget.periodLength;

  bool get _hasData => _stats.latestPeriodStart != null;

  DateTime get _start => _stats.latestPeriodStart!;

  /// Cycle day (1-based) for [d], or null if there is no data for that day.
  int? _cycleDay(DateTime d) {
    if (!_hasData) return null;
    final diff = _daysBetween(_start, d);
    if (diff < 0) return null;
    return diff % _activeCycleLength + 1;
  }

  bool _isPeriodDay(DateTime d) {
    final day = _cycleDay(d);
    return day != null && day <= _activePeriodLength;
  }

  DateTime? get _nextPeriod {
    if (!_hasData) return null;
    final diff = _daysBetween(_start, _today);
    final k = diff < 0 ? 0 : diff ~/ _activeCycleLength + 1;
    return _addDays(_start, k * _activeCycleLength);
  }

  String _fmt(DateTime d) => '${d.day} ${_monthsShort[d.month - 1]} ${d.year}';

  (String title, String line1, String line2) _periodInfo({
    required int day,
    required DateTime cycleStartDate,
    required DateTime periodEndDate,
    required DateTime nextPeriodDate,
  }) {
    final startFmt = '${cycleStartDate.day} ${_monthsShort[cycleStartDate.month - 1]}';
    final endFmt = '${periodEndDate.day} ${_monthsShort[periodEndDate.month - 1]}';
    final nextFmt = '${nextPeriodDate.day} ${_monthsShort[nextPeriodDate.month - 1]}';
    final periodRange = '$startFmt – $endFmt';

    if (day <= widget.periodLength) {
      final daysLeft = widget.periodLength - day;
      return (
        'Period',
        'Day $day of ${widget.periodLength} ($periodRange)',
        daysLeft == 0 ? 'Last day of period' : '$daysLeft days left',
      );
    }

    final daysUntil = _daysBetween(_selected, nextPeriodDate);
    if (daysUntil > 0) {
      return (
        'Day $day',
        daysUntil == 1
            ? 'Period starts tomorrow ($nextFmt)'
            : 'Period in $daysUntil days ($nextFmt)',
        'Period: $periodRange',
      );
    }

    final overdue = -daysUntil;
    return (
      'Day $day',
      'Period expected ($nextFmt)',
      overdue == 0
          ? 'Expected today'
          : (overdue == 1 ? '1 day late' : '$overdue days late'),
    );
  }

  void _soon(String what) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$what is coming soon 🌸'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
  }

  // ----- build --------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final name = widget.name.trim().isEmpty ? 'friend' : widget.name.trim();
    final day = _cycleDay(_selected);

    DateTime? cycleStartDate;
    DateTime? periodEndDate;
    DateTime? nextPeriodDate;
    String? periodRangeText;

    if (_hasData) {
      final diff = _daysBetween(_start, _selected);
      final cycleIndex = diff < 0 ? 0 : diff ~/ widget.cycleLength;
      cycleStartDate = _addDays(_start, cycleIndex * widget.cycleLength);
      periodEndDate = _addDays(cycleStartDate, widget.periodLength - 1);
      nextPeriodDate = _addDays(cycleStartDate, widget.cycleLength);
      final startFmt = '${cycleStartDate.day} ${_monthsShort[cycleStartDate.month - 1]}';
      final endFmt = '${periodEndDate.day} ${_monthsShort[periodEndDate.month - 1]}';
      periodRangeText = '$startFmt – $endFmt';
    }

    String title;
    String line1;
    String line2;
    if (!_hasData) {
      title = 'Add date';
      line1 = 'Log your last period';
      line2 = 'to see your cycle';
    } else if (day == null) {
      title = 'No data';
      line1 = 'This day is before';
      line2 = 'your first log';
    } else {
      final info = _periodInfo(
        day: day,
        cycleStartDate: cycleStartDate!,
        periodEndDate: periodEndDate!,
        nextPeriodDate: nextPeriodDate!,
      );
      title = info.$1;
      line1 = info.$2;
      line2 = info.$3;
    }

    final next = _nextPeriod;
    String nextTitle = 'Add a date';
    String nextSub = '';
    if (next != null) {
      final n = _daysBetween(_today, next);
      nextTitle = n == 0 ? 'Today' : (n == 1 ? 'in 1 day' : 'in $n days');
      nextSub = '(≈ ${_fmt(next)})';
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFCEAF3),
              AppColors.background,
              Color(0xFFF8DCEB),
            ],
            stops: [0.0, 0.45, 1.0],
          ),
        ),
        child: Stack(
          children: [
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
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        children: [
                          _header(),
                          const SizedBox(height: 8),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                            child: _greetingCard(name),
                          ),
                          const SizedBox(height: 14),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                            child: _weekCard(),
                          ),
                          const SizedBox(height: 6),
                          _CycleWheel(
                            day: day,
                            title: title,
                            line1: line1,
                            line2: line2,
                            cycleLength: widget.cycleLength,
                            periodLength: widget.periodLength,
                            startDate: cycleStartDate,
                            endDate: periodEndDate,
                            nextDate: nextPeriodDate,
                          ),
                          const SizedBox(height: 10),
                          _WheelLegend(
                            periodRange: periodRangeText,
                            cycleLength: widget.cycleLength,
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                            child: _infoCard(nextTitle, nextSub),
                          ),
                          const SizedBox(height: 16),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 18),
                            child: _quickCards(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _bottomNav(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- header -------------------------------------------------------------

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 6, 14, 0),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: IconButton(
              tooltip: 'Menu',
              onPressed: () => _soon('Menu'),
              icon: const Icon(
                Icons.menu_rounded,
                size: 30,
                color: AppColors.text,
              ),
            ),
          ),
          const Expanded(child: Center(child: _Logo())),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Material(
                color: const Color(0xD9FFFFFF),
                shape: const CircleBorder(),
                elevation: 0,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => _soon('Notifications'),
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x22D4558C),
                          blurRadius: 14,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.notifications_none_rounded,
                      size: 28,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  width: 12,
                  height: 12,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8446F),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- greeting -----------------------------------------------------------

  Widget _greetingCard(String name) {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [Color(0xCCFBD3E3), Color(0x99FCE6F0)],
        ),
        border: Border.all(color: const Color(0x99FFFFFF), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1FD4558C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: [
            Positioned(
              left: 6,
              bottom: 0,
              child: SizedBox(
                width: 116,
                height: 88,
                child: Image.asset(
                  'assets/images/home_girl.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, _, _) =>
                  const CustomPaint(painter: _GirlPainter()),
                ),
              ),
            ),
            Positioned(
              left: 132,
              right: 48,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Hi, $name!',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('💕', style: TextStyle(fontSize: 22)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Stay kind to yourself today ♡',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
            const Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: SizedBox(
                  width: 28,
                  height: 36,
                  child: CustomPaint(painter: _SparkLinesPainter()),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- weekly calendar ----------------------------------------------------

  Widget _weekCard() {
    final mid = _addDays(_weekStart, 3);
    final days = List.generate(7, (i) => _addDays(_weekStart, i));

    return _Glass(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Previous week',
                onPressed: () =>
                    setState(() => _weekStart = _addDays(_weekStart, -7)),
                icon: const Icon(
                  Icons.chevron_left_rounded,
                  size: 32,
                  color: AppColors.text,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _openFullCalendar(_selected),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${_monthsFull[mid.month - 1]} ${mid.year}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.text,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Next week',
                onPressed: () =>
                    setState(() => _weekStart = _addDays(_weekStart, 7)),
                icon: const Icon(
                  Icons.chevron_right_rounded,
                  size: 32,
                  color: AppColors.text,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [for (final d in days) Expanded(child: _dayCell(d))],
          ),
        ],
      ),
    );
  }

  Widget _dayCell(DateTime d) {
    final isSelected = _daysBetween(d, _selected) == 0;
    final isToday = _daysBetween(d, _today) == 0;
    final isPeriod = _isPeriodDay(d);

    return Semantics(
      button: true,
      selected: isSelected,
      label: '${_weekdays[d.weekday % 7]} ${d.day} ${_monthsFull[d.month - 1]}'
          '${isPeriod ? ', estimated period day' : ''}',
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => setState(() => _selected = d),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _weekdays[d.weekday % 7],
                style: TextStyle(
                  fontSize: 14,
                  color: isSelected ? AppColors.text : AppColors.textMuted,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  boxShadow: isSelected
                      ? const [
                    BoxShadow(
                      color: Color(0x5598577F),
                      blurRadius: 12,
                      offset: Offset(0, 5),
                    ),
                  ]
                      : null,
                ),
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.text,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              SizedBox(
                height: 12,
                child: isPeriod
                    ? const Icon(Icons.water_drop, size: 12, color: _hotPink)
                    : (isToday
                    ? Center(
                  child: Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : null),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----- next period / cycle length ----------------------------------------

  Widget _infoCard(String nextTitle, String nextSub) {
    return _Glass(
      radius: 32,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Row(
                children: [
                  const _IconBubble(icon: Icons.calendar_month_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Next Period',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            nextTitle,
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                        ),
                        if (nextSub.isNotEmpty)
                          Text(
                            nextSub,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textMuted,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 1.2,
              margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              color: const Color(0xFFF0C4D8),
            ),
            Expanded(
              child: Row(
                children: [
                  const _IconBubble(icon: Icons.local_florist_outlined),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Cycle Length',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textMuted,
                          ),
                        ),
                        Text(
                          '${widget.cycleLength} days',
                          style: const TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                            color: AppColors.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ----- quick actions ------------------------------------------------------

  Widget _quickCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _QuickCard(
              title: 'Mood',
              subtitle: 'How are you\nfeeling?',
              icon: Icons.sentiment_satisfied_alt_rounded,
              colors: const [Color(0xFFFDE4E4), Color(0xFFFBD3E2)],
              onTap: () => _soon('Mood tracking'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              title: 'Cramps',
              subtitle: 'Any symptoms?',
              icon: Icons.healing_rounded,
              colors: const [Color(0xFFF8E3F2), Color(0xFFEBD9F7)],
              onTap: () => _soon('Symptom logging'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _QuickCard(
              title: 'Drugs',
              subtitle: 'Take any\nsupplements?',
              icon: Icons.medication_outlined,
              colors: const [Color(0xFFE9E6FB), Color(0xFFDCE0F8)],
              onTap: () => _soon('Medicine log'),
            ),
          ),
        ],
      ),
    );
  }

  void _openFullCalendar([DateTime? initialDate]) async {
    final returnedDate = await Navigator.push<DateTime>(
      context,
      MaterialPageRoute(
        builder: (_) => PeriodCalendarScreen(
          name: widget.name,
          lastPeriodStart: widget.lastPeriodStart,
          cycleLength: widget.cycleLength,
          periodLength: widget.periodLength,
          initialSelectedDate: initialDate ?? _selected,
        ),
      ),
    );
    if (returnedDate != null && mounted) {
      setState(() {
        _selected = _dateOnly(returnedDate);
        _weekStart = _startOfWeek(_selected);
      });
    }
  }

  // ----- bottom navigation --------------------------------------------------

  Widget _bottomNav() {
    return LunaBottomNavBar(
      selectedTab: _tab,
      onTabSelected: (i) {
        setState(() => _tab = i);
        if (i == 1) {
          _openFullCalendar(_selected);
        } else if (i == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CareHomeScreen(
                name: widget.name,
                lastPeriodStart: widget.lastPeriodStart,
                cycleLength: widget.cycleLength,
                periodLength: widget.periodLength,
              ),
            ),
          ).then((_) => setState(() => _tab = 0));
        } else if (i > 2) {
          _soon(LunaBottomNavBar.items[i].$2);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Small reusable widgets
// ---------------------------------------------------------------------------

class _Glass extends StatelessWidget {
  const _Glass({
    required this.child,
    required this.radius,
    required this.padding,
  });

  final Widget child;
  final double radius;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: const Color(0x99FFFFFF),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: const Color(0xB3FFFFFF), width: 1.4),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AD4558C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _IconBubble extends StatelessWidget {
  const _IconBubble({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: const BoxDecoration(
        color: Color(0xE6FFFFFF),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Color(0x1FD4558C),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, size: 28, color: AppColors.primary),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.colors,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. ${subtitle.replaceAll('\n', ' ')}',
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: colors,
          ),
          border: Border.all(color: const Color(0xB3FFFFFF), width: 1.4),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1AD4558C),
              blurRadius: 16,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      color: Color(0xCCFFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 28, color: AppColors.primary),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      height: 1.3,
                      color: AppColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xE6FFFFFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.text,
                      ),
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
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 34,
          height: 26,
          child: CustomPaint(painter: _MiniLotusPainter()),
        ),
        Text(
          'luna',
          style: TextStyle(
            fontSize: 44,
            height: 1.0,
            fontWeight: FontWeight.w300,
            color: AppColors.text,
            letterSpacing: 1.5,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'PERIOD TRACKER',
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: AppColors.text,
            letterSpacing: 5,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cycle wheel (the signature feature)
// ---------------------------------------------------------------------------

class _CycleWheel extends StatelessWidget {
  const _CycleWheel({
    required this.day,
    required this.title,
    required this.line1,
    required this.line2,
    required this.cycleLength,
    required this.periodLength,
    this.startDate,
    this.endDate,
    this.nextDate,
  });

  /// Selected cycle day, or null when there is nothing to show.
  final int? day;
  final String title;
  final String line1;
  final String line2;
  final int cycleLength;
  final int periodLength;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextDate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final wheel = math.min(w * 0.78, 320.0);

        return Semantics(
          label: day == null
              ? 'Cycle wheel. $title. $line1 $line2'
              : 'Cycle wheel. Day $day of $cycleLength. $line1, $line2. '
                  'Estimate only.',
          child: SizedBox(
            width: w,
            height: w * 0.98,
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Positioned.fill(
                  child: CustomPaint(painter: _LotusPetalsPainter()),
                ),
                SizedBox(
                  width: wheel,
                  height: wheel,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(end: (day ?? 1).toDouble()),
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOutCubic,
                        builder: (context, value, _) {
                          return CustomPaint(
                            size: Size.square(wheel),
                            painter: _WheelPainter(
                              cycleLength: cycleLength,
                              periodLength: periodLength,
                              day: value,
                              showSelection: day != null,
                              startDate: startDate,
                              endDate: endDate,
                              nextDate: nextDate,
                            ),
                          );
                        },
                      ),
                      SizedBox(
                        width: wheel * 0.65,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: FittedBox(
                            key: ValueKey('$title|$line1|$line2'),
                            fit: BoxFit.scaleDown,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.water_drop_rounded,
                                  size: wheel * 0.09,
                                  color: _hotPink,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  title,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: wheel * 0.12,
                                    height: 1.1,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  line1,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: wheel * 0.045,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  line2,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: wheel * 0.042,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _WheelPainter extends CustomPainter {
  _WheelPainter({
    required this.cycleLength,
    required this.periodLength,
    required this.day,
    required this.showSelection,
    this.startDate,
    this.endDate,
    this.nextDate,
  });

  final int cycleLength;
  final int periodLength;

  /// Selected day (fractional while animating).
  final double day;
  final bool showSelection;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? nextDate;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width * 0.44;
    final step = 2 * math.pi / cycleLength;
    double angle(double d) => -math.pi / 2 + (d - 1) * step;
    Offset onTrack(double d, double radius) =>
        c + Offset(math.cos(angle(d)), math.sin(angle(d))) * radius;

    final trackR = r * 0.86;
    final trackW = r * 0.16;

    // Soft shadow + disc
    canvas.drawCircle(
      c.translate(0, 8),
      r,
      Paint()
        ..color = const Color(0x33D4558C)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = const RadialGradient(
          colors: [Color(0xF5FFFFFF), Color(0xD9FCE4EF)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = const Color(0xFFFFFFFF),
    );

    // Light track that holds the cycle days
    canvas.drawCircle(
      c,
      trackR,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW
        ..color = const Color(0x59F4A6C6),
    );
    final dot = Paint()..color = const Color(0xE6FFFFFF);
    for (var d = periodLength + 1; d <= cycleLength; d++) {
      canvas.drawCircle(onTrack(d.toDouble(), trackR), 1.8, dot);
    }

    // Inner circle that holds the text
    canvas.drawCircle(c, r * 0.56, Paint()..color = const Color(0x80FFFFFF));
    canvas.drawCircle(
      c,
      r * 0.56,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = const Color(0x66F4A6C6),
    );

    // Period band
    final bandStart = angle(1) - step / 2;
    final bandSweep = periodLength * step;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: trackR),
      bandStart,
      bandSweep,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = trackW
        ..strokeCap = StrokeCap.round
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFE8629A), Color(0xFFCF4F86)],
        ).createShader(Rect.fromCircle(center: c, radius: r)),
    );

    if (periodLength >= 3) {
      _paintTextAlongArc(
        canvas,
        center: c,
        radius: trackR,
        midAngle: bandStart + bandSweep / 2,
        text: 'Period',
      );
    }

    // Start-of-period marker (droplet) at Day 1
    final sp = c + Offset(math.cos(bandStart), math.sin(bandStart)) * trackR;
    canvas.drawCircle(
      sp.translate(0, 2),
      14,
      Paint()
        ..color = const Color(0x33000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(sp, 14, Paint()..color = Colors.white);
    canvas.drawPath(
      _dropPath(sp.translate(0, 1), 7),
      Paint()..color = _hotPink,
    );

    // End-of-period marker at Day `periodLength`
    final bandEnd = bandStart + bandSweep;
    final ep = c + Offset(math.cos(bandEnd), math.sin(bandEnd)) * trackR;
    canvas.drawCircle(
      ep.translate(0, 2),
      10,
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(ep, 10, Paint()..color = Colors.white);
    canvas.drawCircle(ep, 6, Paint()..color = const Color(0xFFE8629A));
    canvas.drawCircle(ep, 2, Paint()..color = Colors.white);

    // Dates & key reference markers on the wheel
    final labelRadius = r * 0.67;
    const dateStyle = TextStyle(
      color: Color(0xFFB54877),
      fontSize: 11.5,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );
    const subStyle = TextStyle(
      color: AppColors.textMuted,
      fontSize: 10.5,
      fontWeight: FontWeight.w600,
    );

    if (startDate != null && endDate != null) {
      // 1. Start date (e.g., "3 Jan" / "3 Nov") under start droplet
      final startLabel = '${startDate!.day} ${_monthsShort[startDate!.month - 1]}';
      final tpStart = TextPainter(
        text: TextSpan(text: startLabel, style: dateStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final pStart = onTrack(1.0, labelRadius);
      tpStart.paint(canvas, pStart - Offset(tpStart.width / 2, tpStart.height / 2));

      // 2. End date (e.g., "7 Jan" / "7 Nov") under end marker
      final endLabel = '${endDate!.day} ${_monthsShort[endDate!.month - 1]}';
      final tpEnd = TextPainter(
        text: TextSpan(text: endLabel, style: dateStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      final pEnd = onTrack(periodLength.toDouble(), labelRadius);
      tpEnd.paint(canvas, pEnd - Offset(tpEnd.width / 2, tpEnd.height / 2));

      // (Next period date label removed from track to avoid overlap)
    } else {
      // Fallback labels if no date logged yet
      for (final d in [1, periodLength, cycleLength ~/ 2]) {
        final tp = TextPainter(
          text: TextSpan(text: 'Day $d', style: subStyle),
          textDirection: TextDirection.ltr,
        )..layout();
        final p = onTrack(d.toDouble(), labelRadius);
        tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
      }
    }

    // Selected-day knob
    if (showSelection) {
      final p = onTrack(day, trackR);
      canvas.drawCircle(
        p.translate(0, 2),
        12,
        Paint()
          ..color = const Color(0x44000000)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      canvas.drawCircle(p, 12, Paint()..color = Colors.white);
      canvas.drawCircle(p, 7.5, Paint()..color = AppColors.primary);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
    }
  }

  void _paintTextAlongArc(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required double midAngle,
    required String text,
  }) {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 12,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.6,
    );
    final painters = [
      for (final ch in text.split(''))
        TextPainter(
          text: TextSpan(text: ch, style: style),
          textDirection: TextDirection.ltr,
        )..layout(),
    ];
    final total = painters.fold<double>(0, (s, p) => s + p.width);
    var theta = midAngle - total / (2 * radius) + 0.10;
    for (final tp in painters) {
      final a = theta + tp.width / (2 * radius);
      final pos = center + Offset(math.cos(a), math.sin(a)) * radius;
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(a + math.pi / 2);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
      theta += tp.width / radius;
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) =>
      old.day != day ||
      old.cycleLength != cycleLength ||
      old.periodLength != periodLength ||
      old.showSelection != showSelection ||
      old.startDate != startDate ||
      old.endDate != endDate ||
      old.nextDate != nextDate;
}

/// Small key under the wheel so the symbols are explained in words.
class _WheelLegend extends StatelessWidget {
  const _WheelLegend({
    this.periodRange,
    this.cycleLength,
  });

  final String? periodRange;
  final int? cycleLength;

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(fontSize: 13, color: AppColors.textMuted);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFD95A8F),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.water_drop, size: 12, color: Colors.white),
            ),
            const SizedBox(width: 6),
            const Text('Period days', style: style),
            const SizedBox(width: 20),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primary, width: 4.5),
              ),
            ),
            const SizedBox(width: 6),
            const Text('Selected day', style: style),
          ],
        ),
        if (periodRange != null && cycleLength != null) ...[
          const SizedBox(height: 6),
          Text(
            'Period: $periodRange · Cycle: $cycleLength days',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
            ),
          ),
        ],
      ],
    );
  }
}

Path _dropPath(Offset c, double s) {
  return Path()
    ..moveTo(c.dx, c.dy - s)
    ..cubicTo(c.dx + s * 0.95, c.dy - s * 0.1, c.dx + s * 0.85, c.dy + s * 0.95,
        c.dx, c.dy + s * 0.95)
    ..cubicTo(c.dx - s * 0.85, c.dy + s * 0.95, c.dx - s * 0.95, c.dy - s * 0.1,
        c.dx, c.dy - s)
    ..close();
}

// ---------------------------------------------------------------------------
// Lotus petals behind the wheel
// ---------------------------------------------------------------------------

class _LotusPetalsPainter extends CustomPainter {
  const _LotusPetalsPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final c = Offset(w / 2, size.height * 0.52);

    // Ripple under the flower
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0x55F4A6C6);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, size.height * 0.86),
        width: w * 0.95,
        height: w * 0.12,
      ),
      ripple,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, size.height * 0.86),
        width: w * 0.70,
        height: w * 0.08,
      ),
      ripple,
    );

    // Layers of large, soft petals
    const petals = <List<double>>[
      // angle, length factor, width factor
      [-150, 0.50, 0.15],
      [150, 0.50, 0.15],
      [-125, 0.55, 0.16],
      [125, 0.55, 0.16],
      [-100, 0.54, 0.16],
      [100, 0.54, 0.16],
      [-72, 0.56, 0.17],
      [72, 0.56, 0.17],
      [-42, 0.55, 0.17],
      [42, 0.55, 0.17],
    ];
    for (final p in petals) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(p[0] * math.pi / 180);
      final len = w * p[1];
      final wid = w * p[2];
      final path = Path()
        ..moveTo(0, 0)
        ..cubicTo(wid * 0.95, -len * 0.25, wid * 0.55, -len * 0.85, 0, -len)
        ..cubicTo(-wid * 0.55, -len * 0.85, -wid * 0.95, -len * 0.25, 0, 0)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [Color(0x44F8B9D3), Color(0x33FFEAF2)],
          ).createShader(Rect.fromLTWH(-wid, -len, wid * 2, len)),
      );
      canvas.drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x55FFFFFF),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Small painters
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
  canvas.drawPath(
    _petalPath(w, h),
    Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [bottom, top],
      ).createShader(Rect.fromLTWH(-w, -h, w * 2, h)),
  );
  canvas.restore();
}

double _rad(double deg) => deg * math.pi / 180;

class _MiniLotusPainter extends CustomPainter {
  const _MiniLotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height);
    final h = size.height * 0.95;
    final w = size.width * 0.32;
    for (final a in [-48.0, 48.0]) {
      _drawPetal(
        canvas,
        base: base,
        angle: _rad(a),
        w: w,
        h: h * 0.85,
        bottom: const Color(0xFFF4A6C6),
        top: const Color(0xFFE5779F),
      );
    }
    _drawPetal(
      canvas,
      base: base,
      angle: 0,
      w: w,
      h: h,
      bottom: const Color(0xFFE5779F),
      top: const Color(0xFFD4558C),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _SparkLinesPainter extends CustomPainter {
  const _SparkLinesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = _hotPink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(size.width * 0.55, size.height * 0.08),
      Offset(size.width * 0.80, size.height * 0.02),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.34),
      Offset(size.width * 0.82, size.height * 0.30),
      p,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.62),
      Offset(size.width * 0.80, size.height * 0.80),
      p,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

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
    canvas.drawPath(
      _petalPath(size.width * 0.9, size.height),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [color.withAlpha(130), color.withAlpha(225)],
        ).createShader(
          Rect.fromLTWH(-size.width, -size.height, size.width * 2, size.height),
        ),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SmallPetalPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Girl hugging a pink pillow (fallback for assets/images/home_girl.png).
class _GirlPainter extends CustomPainter {
  const _GirlPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 210, size.height / 160);

    const hair = Color(0xFF6B4044);
    const skin = Color(0xFFFFE1D0);
    const ink = Color(0xFF5A3A40);

    // Small hearts
    canvas.drawPath(
      _heartPath(46, 30, 20, 18),
      Paint()..color = const Color(0xFFF58FB0),
    );
    canvas.drawPath(
      _heartPath(168, 24, 18, 16),
      Paint()..color = const Color(0xFFF7A4C0),
    );

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
    canvas.drawRRect(
      RRect.fromRectAndCorners(
        const Rect.fromLTRB(66, 110, 144, 160),
        topLeft: const Radius.circular(26),
        topRight: const Radius.circular(26),
      ),
      Paint()..color = const Color(0xFFFFEBDD),
    );
    canvas.drawOval(
      const Rect.fromLTRB(76, 44, 134, 106),
      Paint()..color = skin,
    );
    final bangs = Path()
      ..moveTo(72, 74)
      ..cubicTo(72, 36, 100, 30, 118, 38)
      ..cubicTo(134, 44, 140, 60, 138, 76)
      ..cubicTo(130, 62, 120, 56, 106, 56)
      ..cubicTo(92, 56, 80, 62, 72, 74)
      ..close();
    canvas.drawPath(bangs, hairPaint);

    // Flower in hair
    canvas.drawCircle(
      const Offset(66, 52),
      9,
      Paint()..color = const Color(0xFFF7A9C6),
    );
    canvas.drawCircle(
      const Offset(66, 52),
      3.5,
      Paint()..color = const Color(0xFFFFE08A),
    );

    final eye = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(const Rect.fromLTWH(85, 72, 13, 9), 0.2, 2.7, false, eye);
    canvas.drawArc(const Rect.fromLTWH(112, 72, 13, 9), 0.2, 2.7, false, eye);
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

    // Pink pillow (heart)
    canvas.drawPath(
      _heartPath(105, 132, 82, 70),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFFA9C6), Color(0xFFF2709F)],
        ).createShader(const Rect.fromLTWH(64, 100, 82, 70)),
    );
    final hand = Paint()..color = skin;
    canvas.drawOval(const Rect.fromLTWH(60, 116, 20, 14), hand);
    canvas.drawOval(const Rect.fromLTWH(130, 116, 20, 14), hand);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}