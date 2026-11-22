import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/models/period_record.dart';
import '../../core/services/cycle_calculation_service.dart';
import '../../core/widgets/luna_bottom_nav_bar.dart';
import '../care/care_home_screen.dart';
import 'home_screen.dart';

export '../../core/models/period_record.dart';

/// Repository to persist and manage period records across the app session.
class PeriodRecordsRepository {
  PeriodRecordsRepository._();
  static final PeriodRecordsRepository instance = PeriodRecordsRepository._();

  final List<PeriodRecord> _records = [];

  List<PeriodRecord> get records => List.unmodifiable(_records);

  void addRecord(PeriodRecord record) {
    // Remove overlapping or exact start date records if updating
    _records.removeWhere((r) =>
        _dateOnly(r.startDate).atStartOfDay() ==
        _dateOnly(record.startDate).atStartOfDay());
    _records.add(record);
    _records.sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  void updateEndDate(DateTime startDate, DateTime newEndDate) {
    final idx = _records.indexWhere(
        (r) => _dateOnly(r.startDate) == _dateOnly(startDate));
    if (idx != -1) {
      _records[idx] = _records[idx].copyWith(endDate: newEndDate);
    }
  }
}

extension on DateTime {
  DateTime atStartOfDay() => DateTime(year, month, day);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _addDays(DateTime d, int n) => DateTime(d.year, d.month, d.day + n);

int _daysBetween(DateTime a, DateTime b) {
  final ua = DateTime.utc(a.year, a.month, a.day);
  final ub = DateTime.utc(b.year, b.month, b.day);
  return ub.difference(ua).inDays;
}

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

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Period Calendar Screen for Luna Tracker.
class PeriodCalendarScreen extends StatefulWidget {
  const PeriodCalendarScreen({
    super.key,
    this.name = '',
    this.lastPeriodStart,
    this.cycleLength = 28,
    this.periodLength = 5,
    this.initialSelectedDate,
  });

  final String name;
  final DateTime? lastPeriodStart;
  final int cycleLength;
  final int periodLength;
  final DateTime? initialSelectedDate;

  @override
  State<PeriodCalendarScreen> createState() => _PeriodCalendarScreenState();
}

class _PeriodCalendarScreenState extends State<PeriodCalendarScreen>
    with SingleTickerProviderStateMixin {
  late DateTime _today;
  late DateTime _selectedDate;
  late DateTime _displayedMonth; // first day of displayed month
  late final AnimationController _float;
  int _tab = 1; // Calendar tab is index 1

  @override
  void initState() {
    super.initState();
    _today = _dateOnly(DateTime.now());
    if (widget.initialSelectedDate != null) {
      _selectedDate = _dateOnly(widget.initialSelectedDate!);
    } else {
      _selectedDate = _today;
    }
    _displayedMonth = DateTime(_selectedDate.year, _selectedDate.month, 1);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    // Initialize repo with onboarding last period if available and repo is empty
    if (widget.lastPeriodStart != null &&
        PeriodRecordsRepository.instance.records.isEmpty) {
      final start = _dateOnly(widget.lastPeriodStart!);
      final end = _addDays(start, widget.periodLength - 1);
      PeriodRecordsRepository.instance.addRecord(
        PeriodRecord(startDate: start, endDate: end),
      );
    }
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
    });
  }

  void _goToToday() {
    setState(() {
      _today = _dateOnly(DateTime.now());
      _selectedDate = _today;
      _displayedMonth = DateTime(_today.year, _today.month, 1);
    });
  }

  // ----- Calculations based on onboarding & records ------------------------

  CycleStats get _cycleStats => CycleCalculationService.instance.calculateStats(
        records: PeriodRecordsRepository.instance.records,
        onboardingLastPeriodStart: widget.lastPeriodStart,
        onboardingCycleLength: widget.cycleLength,
        onboardingPeriodLength: widget.periodLength,
        referenceDate: _today,
      );

  /// Check if [d] is within any recorded period
  bool _isRecordedPeriodDay(DateTime d) {
    final date = _dateOnly(d);
    for (final r in PeriodRecordsRepository.instance.records) {
      if (r.isConfirmed) {
        final start = _dateOnly(r.startDate);
        final end = _dateOnly(r.endDate);
        if (!date.isBefore(start) && !date.isAfter(end)) {
          return true;
        }
      }
    }
    return false;
  }

  /// Check if [d] is a predicted period day
  bool _isPredictedPeriodDay(DateTime d) {
    final stats = _cycleStats;
    if (stats.nextExpectedPeriodStart == null) return false;

    final date = _dateOnly(d);
    if (_isRecordedPeriodDay(date)) return false;

    final cycleLength = stats.averageCycleLength ?? widget.cycleLength;
    final periodDuration = stats.averagePeriodDuration ?? widget.periodLength;

    for (int i = 0; i < 6; i++) {
      final start = _addDays(stats.nextExpectedPeriodStart!, i * cycleLength);
      final end = _addDays(start, periodDuration - 1);
      if (!date.isBefore(start) && !date.isAfter(end)) {
        return true;
      }
    }
    return false;
  }

  /// Check if [d] is ovulation day (approx 14 days before next expected period)
  bool _isOvulationDay(DateTime d) {
    final stats = _cycleStats;
    if (stats.nextExpectedPeriodStart == null) return false;

    final date = _dateOnly(d);
    final cycleLength = stats.averageCycleLength ?? widget.cycleLength;

    for (int i = 0; i < 6; i++) {
      final nextPeriod = _addDays(stats.nextExpectedPeriodStart!, i * cycleLength);
      final ovulation = _addDays(nextPeriod, -14);
      if (_dateOnly(ovulation) == date) return true;
    }
    return false;
  }

  /// Check if [d] is in fertile window (5 days leading up to ovulation day)
  bool _isFertileWindowDay(DateTime d) {
    final stats = _cycleStats;
    if (stats.nextExpectedPeriodStart == null) return false;

    final date = _dateOnly(d);
    if (_isOvulationDay(date)) return false;

    final cycleLength = stats.averageCycleLength ?? widget.cycleLength;

    for (int i = 0; i < 6; i++) {
      final nextPeriod = _addDays(stats.nextExpectedPeriodStart!, i * cycleLength);
      final ovulation = _addDays(nextPeriod, -14);
      final fertileStart = _addDays(ovulation, -5);
      if (!date.isBefore(fertileStart) && !date.isAfter(ovulation)) {
        return true;
      }
    }
    return false;
  }

  int? _calculateCycleDay(DateTime d) {
    final stats = _cycleStats;
    if (stats.latestPeriodStart == null || stats.averageCycleLength == null) {
      return null;
    }
    final diff = _daysBetween(stats.latestPeriodStart!, _dateOnly(d));
    if (diff < 0) return null;
    return diff % stats.averageCycleLength! + 1;
  }

  // ----- Log Period Modal / Bottom Sheet -----------------------------------

  void _showLogPeriodBottomSheet() {
    DateTime startDate = _selectedDate;
    DateTime endDate = _addDays(_selectedDate, widget.periodLength - 1);
    String flow = 'Medium';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Log Your Period 💧',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.text,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFEADBEE)),
                    ),
                    leading: const Icon(Icons.calendar_today_rounded, color: AppColors.primary),
                    title: const Text('Start Date'),
                    trailing: Text(
                      '${startDate.day} ${_monthsShort[startDate.month - 1]} ${startDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    onTap: () async {
                      const maxDaysFromNow = 365; // allow past & future dates
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: startDate,
                        firstDate: _today.subtract(const Duration(days: maxDaysFromNow)),
                        lastDate: _today.add(const Duration(days: maxDaysFromNow)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          startDate = picked;
                          endDate = _addDays(picked, widget.periodLength - 1);
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: Color(0xFFEADBEE)),
                    ),
                    leading: const Icon(Icons.event_available_rounded, color: AppColors.primary),
                    title: const Text('End Date'),
                    trailing: Text(
                      '${endDate.day} ${_monthsShort[endDate.month - 1]} ${endDate.year}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.text),
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: endDate,
                        firstDate: startDate,
                        lastDate: _today.add(const Duration(days: 365)),
                      );
                      if (picked != null) {
                        setModalState(() {
                          endDate = picked;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Flow Intensity',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: ['Light', 'Medium', 'Heavy'].map((f) {
                      final isSel = flow == f;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GestureDetector(
                            onTap: () => setModalState(() => flow = f),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSel ? const Color(0xFFFDEAF2) : const Color(0xFFFAFAFA),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSel ? AppColors.primary : const Color(0xFFEADBEE),
                                  width: isSel ? 1.5 : 1,
                                ),
                              ),
                              child: Text(
                                f,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isSel ? AppColors.primary : AppColors.textMuted,
                                  fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      PeriodRecordsRepository.instance.addRecord(
                        PeriodRecord(startDate: startDate, endDate: endDate, flowIntensity: flow),
                      );
                      Navigator.pop(context);
                      setState(() {});
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Period logged successfully! 💧💗'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Save Period Record 💕',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _soon(String feature) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$feature is coming soon 🌸'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(context, _selectedDate);
        }
      },
      child: Scaffold(
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
                      _buildMonthNavigator(),
                      const SizedBox(height: 12),
                      _buildCalendarGrid(),
                      const SizedBox(height: 14),
                      _buildLegend(),
                      const SizedBox(height: 20),
                      _buildSelectedDateCard(),
                      const SizedBox(height: 20),
                      _buildCycleOverviewCard(),
                      const SizedBox(height: 16),
                      _buildInsightCard(),
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
    ),
    );
  }

  // ----- 1. Header ---------------------------------------------------------

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Text(
                  'My Calendar',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(width: 6),
                Text('💕', style: TextStyle(fontSize: 22)),
              ],
            ),
            SizedBox(height: 2),
            Text(
              'Your cycle, your rhythm',
              style: TextStyle(
                fontSize: 14.5,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(
          width: 90,
          height: 85,
          child: CustomPaint(
            painter: const _LunaCalendarHeaderPainter(),
          ),
        ),
      ],
    );
  }

  // ----- 2. Month Navigator ------------------------------------------------

  Widget _buildMonthNavigator() {
    final monthName = _monthsFull[_displayedMonth.month - 1];
    final year = _displayedMonth.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _previousMonth,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.chevron_left_rounded, color: AppColors.text, size: 26),
            ),
          ),
        ),
        GestureDetector(
          onTap: _goToToday,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEADBEE)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_month_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  '$monthName $year',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.text,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.arrow_drop_down_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: _nextMonth,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(Icons.chevron_right_rounded, color: AppColors.text, size: 26),
            ),
          ),
        ),
      ],
    );
  }

  // ----- 3. Monthly Calendar Grid ------------------------------------------

  Widget _buildCalendarGrid() {
    // Calculate days for the month
    final firstDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month, 1);
    final lastDayOfMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final startingWeekday = firstDayOfMonth.weekday % 7; // Sunday = 0

    // Previous month trailing days
    final prevMonthLastDay = DateTime(_displayedMonth.year, _displayedMonth.month, 0);
    final daysFromPrevMonth = startingWeekday;

    List<Widget> dayCells = [];

    // Weekday header
    for (final wd in _weekdays) {
      dayCells.add(
        Center(
          child: Text(
            wd,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
        ),
      );
    }

    // Previous month trailing days
    for (int i = daysFromPrevMonth - 1; i >= 0; i--) {
      final d = DateTime(
        _displayedMonth.year,
        _displayedMonth.month - 1,
        prevMonthLastDay.day - i,
      );
      dayCells.add(_buildDayCell(d, isCurrentMonth: false));
    }

    // Current month days
    for (int day = 1; day <= daysInMonth; day++) {
      final d = DateTime(_displayedMonth.year, _displayedMonth.month, day);
      dayCells.add(_buildDayCell(d, isCurrentMonth: true));
    }

    // Next month leading days to complete grid (42 cells total for 6 rows)
    final totalCellsSoFar = daysFromPrevMonth + daysInMonth;
    final remainingCells = totalCellsSoFar <= 35 ? 35 - totalCellsSoFar : 42 - totalCellsSoFar;
    for (int day = 1; day <= remainingCells; day++) {
      final d = DateTime(_displayedMonth.year, _displayedMonth.month + 1, day);
      dayCells.add(_buildDayCell(d, isCurrentMonth: false));
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 7,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 6,
        crossAxisSpacing: 4,
        children: dayCells,
      ),
    );
  }

  Widget _buildDayCell(DateTime d, {required bool isCurrentMonth}) {
    final date = _dateOnly(d);
    final isToday = date == _today;
    final isSelected = date == _dateOnly(_selectedDate);
    final isRecorded = _isRecordedPeriodDay(date);
    final isPredicted = _isPredictedPeriodDay(date);
    final isFertile = _isFertileWindowDay(date);
    final isOvulation = _isOvulationDay(date);

    Color? bgColor;
    Color textColor = isCurrentMonth ? AppColors.text : AppColors.textMuted.withValues(alpha: 0.4);
    Border? border;

    if (isRecorded) {
      bgColor = const Color(0xFFF4A6C6);
      textColor = Colors.white;
    } else if (isPredicted) {
      bgColor = const Color(0xFFE5D5EE);
      textColor = AppColors.text;
    } else if (isFertile) {
      bgColor = const Color(0xFFE2F3E6);
      textColor = AppColors.text;
    } else if (isOvulation) {
      bgColor = const Color(0xFFFFF8E1);
      textColor = AppColors.text;
    }

    if (isSelected) {
      border = Border.all(color: AppColors.primary, width: 2);
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDate = date;
          if (!isCurrentMonth) {
            _displayedMonth = DateTime(date.year, date.month, 1);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          shape: BoxShape.circle,
          border: border,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${d.day}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isToday || isSelected || isRecorded ? FontWeight.bold : FontWeight.w500,
                    color: textColor,
                  ),
                ),
                if (isToday)
                  const Text('♡', style: TextStyle(fontSize: 9, color: AppColors.primary, height: 0.8))
                else if (isOvulation)
                  const Text('⭐', style: TextStyle(fontSize: 8, height: 0.8))
                else if (isRecorded)
                  const Text('💧', style: TextStyle(fontSize: 8, height: 0.8)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _legendItem(const Color(0xFFF4A6C6), 'Period'),
          _legendItem(const Color(0xFFE5D5EE), 'Predicted'),
          _legendItem(const Color(0xFFE2F3E6), 'Fertile'),
          _legendItem(const Color(0xFFFFD54F), 'Ovulation', isStar: true),
          _legendItem(Colors.transparent, 'Today', isHeart: true),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isStar = false, bool isHeart = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isHeart ? Border.all(color: AppColors.primary, width: 1.5) : null,
          ),
          child: isStar
              ? const Center(child: Text('⭐', style: TextStyle(fontSize: 7)))
              : isHeart
                  ? const Center(child: Text('♡', style: TextStyle(fontSize: 7, color: AppColors.primary)))
                  : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textMuted, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  // ----- 6. Selected Date Details Card -------------------------------------

  Widget _buildSelectedDateCard() {
    final dateStr = '${_weekdays[_selectedDate.weekday % 7]}, ${_monthsShort[_selectedDate.month - 1]} ${_selectedDate.day}';
    final cycleDay = _calculateCycleDay(_selectedDate);
    final isRecorded = _isRecordedPeriodDay(_selectedDate);
    final isPredicted = _isPredictedPeriodDay(_selectedDate);
    final isFertile = _isFertileWindowDay(_selectedDate);
    final isOvulation = _isOvulationDay(_selectedDate);

    String statusText = 'No period recorded';
    Color statusColor = const Color(0xFF76B98A);
    IconData statusIcon = Icons.check_circle_rounded;

    if (isRecorded) {
      statusText = 'Recorded Period day 💧';
      statusColor = AppColors.primary;
      statusIcon = Icons.water_drop_rounded;
    } else if (isPredicted) {
      statusText = 'Predicted Period day 🌙';
      statusColor = const Color(0xFF9B72DC);
      statusIcon = Icons.auto_awesome_rounded;
    } else if (isOvulation) {
      statusText = 'Estimated Ovulation day ⭐';
      statusColor = Colors.amber.shade800;
      statusIcon = Icons.star_rounded;
    } else if (isFertile) {
      statusText = "You're in your fertile window 💚";
      statusColor = const Color(0xFF76B98A);
      statusIcon = Icons.favorite_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.text,
                ),
              ),
              if (cycleDay != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFDEAF2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Cycle Day $cycleDay',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(statusIcon, color: statusColor, size: 20),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showLogPeriodBottomSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFCE4EE),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.water_drop_rounded, size: 18),
                  label: const Text(
                    'Log Period',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _soon('Symptoms logging'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.text,
                    side: const BorderSide(color: Color(0xFFEADBEE)),
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  icon: const Icon(Icons.favorite_border_rounded, size: 18, color: AppColors.primary),
                  label: const Text(
                    'Log Symptoms',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----- 8. Cycle Overview Card --------------------------------------------

  Widget _buildCycleOverviewCard() {
    final stats = _cycleStats;
    final nextPeriod = stats.nextExpectedPeriodStart;
    final nextPeriodStr = nextPeriod != null
        ? '${nextPeriod.day} ${_monthsShort[nextPeriod.month - 1]}'
        : 'Not available';

    final cycleSourceLabel = stats.observedCycleCount > 0
        ? '${stats.observedCycleCount} observed'
        : 'Onboarding';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Cycle Overview',
                    style: TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _soon('Cycle details'),
                child: const Text(
                  'View Details →',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _overviewStat(
                icon: Icons.calendar_today_rounded,
                value: stats.averageCycleLength != null
                    ? '${stats.averageCycleLength} days'
                    : '--',
                label: 'Avg Cycle ($cycleSourceLabel)',
              ),
              Container(width: 1, height: 35, color: const Color(0xFFEADBEE)),
              _overviewStat(
                icon: Icons.water_drop_rounded,
                value: stats.averagePeriodDuration != null
                    ? '${stats.averagePeriodDuration} days'
                    : '--',
                label: 'Avg Period',
              ),
              Container(width: 1, height: 35, color: const Color(0xFFEADBEE)),
              _overviewStat(
                icon: Icons.favorite_rounded,
                value: nextPeriodStr,
                label: 'Next Period',
              ),
            ],
          ),
          if (stats.shortestCycleLength != null && stats.longestCycleLength != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.show_chart_rounded, size: 15, color: AppColors.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Shortest: ${stats.shortestCycleLength} days • Longest: ${stats.longestCycleLength} days',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (stats.isDelayed) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3E0),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline_rounded, size: 16, color: Colors.orange.shade800),
                  const SizedBox(width: 6),
                  Text(
                    'Period delayed by ${stats.daysDelayed} ${stats.daysDelayed == 1 ? 'day' : 'days'}. Listen to your body 🌸',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _overviewStat({required IconData icon, required String value, required String label}) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.primary),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildInsightCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFAF0F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.period.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: Colors.amber, size: 26),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ovulation is likely in your fertile window',
                  style: TextStyle(
                    color: AppColors.text,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tracking cycle symptoms helps improve future predictions 🌸',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----- 9. Bottom Navigation ----------------------------------------------

  Widget _bottomNav() {
    return LunaBottomNavBar(
      selectedTab: _tab,
      onTabSelected: (i) {
        setState(() => _tab = i);
        if (i == 0) {
          if (Navigator.canPop(context)) {
            Navigator.pop(context, _selectedDate);
          } else {
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
          }
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
          );
        } else if (i > 2) {
          _soon(LunaBottomNavBar.items[i].$2);
        }
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painter for Calendar Header Mascot
// ---------------------------------------------------------------------------

class _LunaCalendarHeaderPainter extends CustomPainter {
  const _LunaCalendarHeaderPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.6, h * 0.5);

    // Sparkles
    _drawSparkle(canvas, Offset(w * 0.15, h * 0.3), 6, const Color(0xFFF8BBD0));
    _drawSparkle(canvas, Offset(w * 0.9, h * 0.2), 7, const Color(0xFFE1BEE7));

    // Crescent Moon
    final moonRadius = h * 0.42;
    final moonPath = Path()
      ..addArc(
        Rect.fromCircle(center: center, radius: moonRadius),
        -math.pi * 0.6,
        math.pi * 1.55,
      )
      ..arcToPoint(
        Offset(
          center.dx + moonRadius * math.cos(-math.pi * 0.6),
          center.dy + moonRadius * math.sin(-math.pi * 0.6),
        ),
        radius: Radius.circular(moonRadius * 0.75),
        clockwise: false,
      );

    final moonPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFFDE7),
          Color(0xFFFFF59D),
          Color(0xFFFFEE58),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: moonRadius));
    canvas.drawPath(moonPath, moonPaint);

    // Face features
    final eyePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;

    final leftEyePath = Path()
      ..addArc(Rect.fromLTWH(center.dx - 16, center.dy - 10, 10, 8), math.pi, -math.pi);
    canvas.drawPath(leftEyePath, eyePaint);

    final rightEyePath = Path()
      ..addArc(Rect.fromLTWH(center.dx + 4, center.dy - 10, 10, 8), math.pi, -math.pi);
    canvas.drawPath(rightEyePath, eyePaint);

    final smilePath = Path()
      ..addArc(Rect.fromLTWH(center.dx - 4, center.dy + 4, 8, 6), 0, math.pi);
    canvas.drawPath(smilePath, eyePaint);

    final blushPaint = Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.55);
    canvas.drawCircle(Offset(center.dx - 14, center.dy + 2), 3.5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 14, center.dy + 2), 3.5, blushPaint);

    // Heart held by Luna
    _drawHeart(canvas, Offset(center.dx + 8, center.dy + 12), 16);
  }

  void _drawHeart(Canvas canvas, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.6);
    path.cubicTo(
      center.dx - size,
      center.dy,
      center.dx - size * 0.5,
      center.dy - size,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.5,
      center.dy - size,
      center.dx + size,
      center.dy,
      center.dx,
      center.dy + size * 0.6,
    );
    final heartPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF80AB), Color(0xFFEC407A)],
      ).createShader(Rect.fromCircle(center: center, radius: size));
    canvas.drawPath(path, heartPaint);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius);
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
