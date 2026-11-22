import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/app_colors.dart';
import '../../core/services/notification_service.dart';

// ---------------------------------------------------------------------------
// Model & Persistence
// ---------------------------------------------------------------------------

/// Preference data model for Luna notifications.
@immutable
class NotificationPreferencesModel {
  const NotificationPreferencesModel({
    this.notificationsEnabled = true,
    this.language = 'tanglish',
    this.personality = 'funny_caring',
    this.prePeriodReminderEnabled = true,
    this.periodCheckInsEnabled = true,
    this.notificationsPerDay = 4,
    this.selectedNotificationTimes = const [
      TimeOfDay(hour: 8, minute: 0),
      TimeOfDay(hour: 13, minute: 0),
      TimeOfDay(hour: 18, minute: 0),
      TimeOfDay(hour: 21, minute: 0),
    ],
    this.discreetNotifications = false,
  });

  final bool notificationsEnabled;
  final String language; // 'english', 'tanglish', 'tamil'
  final String personality; // 'funny_caring', 'cute_friendly', 'gentle_supportive'
  final bool prePeriodReminderEnabled;
  final bool periodCheckInsEnabled;
  final int notificationsPerDay; // 1, 2, 3, 4
  final List<TimeOfDay> selectedNotificationTimes;
  final bool discreetNotifications;

  NotificationPreferencesModel copyWith({
    bool? notificationsEnabled,
    String? language,
    String? personality,
    bool? prePeriodReminderEnabled,
    bool? periodCheckInsEnabled,
    int? notificationsPerDay,
    List<TimeOfDay>? selectedNotificationTimes,
    bool? discreetNotifications,
  }) {
    return NotificationPreferencesModel(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
      personality: personality ?? this.personality,
      prePeriodReminderEnabled:
          prePeriodReminderEnabled ?? this.prePeriodReminderEnabled,
      periodCheckInsEnabled:
          periodCheckInsEnabled ?? this.periodCheckInsEnabled,
      notificationsPerDay: notificationsPerDay ?? this.notificationsPerDay,
      selectedNotificationTimes:
          selectedNotificationTimes ?? this.selectedNotificationTimes,
      discreetNotifications:
          discreetNotifications ?? this.discreetNotifications,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'notificationsEnabled': notificationsEnabled,
      'language': language,
      'personality': personality,
      'prePeriodReminderEnabled': prePeriodReminderEnabled,
      'periodCheckInsEnabled': periodCheckInsEnabled,
      'notificationsPerDay': notificationsPerDay,
      'selectedNotificationTimes': selectedNotificationTimes
          .map((t) => '${t.hour}:${t.minute}')
          .toList(),
      'discreetNotifications': discreetNotifications,
    };
  }
}

/// In-memory & local repository for notification preferences.
class NotificationPreferencesRepository {
  NotificationPreferencesRepository._();
  static final NotificationPreferencesRepository instance =
      NotificationPreferencesRepository._();

  NotificationPreferencesModel _current = const NotificationPreferencesModel();

  NotificationPreferencesModel get preferences => _current;

  void save(NotificationPreferencesModel newPrefs) {
    _current = newPrefs;
  }
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------

/// Onboarding Step 5: Notification Preferences Screen.
class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({
    super.key,
    this.step = 5,
    this.totalSteps = 5,
    this.initial,
    this.onSave,
    this.onBack,
  });

  final int step;
  final int totalSteps;
  final NotificationPreferencesModel? initial;
  final ValueChanged<NotificationPreferencesModel>? onSave;
  final VoidCallback? onBack;

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen>
    with SingleTickerProviderStateMixin {
  late NotificationPreferencesModel _prefs;
  late final AnimationController _intro;

  // Default time slot reference templates
  static const _defaultTimes = [
    TimeOfDay(hour: 8, minute: 0), // Morning
    TimeOfDay(hour: 13, minute: 0), // Afternoon
    TimeOfDay(hour: 18, minute: 0), // Evening
    TimeOfDay(hour: 21, minute: 0), // Night
  ];

  @override
  void initState() {
    super.initState();
    _prefs = widget.initial ?? NotificationPreferencesRepository.instance.preferences;
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

  void _handleMasterSwitch(bool value) {
    setState(() {
      _prefs = _prefs.copyWith(notificationsEnabled: value);
    });
  }

  void _handleLanguageSelect(String lang) {
    setState(() {
      _prefs = _prefs.copyWith(language: lang);
    });
  }

  void _handlePersonalitySelect(String persona) {
    setState(() {
      _prefs = _prefs.copyWith(personality: persona);
    });
  }

  void _handlePrePeriodSwitch(bool value) {
    setState(() {
      _prefs = _prefs.copyWith(prePeriodReminderEnabled: value);
    });
  }

  void _handlePeriodCheckInsSwitch(bool value) {
    setState(() {
      _prefs = _prefs.copyWith(periodCheckInsEnabled: value);
    });
  }

  void _handleFrequencyChange(int count) {
    final currentTimes = List<TimeOfDay>.from(_prefs.selectedNotificationTimes);
    List<TimeOfDay> newTimes;

    if (currentTimes.length >= count) {
      newTimes = currentTimes.sublist(0, count);
    } else {
      newTimes = List<TimeOfDay>.from(currentTimes);
      for (int i = currentTimes.length; i < count; i++) {
        final fallback = _defaultTimes[i % _defaultTimes.length];
        if (!newTimes.contains(fallback)) {
          newTimes.add(fallback);
        } else {
          // adjust minute if duplicate
          newTimes.add(TimeOfDay(hour: (fallback.hour + 1) % 24, minute: fallback.minute));
        }
      }
    }

    setState(() {
      _prefs = _prefs.copyWith(
        notificationsPerDay: count,
        selectedNotificationTimes: newTimes,
      );
    });
  }

  void _toggleOrEditTimeSlot(int index) async {
    final times = List<TimeOfDay>.from(_prefs.selectedNotificationTimes);
    if (index < times.length) {
      // Pick custom time for existing slot
      final picked = await showTimePicker(
        context: context,
        initialTime: times[index],
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: Colors.white,
                surface: Colors.white,
                onSurface: AppColors.text,
              ),
            ),
            child: child!,
          );
        },
      );
      if (picked != null) {
        times[index] = picked;
        setState(() {
          _prefs = _prefs.copyWith(selectedNotificationTimes: times);
        });
      }
    } else {
      // If user taps an unselected slot to select it
      if (times.length < _prefs.notificationsPerDay) {
        times.add(_defaultTimes[index % _defaultTimes.length]);
        setState(() {
          _prefs = _prefs.copyWith(selectedNotificationTimes: times);
        });
      } else {
        // Swap or replace slot
        times[_prefs.notificationsPerDay - 1] = _defaultTimes[index % _defaultTimes.length];
        setState(() {
          _prefs = _prefs.copyWith(selectedNotificationTimes: times);
        });
      }
    }
  }

  void _handlePrivacySwitch(bool value) {
    setState(() {
      _prefs = _prefs.copyWith(discreetNotifications: value);
    });
  }

  void _savePreferences() {
    // Validate frequency vs selected slots
    if (_prefs.periodCheckInsEnabled &&
        _prefs.selectedNotificationTimes.length != _prefs.notificationsPerDay) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Please select exactly ${_prefs.notificationsPerDay} notification time slots 💕',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
          ),
        );
      return;
    }

    // Save to repository
    NotificationPreferencesRepository.instance.save(_prefs);

    // Trigger instant native notification on device if enabled
    if (_prefs.notificationsEnabled) {
      NotificationService.instance.triggerPreferencesSavedNotification(_prefs);
    }

    // Show friendly confirmation & permission explanation if enabled
    if (_prefs.notificationsEnabled) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Preferences saved! Luna will remind you at your preferred times 💗',
            ),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primary,
            duration: Duration(seconds: 2),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Preferences saved! Notifications are currently off.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.textMuted,
          ),
        );
    }

    widget.onSave?.call(_prefs);
  }

  void _goBack() {
    if (widget.onBack != null) {
      widget.onBack!();
    } else if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fade = CurvedAnimation(parent: _intro, curve: Curves.easeOut);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.03),
      end: Offset.zero,
    ).animate(fade);

    final isMasterEnabled = _prefs.notificationsEnabled;

    return PopScope(
      canPop: true,
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
                        constraints: const BoxConstraints(maxWidth: 540),
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _TopBar(
                                step: widget.step,
                                totalSteps: widget.totalSteps,
                                onBack: _goBack,
                              ),
                              const SizedBox(height: 12),
                              const _HeaderMascot(),
                              const SizedBox(height: 20),
                              _MasterSwitchCard(
                                enabled: isMasterEnabled,
                                onChanged: _handleMasterSwitch,
                              ),
                              const SizedBox(height: 16),
                              AnimatedOpacity(
                                opacity: isMasterEnabled ? 1.0 : 0.45,
                                duration: const Duration(milliseconds: 250),
                                child: IgnorePointer(
                                  ignoring: !isMasterEnabled,
                                  child: Column(
                                    children: [
                                      _LanguageSelectionCard(
                                        selected: _prefs.language,
                                        onSelect: _handleLanguageSelect,
                                      ),
                                      const SizedBox(height: 16),
                                      _PersonalityCard(
                                        selected: _prefs.personality,
                                        onSelect: _handlePersonalitySelect,
                                      ),
                                      const SizedBox(height: 16),
                                      _BeforePeriodCard(
                                        enabled: _prefs.prePeriodReminderEnabled,
                                        onChanged: _handlePrePeriodSwitch,
                                      ),
                                      const SizedBox(height: 16),
                                      _DuringPeriodCard(
                                        enabled: _prefs.periodCheckInsEnabled,
                                        onChanged: _handlePeriodCheckInsSwitch,
                                        frequency: _prefs.notificationsPerDay,
                                        onFrequencyChanged: _handleFrequencyChange,
                                        selectedTimes:
                                            _prefs.selectedNotificationTimes,
                                        onTapTimeSlot: _toggleOrEditTimeSlot,
                                      ),
                                      const SizedBox(height: 16),
                                      _PrivacyCard(
                                        discreet: _prefs.discreetNotifications,
                                        onChanged: _handlePrivacySwitch,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              _SaveButton(
                                onSave: _savePreferences,
                              ),
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
// Header Components
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Material(
          color: Colors.white,
          shape: const CircleBorder(),
          elevation: 1,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onBack,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.text,
                size: 26,
              ),
            ),
          ),
        ),
        Text(
          'Step $step / $totalSteps',
          style: const TextStyle(
            color: AppColors.primary,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _HeaderMascot extends StatelessWidget {
  const _HeaderMascot();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 150,
          width: 220,
          child: CustomPaint(
            painter: const _LunaMascotPainter(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              "Let's stay in touch! ",
              style: TextStyle(
                color: AppColors.text,
                fontSize: 26,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              "🌙",
              style: TextStyle(fontSize: 24),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Luna will remind you, support you and make your period days easier.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Card 1: Master Notification Switch
// ---------------------------------------------------------------------------

class _MasterSwitchCard extends StatelessWidget {
  const _MasterSwitchCard({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFDE8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_active_rounded,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Enable Period Notifications',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 16.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Get helpful reminders from Luna',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13.5,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.9,
            child: Switch.adaptive(
              value: enabled,
              activeTrackColor: AppColors.period,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card 2: Language Selection
// ---------------------------------------------------------------------------

class _LanguageSelectionCard extends StatelessWidget {
  const _LanguageSelectionCard({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Choose Your Language',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'How should Luna talk to you?',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  title: '🇬🇧 English',
                  subtitle: '“Hey bestie! Take care of yourself!”',
                  isSelected: selected == 'english',
                  onTap: () => onSelect('english'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionCard(
                  title: '🥰 Tanglish',
                  subtitle: '“Hey girl! Pain ah? Konjam rest edu!”',
                  isSelected: selected == 'tanglish',
                  onTap: () => onSelect('tanglish'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionCard(
                  title: '🕜 தமிழ்',
                  subtitle: '“ஹே பெஸ்டி! கொஞ்சம் ஓய்வெடு!”',
                  isSelected: selected == 'tamil',
                  onTap: () => onSelect('tamil'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card 3: Personality
// ---------------------------------------------------------------------------

class _PersonalityCard extends StatelessWidget {
  const _PersonalityCard({
    required this.selected,
    required this.onSelect,
  });

  final String selected;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Luna's Personality",
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Pick her vibe!',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _OptionCard(
                  title: '😂 Funny & Caring',
                  subtitle: '“Girl, uterus drama ah? Take care da!”',
                  isSelected: selected == 'funny_caring',
                  onTap: () => onSelect('funny_caring'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionCard(
                  title: '🥰 Cute & Friendly',
                  subtitle: '“Sending you a little hug!”',
                  isSelected: selected == 'cute_friendly',
                  onTap: () => onSelect('cute_friendly'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _OptionCard(
                  title: '🌙 Gentle & Supportive',
                  subtitle: '“Listen to your body.”',
                  isSelected: selected == 'gentle_supportive',
                  onTap: () => onSelect('gentle_supportive'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Card 4: Before Your Period
// ---------------------------------------------------------------------------

class _BeforePeriodCard extends StatelessWidget {
  const _BeforePeriodCard({
    required this.enabled,
    required this.onChanged,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Before Your Period',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Get a 2-day advance reminder',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: enabled,
                  activeTrackColor: AppColors.period,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFAF0F6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.period.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: CustomPaint(painter: _MiniLunaPainter()),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      '“Psst bestie! Your period may arrive in 2 days. Keep a pad in your bag! 💗”',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 12.5,
                        height: 1.3,
                        fontWeight: FontWeight.w500,
                      ),
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
}

// ---------------------------------------------------------------------------
// Card 5: During Your Period
// ---------------------------------------------------------------------------

class _DuringPeriodCard extends StatelessWidget {
  const _DuringPeriodCard({
    required this.enabled,
    required this.onChanged,
    required this.frequency,
    required this.onFrequencyChanged,
    required this.selectedTimes,
    required this.onTapTimeSlot,
  });

  final bool enabled;
  final ValueChanged<bool> onChanged;
  final int frequency;
  final ValueChanged<int> onFrequencyChanged;
  final List<TimeOfDay> selectedTimes;
  final ValueChanged<int> onTapTimeSlot;

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Color(0xFFFDE8F1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'During Your Period',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Receive daily check-ins (1–4 messages per day)',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch.adaptive(
                  value: enabled,
                  activeTrackColor: AppColors.period,
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
          if (enabled) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'How many notifications per day?',
                    style: TextStyle(
                      color: AppColors.text,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(4, (i) {
                    final num = i + 1;
                    final isSelected = num == frequency;
                    return Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: GestureDetector(
                        onTap: () => onFrequencyChanged(num),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFFCE4EE)
                                : const Color(0xFFFAFAFA),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : const Color(0xFFE5D5E2),
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (isSelected) ...[
                                const Icon(
                                  Icons.check_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                '$num',
                                style: TextStyle(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.text,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDE8F1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.access_time_filled_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Preferred Times',
                      style: TextStyle(
                        color: AppColors.text,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'When should Luna notify you?',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _TimeSlotTile(
                  title: 'Morning',
                  icon: Icons.wb_twilight_rounded,
                  timeText: selectedTimes.isNotEmpty
                      ? _formatTime(selectedTimes[0])
                      : '8:00 AM',
                  isSelected: selectedTimes.isNotEmpty,
                  onTap: () => onTapTimeSlot(0),
                ),
                const SizedBox(width: 6),
                _TimeSlotTile(
                  title: 'Afternoon',
                  icon: Icons.wb_sunny_rounded,
                  timeText: selectedTimes.length >= 2
                      ? _formatTime(selectedTimes[1])
                      : '1:00 PM',
                  isSelected: selectedTimes.length >= 2,
                  onTap: () => onTapTimeSlot(1),
                ),
                const SizedBox(width: 6),
                _TimeSlotTile(
                  title: 'Evening',
                  icon: Icons.wb_cloudy_rounded,
                  timeText: selectedTimes.length >= 3
                      ? _formatTime(selectedTimes[2])
                      : '6:00 PM',
                  isSelected: selectedTimes.length >= 3,
                  onTap: () => onTapTimeSlot(3 > frequency ? frequency - 1 : 2),
                ),
                const SizedBox(width: 6),
                _TimeSlotTile(
                  title: 'Night',
                  icon: Icons.nightlight_round,
                  timeText: selectedTimes.length >= 4
                      ? _formatTime(selectedTimes[3])
                      : '9:00 PM',
                  isSelected: selectedTimes.length >= 4,
                  onTap: () => onTapTimeSlot(4 > frequency ? frequency - 1 : 3),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _TimeSlotTile extends StatelessWidget {
  const _TimeSlotTile({
    required this.title,
    required this.icon,
    required this.timeText,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final String timeText;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFFDEAF2)
                : const Color(0xFFF9F6F8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppColors.period.withValues(alpha: 0.8)
                  : const Color(0xFFEADBEE),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: isSelected ? AppColors.text : AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                timeText,
                style: TextStyle(
                  color: isSelected ? AppColors.primary : AppColors.textMuted,
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
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
// Card 6: Privacy
// ---------------------------------------------------------------------------

class _PrivacyCard extends StatelessWidget {
  const _PrivacyCard({
    required this.discreet,
    required this.onChanged,
  });

  final bool discreet;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Color(0xFFFDE8F1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Privacy',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Discreet Notifications',
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                const Text(
                  'Hide period-related wording on lock screen',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch.adaptive(
              value: discreet,
              activeTrackColor: AppColors.period,
              onChanged: onChanged,
            ),
          ),
          const SizedBox(width: 6),
          // Preview container
          Container(
            width: 140,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Preview:',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.85),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CustomPaint(painter: _MiniLunaPainter()),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'Luna',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.text,
                                  ),
                                ),
                                Text(
                                  'now',
                                  style: TextStyle(
                                    fontSize: 9,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              discreet
                                  ? 'Luna has a reminder 🌸'
                                  : 'Hey bestie! Take care 💕',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 9.5,
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
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared Base Components
// ---------------------------------------------------------------------------

class _BaseCard extends StatelessWidget {
  const _BaseCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: child,
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFDF0F6)
                  : const Color(0xFFFAFAFA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.period
                    : const Color(0xFFEADBEE),
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.text,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
          if (isSelected)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  color: AppColors.period,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  size: 12,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.onSave});

  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFE882B4), Color(0xFFD66AA0)],
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE882B4).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: onSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Save My Preferences ',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '💕',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'You can change these anytime',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Custom Painters
// ---------------------------------------------------------------------------

/// Custom painter for Luna crescent moon mascot with pink flower and heart.
class _LunaMascotPainter extends CustomPainter {
  const _LunaMascotPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w * 0.48, h * 0.48);

    // 1. Floating background sparkles and hearts
    _drawSparkle(canvas, Offset(w * 0.18, h * 0.25), 6, const Color(0xFFF8BBD0));
    _drawSparkle(canvas, Offset(w * 0.82, h * 0.28), 7, const Color(0xFFE1BEE7));
    _drawSparkle(canvas, Offset(w * 0.88, h * 0.70), 5, const Color(0xFFF8BBD0));
    _drawMiniHeart(canvas, Offset(w * 0.76, h * 0.15), 8, const Color(0xFFF48FB1));
    _drawMiniHeart(canvas, Offset(w * 0.22, h * 0.72), 7, const Color(0xFFF06292));

    // 2. Crescent Moon Body
    final moonRadius = h * 0.38;
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

    // Moon gradient fill (cream pastel yellow)
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

    // Soft moon outline
    final outlinePaint = Paint()
      ..color = const Color(0xFFFBC02D).withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;
    canvas.drawPath(moonPath, outlinePaint);

    // 3. Face features (Sleeping / smiling eyes & blush)
    final eyePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    // Left eye (closed happy curve)
    final leftEyePath = Path()
      ..addArc(
        Rect.fromLTWH(center.dx - 18, center.dy - 12, 12, 10),
        math.pi,
        -math.pi,
      );
    canvas.drawPath(leftEyePath, eyePaint);

    // Right eye
    final rightEyePath = Path()
      ..addArc(
        Rect.fromLTWH(center.dx + 4, center.dy - 12, 12, 10),
        math.pi,
        -math.pi,
      );
    canvas.drawPath(rightEyePath, eyePaint);

    // Smile
    final smilePath = Path()
      ..addArc(
        Rect.fromLTWH(center.dx - 5, center.dy + 4, 10, 8),
        0,
        math.pi,
      );
    canvas.drawPath(smilePath, eyePaint);

    // Cheeks (blush)
    final blushPaint = Paint()..color = const Color(0xFFFF80AB).withValues(alpha: 0.55);
    canvas.drawCircle(Offset(center.dx - 18, center.dy + 2), 4.5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 18, center.dy + 2), 4.5, blushPaint);

    // 4. Head flower decoration
    _drawFlower(canvas, Offset(center.dx - 22, center.dy - 28));

    // 5. Big Pink Heart Luna is holding
    _drawBigHeart(canvas, Offset(center.dx + 10, center.dy + 12), 22);
  }

  void _drawFlower(Canvas canvas, Offset center) {
    final petalPaint = Paint()..color = const Color(0xFFF48FB1);
    final centerPaint = Paint()..color = const Color(0xFFFFEB3B);

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * math.pi / 5);
      final petalCenter = Offset(
        center.dx + 6 * math.cos(angle),
        center.dy + 6 * math.sin(angle),
      );
      canvas.drawCircle(petalCenter, 4.5, petalPaint);
    }
    canvas.drawCircle(center, 4, centerPaint);
  }

  void _drawBigHeart(Canvas canvas, Offset center, double size) {
    final path = Path();
    path.moveTo(center.dx, center.dy + size * 0.7);
    path.cubicTo(
      center.dx - size * 1.1,
      center.dy + size * 0.1,
      center.dx - size * 0.7,
      center.dy - size * 0.8,
      center.dx,
      center.dy - size * 0.3,
    );
    path.cubicTo(
      center.dx + size * 0.7,
      center.dy - size * 0.8,
      center.dx + size * 1.1,
      center.dy + size * 0.1,
      center.dx,
      center.dy + size * 0.7,
    );

    final heartPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFFF80AB), Color(0xFFEC407A)],
      ).createShader(Rect.fromCircle(center: center, radius: size));
    canvas.drawPath(path, heartPaint);

    // Heart highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromLTWH(center.dx - size * 0.5, center.dy - size * 0.5, size * 0.5, size * 0.5),
      math.pi * 0.8,
      math.pi * 0.6,
      false,
      highlightPaint,
    );
  }

  void _drawMiniHeart(Canvas canvas, Offset center, double size, Color color) {
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
    canvas.drawPath(path, Paint()..color = color);
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

/// Mini Luna moon painter for previews.
class _MiniLunaPainter extends CustomPainter {
  const _MiniLunaPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(radius, radius);

    final moonPaint = Paint()..color = const Color(0xFFFFF176);
    canvas.drawCircle(center, radius * 0.8, moonPaint);

    final eyePaint = Paint()
      ..color = const Color(0xFF5D4037)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawArc(
      Rect.fromLTWH(center.dx - 4, center.dy - 3, 4, 4),
      0,
      math.pi,
      false,
      eyePaint,
    );
    canvas.drawArc(
      Rect.fromLTWH(center.dx + 1, center.dy - 3, 4, 4),
      0,
      math.pi,
      false,
      eyePaint,
    );

    final blushPaint = Paint()..color = const Color(0xFFFF80AB);
    canvas.drawCircle(Offset(center.dx - 4, center.dy + 2), 1.5, blushPaint);
    canvas.drawCircle(Offset(center.dx + 4, center.dy + 2), 1.5, blushPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Floating petals and sparkles background painter.
class _DecorPainter extends CustomPainter {
  const _DecorPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final paint1 = Paint()..color = const Color(0x22F48FB1);
    final paint2 = Paint()..color = const Color(0x22CE93D8);

    canvas.drawCircle(Offset(w * 0.1, h * 0.15), 18, paint1);
    canvas.drawCircle(Offset(w * 0.9, h * 0.25), 24, paint2);
    canvas.drawCircle(Offset(w * 0.85, h * 0.8), 20, paint1);
    canvas.drawCircle(Offset(w * 0.12, h * 0.75), 16, paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
