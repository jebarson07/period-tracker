import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

/// What the user told us about their cycle.
///
/// A `null` value means "I'm not sure". It is never replaced by 28 or 5.
@immutable
class CycleInfo {
  const CycleInfo({this.cycleLength, this.periodLength});

  /// Only the *initial selection* shown on the screen, not an assumption.
  static const initialSelection = CycleInfo(cycleLength: 28, periodLength: 5);

  /// Days from the first day of one period to the next, or null if unknown.
  final int? cycleLength;

  /// Days of bleeding in a period, or null if unknown.
  final int? periodLength;

  bool get isCycleLengthKnown => cycleLength != null;
  bool get isPeriodLengthKnown => periodLength != null;

  @override
  bool operator ==(Object other) =>
      other is CycleInfo &&
          other.cycleLength == cycleLength &&
          other.periodLength == periodLength;

  @override
  int get hashCode => Object.hash(cycleLength, periodLength);

  @override
  String toString() =>
      'CycleInfo(cycleLength: $cycleLength, periodLength: $periodLength)';
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Onboarding step 4 of 6: cycle length and period duration.
///
/// * [initial] restores earlier choices when the user comes back to this screen.
/// * [onNext] receives the choices (unknown values are null).
/// * [onBack] receives the current choices so the parent can remember them.
///   If it is null the screen pops itself and returns the [CycleInfo].
class CycleLengthDurationScreen extends StatefulWidget {
  const CycleLengthDurationScreen({
    super.key,
    this.initial = CycleInfo.initialSelection,
    this.step = 4,
    this.totalSteps = 6,
    this.onNext,
    this.onBack,
  });

  final CycleInfo initial;
  final int step;
  final int totalSteps;
  final ValueChanged<CycleInfo>? onNext;
  final ValueChanged<CycleInfo>? onBack;

  @override
  State<CycleLengthDurationScreen> createState() =>
      _CycleLengthDurationScreenState();
}

class _CycleLengthDurationScreenState extends State<CycleLengthDurationScreen>
    with SingleTickerProviderStateMixin {
  static const _cycleQuick = [24, 26, 28, 30, 32];
  static const _periodQuick = [3, 4, 5, 6, 7];

  late int? _cycleLength;
  late int? _periodLength;
  late final AnimationController _intro;

  @override
  void initState() {
    super.initState();
    _cycleLength = widget.initial.cycleLength;
    _periodLength = widget.initial.periodLength;
    _intro = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _intro.dispose();
    super.dispose();
  }

  CycleInfo get _info =>
      CycleInfo(cycleLength: _cycleLength, periodLength: _periodLength);

  bool get _bothUnknown => _cycleLength == null && _periodLength == null;

  void _goBack() {
    final onBack = widget.onBack;
    if (onBack != null) {
      onBack(_info);
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop(_info);
    }
  }

  void _next() {
    final onNext = widget.onNext;
    if (onNext != null) {
      onNext(_info);
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: const Text('The next step is coming soon 🌸'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final buttonWidth = (width * 0.68).clamp(240.0, 360.0);
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(fade);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
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
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Stack(
            children: [
              const Positioned.fill(
                child: IgnorePointer(
                  child: CustomPaint(painter: _DecorPainter()),
                ),
              ),
              SafeArea(
                child: FadeTransition(
                  opacity: fade,
                  child: SlideTransition(
                    position: slide,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
                          child: Column(
                            children: [
                              _TopBar(
                                step: widget.step,
                                totalSteps: widget.totalSteps,
                                onBack: _goBack,
                              ),
                              const SizedBox(height: 14),
                              const _Heading(),
                              const SizedBox(height: 20),
                              _SelectorCard(
                                icon: Icons.calendar_month_outlined,
                                title: 'How long is your average cycle?',
                                description:
                                'This is the number of days from the first '
                                    'day of one period to the next.',
                                sheetTitle: 'Cycle length',
                                value: _cycleLength,
                                quickOptions: _cycleQuick,
                                min: 21,
                                max: 45,
                                onChanged: (v) =>
                                    setState(() => _cycleLength = v),
                                onUnknown: () =>
                                    setState(() => _cycleLength = null),
                              ),
                              const SizedBox(height: 16),
                              _SelectorCard(
                                icon: Icons.water_drop_outlined,
                                title: 'How many days does your period '
                                    'usually last?',
                                description:
                                'This is the number of days you bleed '
                                    'each period.',
                                sheetTitle: 'Period duration',
                                value: _periodLength,
                                quickOptions: _periodQuick,
                                min: 1,
                                max: 10,
                                onChanged: (v) =>
                                    setState(() => _periodLength = v),
                                onUnknown: () =>
                                    setState(() => _periodLength = null),
                              ),
                              const SizedBox(height: 16),
                              _NotSureCard(
                                disabled: _bothUnknown,
                                onTap: () => setState(() {
                                  _cycleLength = null;
                                  _periodLength = null;
                                }),
                              ),
                              const SizedBox(height: 22),
                              _NextButton(width: buttonWidth, onTap: _next),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Top section
// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.step,
    required this.totalSteps,
    required this.onBack,
  });

  final int step;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Tooltip(
              message: 'Back',
              child: Material(
                color: const Color(0xCCFFFFFF),
                shape: const CircleBorder(
                  side: BorderSide(color: Colors.white, width: 1.5),
                ),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: onBack,
                  child: const SizedBox(
                    width: 48,
                    height: 48,
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 32,
                      color: AppColors.text,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: Center(
            child: SizedBox(
              width: 92,
              height: 66,
              child: CustomPaint(painter: _LotusPainter()),
            ),
          ),
        ),
        SizedBox(
          width: 100,
          child: _StepProgress(step: step, totalSteps: totalSteps),
        ),
      ],
    );
  }
}

class _StepProgress extends StatelessWidget {
  const _StepProgress({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Step $step of $totalSteps',
      excludeSemantics: true,
      child: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$step / $totalSteps',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (var i = 0; i < totalSteps; i++)
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      height: 5,
                      margin: EdgeInsets.only(
                        right: i == totalSteps - 1 ? 0 : 3,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3),
                        color: i < step
                            ? AppColors.primary
                            : const Color(0xFFF4C4DC),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'Cycle Length & Duration',
            style: TextStyle(
              fontFamily: 'serif',
              fontSize: 34,
              height: 1.2,
              fontWeight: FontWeight.w500,
              color: AppColors.text,
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Help Luna learn your cycle pattern ✨',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17, color: AppColors.text),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Selector card (used for both cycle length and period duration)
// ---------------------------------------------------------------------------

class _SelectorCard extends StatelessWidget {
  const _SelectorCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.sheetTitle,
    required this.value,
    required this.quickOptions,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.onUnknown,
  });

  final IconData icon;
  final String title;
  final String description;
  final String sheetTitle;

  /// Selected number of days, or null for "I'm not sure".
  final int? value;
  final List<int> quickOptions;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final VoidCallback onUnknown;

  Future<void> _openSheet(BuildContext context) async {
    final picked = await _showNumberSheet(
      context,
      title: sheetTitle,
      min: min,
      max: max,
      selected: value,
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: BoxDecoration(
        color: const Color(0xCCFFFFFF),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF3D3E6), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1AD4558C),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBD3E3),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 30, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'serif',
                        fontSize: 21,
                        height: 1.2,
                        fontWeight: FontWeight.w500,
                        color: AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.35,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _ValueField(
            value: value,
            label: '$title ${value == null ? 'Not sure yet' : '$value days'}. '
                'Tap to choose a different number.',
            onTap: () => _openSheet(context),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (var i = 0; i < quickOptions.length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _QuickChip(
                    label: '${quickOptions[i]}',
                    semanticLabel: '${quickOptions[i]} days',
                    selected: value == quickOptions[i],
                    onTap: () => onChanged(quickOptions[i]),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          _UnknownToggle(selected: value == null, onTap: onUnknown),
        ],
      ),
    );
  }
}

class _ValueField extends StatelessWidget {
  const _ValueField({
    required this.value,
    required this.label,
    required this.onTap,
  });

  final int? value;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final known = value != null;
    return Semantics(
      button: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: const Color(0x80F3E3F2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: const BorderSide(color: Color(0xFFEBD3E4), width: 1.2),
        ),
        child: InkWell(
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          onTap: onTap,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: known
                          ? Row(
                        key: ValueKey(value),
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$value',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              color: AppColors.text,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            value == 1 ? 'day' : 'days',
                            style: const TextStyle(
                              fontSize: 18,
                              color: AppColors.text,
                            ),
                          ),
                        ],
                      )
                          : const Text(
                        "I'm not sure",
                        key: ValueKey('unknown'),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  width: 48,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 30,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({
    required this.label,
    required this.semanticLabel,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String semanticLabel;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.text;
    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      excludeSemantics: true,
      child: Material(
        color: selected ? AppColors.primary : const Color(0xB3FFFFFF),
        shape: StadiumBorder(
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.lavenderSoft,
            width: 1.2,
          ),
        ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                        color: fg,
                      ),
                    ),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      Icon(Icons.check_rounded, size: 18, color: fg),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Per-card "I'm not sure". Choosing a number again leaves the unknown state.
class _UnknownToggle extends StatelessWidget {
  const _UnknownToggle({required this.selected, required this.onTap});

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: "I'm not sure",
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: selected ? null : onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 22,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  "I'm not sure",
                  style: TextStyle(
                    fontSize: 15.5,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// "Not sure?" help card and Next button
// ---------------------------------------------------------------------------

class _NotSureCard extends StatelessWidget {
  const _NotSureCard({required this.onTap, required this.disabled});

  final VoidCallback onTap;

  /// True when both values are already unknown.
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xCCE9DDF9),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 30,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Not sure?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.text,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Luna can learn from your future period records.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.3,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: disabled ? null : onTap,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(96, 48),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              shape: const StadiumBorder(),
              foregroundColor: AppColors.primary,
              backgroundColor: const Color(0x99FFFFFF),
              side: BorderSide(
                color: disabled ? AppColors.lavenderSoft : AppColors.lavender,
                width: 1.4,
              ),
              textStyle: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text("I'm not sure"),
          ),
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  const _NextButton({required this.width, required this.onTap});

  final double width;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          boxShadow: const [
            BoxShadow(
              color: Color(0x5598577F),
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: onTap,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next'),
              SizedBox(width: 10),
              Icon(Icons.arrow_forward_rounded, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Number picker bottom sheet (full range)
// ---------------------------------------------------------------------------

/// Returns the chosen number, or null if the sheet was dismissed.
Future<int?> _showNumberSheet(
    BuildContext context, {
      required String title,
      required int min,
      required int max,
      required int? selected,
    }) {
  const itemHeight = 56.0;
  final count = max - min + 1;
  final maxHeight = MediaQuery.sizeOf(context).height * 0.5;
  final listHeight = math.min(count * itemHeight, maxHeight);
  final firstVisible = selected == null ? 0 : selected - min;
  final controller = ScrollController(
    initialScrollOffset: math.max(0, (firstVisible - 2) * itemHeight),
  );

  return showModalBottomSheet<int>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) {
      return Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFF7FB),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.lavenderSoft,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'serif',
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    color: AppColors.text,
                  ),
                ),
              ),
              SizedBox(
                height: listHeight,
                child: ListView.builder(
                  controller: controller,
                  itemExtent: itemHeight,
                  itemCount: count,
                  itemBuilder: (context, index) {
                    final n = min + index;
                    final isSelected = n == selected;
                    return Semantics(
                      button: true,
                      selected: isSelected,
                      label: n == 1 ? '1 day' : '$n days',
                      excludeSemantics: true,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Material(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => Navigator.of(sheetContext).pop(n),
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    n == 1 ? '$n day' : '$n days',
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? Colors.white
                                          : AppColors.text,
                                    ),
                                  ),
                                  if (isSelected) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.check_rounded,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      );
    },
  ).whenComplete(controller.dispose);
}

// ---------------------------------------------------------------------------
// Decoration painters (drawn in code, like the other Luna screens)
// ---------------------------------------------------------------------------

double _rad(double deg) => deg * math.pi / 180;

Path _leafPath(double len, double wid) {
  return Path()
    ..moveTo(0, 0)
    ..cubicTo(wid, -len * 0.3, wid * 0.6, -len * 0.8, 0, -len)
    ..cubicTo(-wid * 0.6, -len * 0.8, -wid, -len * 0.3, 0, 0)
    ..close();
}

void _drawShape(
    Canvas canvas,
    Path path,
    Offset at,
    double angle,
    Paint paint,
    ) {
  canvas.save();
  canvas.translate(at.dx, at.dy);
  canvas.rotate(angle);
  canvas.drawPath(path, paint);
  canvas.restore();
}

void _sparkle(Canvas canvas, Offset o, double r, Paint paint) {
  final path = Path()
    ..moveTo(o.dx, o.dy - r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx + r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy + r)
    ..quadraticBezierTo(o.dx, o.dy, o.dx - r, o.dy)
    ..quadraticBezierTo(o.dx, o.dy, o.dx, o.dy - r)
    ..close();
  canvas.drawPath(path, paint);
}

/// Small lotus shown at the top of the screen.
class _LotusPainter extends CustomPainter {
  const _LotusPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final base = Offset(size.width / 2, size.height);
    final h = size.height;
    final w = size.width * 0.2;

    // angle (deg), length factor, bottom colour, top colour
    const petals = <(double, double, Color, Color)>[
      (-64, 0.70, Color(0xFFF7B9D2), Color(0xFFEFA0C2)),
      (64, 0.70, Color(0xFFF7B9D2), Color(0xFFEFA0C2)),
      (-34, 0.90, Color(0xFFF4A6C6), Color(0xFFE879A8)),
      (34, 0.90, Color(0xFFF4A6C6), Color(0xFFE879A8)),
      (0, 1.0, Color(0xFFF9C4DA), Color(0xFFEA7FAE)),
    ];

    for (final p in petals) {
      final len = h * p.$2;
      final paint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [p.$3, p.$4],
        ).createShader(Rect.fromLTWH(-w, -len, w * 2, len));
      _drawShape(canvas, _leafPath(len, w), base, _rad(p.$1), paint);
      canvas.save();
      canvas.translate(base.dx, base.dy);
      canvas.rotate(_rad(p.$1));
      canvas.drawPath(
        _leafPath(len, w),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1
          ..color = const Color(0x99FFFFFF),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Soft leaves, sparkles and flowers in the background.
class _DecorPainter extends CustomPainter {
  const _DecorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final lavenderLeaf = Paint()..color = const Color(0x55C9A8E6);
    final pinkLeaf = Paint()..color = const Color(0x44E9A6C9);
    final sparkle = Paint()..color = const Color(0xFFFBC9A5);

    // Leaves at the left and right edges, near the title
    _drawShape(canvas, _leafPath(70, 18), Offset(-6, h * 0.17), _rad(55),
        lavenderLeaf);
    _drawShape(canvas, _leafPath(52, 14), Offset(-6, h * 0.20), _rad(95),
        pinkLeaf);
    _drawShape(canvas, _leafPath(70, 18), Offset(w + 6, h * 0.17), _rad(-55),
        lavenderLeaf);
    _drawShape(canvas, _leafPath(52, 14), Offset(w + 6, h * 0.20), _rad(-95),
        pinkLeaf);

    // Sparkles
    _sparkle(canvas, Offset(w * 0.66, h * 0.07), 9, sparkle);
    _sparkle(canvas, Offset(w * 0.70, h * 0.09), 5, sparkle);
    _sparkle(canvas, Offset(w * 0.32, h * 0.10), 6, sparkle);

    // Flowers in the bottom corners
    _flower(canvas, Offset(w * 0.12, h * 0.925), Offset(w * 0.02, h), 1);
    _flower(canvas, Offset(w * 0.88, h * 0.935), Offset(w * 0.98, h), -1);
  }

  void _flower(Canvas canvas, Offset head, Offset stemBase, double side) {
    canvas.drawPath(
      Path()
        ..moveTo(stemBase.dx, stemBase.dy)
        ..quadraticBezierTo(
          (stemBase.dx + head.dx) / 2 - side * 6,
          (stemBase.dy + head.dy) / 2 + 6,
          head.dx,
          head.dy,
        ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0x66B9A0DC),
    );

    final stemLeaf = Paint()..color = const Color(0x55C9A8E6);
    _drawShape(canvas, _leafPath(34, 9), head.translate(side * 8, 34),
        _rad(side * 60), stemLeaf);
    _drawShape(canvas, _leafPath(28, 8), head.translate(side * -2, 46),
        _rad(side * -50), stemLeaf);

    final petal = Paint()..color = const Color(0x99F4A6C6);
    for (var i = 0; i < 5; i++) {
      _drawShape(canvas, _leafPath(26, 11), head, _rad(i * 72.0), petal);
    }
    canvas.drawCircle(head, 4, Paint()..color = const Color(0xFFFBD8C6));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}