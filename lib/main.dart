import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'core/services/notification_service.dart';
import 'features/onboarding/home_screen.dart';
import 'features/onboarding/cycle_length_duration_screen.dart';
import 'features/onboarding/cycle_setup_screen.dart';
import 'features/onboarding/name_screen.dart';
import 'features/onboarding/notification_preferences_screen.dart';
import 'features/onboarding/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Luna',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: Builder(
        builder: (context) => WelcomeScreen(
          onBegin: () => _openNameScreen(context),
        ),
      ),
    );
  }
}

/// Remembers the cycle choices while the user moves back and forth in
/// onboarding. Null values mean "I'm not sure". (Not saved after app restart.)
CycleInfo _cycleInfo = CycleInfo.initialSelection;

/// Screen 1 -> Screen 2
void _openNameScreen(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NameScreen(
        onContinue: (name) => _openCycleSetup(context, name),
        onSkip: () => _openCycleSetup(context, ''),
      ),
    ),
  );
}

/// Screen 2 -> Screen 3
void _openCycleSetup(BuildContext context, String name) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CycleSetupScreen(
        name: name,
        onContinue: (date) => _openCycleLength(context, name, date),
        onLater: () => _openCycleLength(context, name, null),
      ),
    ),
  );
}

/// Screen 3 -> Screen 4 (Cycle Length & Duration)
void _openCycleLength(BuildContext context, String name, DateTime? lastPeriod) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => CycleLengthDurationScreen(
        initial: _cycleInfo,
        step: 4,
        totalSteps: 5,
        onBack: (info) {
          _cycleInfo = info;
          Navigator.pop(context);
        },
        onNext: (info) {
          _cycleInfo = info;
          _openNotificationPreferences(context, name, lastPeriod, info);
        },
      ),
    ),
  );
}

/// Screen 4 -> Screen 5 (Notification Preferences)
void _openNotificationPreferences(
  BuildContext context,
  String name,
  DateTime? lastPeriod,
  CycleInfo info,
) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => NotificationPreferencesScreen(
        step: 5,
        totalSteps: 5,
        onSave: (prefs) {
          _openHome(context, name, lastPeriod, info);
        },
        onBack: () => Navigator.pop(context),
      ),
    ),
  );
}

/// Last onboarding screen -> Home (clears onboarding from the back stack)
void _openHome(
    BuildContext context,
    String name,
    DateTime? lastPeriod,
    CycleInfo info,
    ) {
  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) => HomeScreen(
        name: name,
        lastPeriodStart: lastPeriod,
        // HomeScreen needs numbers for the wheel. These fallbacks are only
        // display estimates when the user chose "I'm not sure".
        cycleLength: info.cycleLength ?? 28,
        periodLength: info.periodLength ?? 5,
      ),
    ),
        (route) => false,
  );
}