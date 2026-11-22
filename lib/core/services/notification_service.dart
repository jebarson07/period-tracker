import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../features/onboarding/notification_preferences_screen.dart';

/// Service for managing native Android notifications using flutter_local_notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Initialize notification channels and settings.
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await _plugin.initialize(settings);

    // Create high importance channel for Luna
    const androidChannel = AndroidNotificationChannel(
      'luna_reminders_channel',
      'Luna Reminders',
      description: 'Luna period reminders and supportive check-ins',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(androidChannel);
    }

    _initialized = true;
  }

  /// Request POST_NOTIFICATIONS permission (Android 13+)
  Future<bool?> requestPermission() async {
    final androidImplementation =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestNotificationsPermission();
    }
    return true;
  }

  /// Show an immediate test / confirmation notification on device
  Future<void> showNotification({
    required String title,
    required String body,
    int id = 0,
  }) async {
    await init();

    const androidDetails = AndroidNotificationDetails(
      'luna_reminders_channel',
      'Luna Reminders',
      channelDescription: 'Luna period reminders and supportive check-ins',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Luna',
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(''),
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id,
      title,
      body,
      details,
    );
  }

  /// Triggers notification based on user's saved preferences
  Future<void> triggerPreferencesSavedNotification(
    NotificationPreferencesModel prefs,
  ) async {
    if (!prefs.notificationsEnabled) return;

    await requestPermission();

    final title = _getTitle(prefs);
    final message = _getMessage(prefs);

    await showNotification(
      id: 101,
      title: title,
      body: message,
    );
  }

  String _getTitle(NotificationPreferencesModel prefs) {
    if (prefs.discreetNotifications) {
      return 'Luna 🌸';
    }
    return 'Luna 🌙';
  }

  String _getMessage(NotificationPreferencesModel prefs) {
    if (prefs.discreetNotifications) {
      return 'Luna has a little reminder for you 🌸';
    }

    // Language & Personality combinations
    if (prefs.language == 'tanglish') {
      switch (prefs.personality) {
        case 'funny_caring':
          return 'Girl, uterus drama ah? Take care da! 💗';
        case 'cute_friendly':
          return 'Hey girl! Pain ah? Konjam rest edu ma! 🥰';
        case 'gentle_supportive':
          return 'Listen to your body. Take it easy ma! 🌙';
      }
    } else if (prefs.language == 'tamil') {
      switch (prefs.personality) {
        case 'funny_caring':
          return 'ஹே பெஸ்டி! கொஞ்சம் ஓய்வெடு! 😂';
        case 'cute_friendly':
          return 'ஹே பெஸ்டி! உனக்கு சின்ன கட்டிப்பிடிப்பு! 🥰';
        case 'gentle_supportive':
          return 'உன் உடலை கவனி. ஓய்வெடு! 🌙';
      }
    } else {
      // English
      switch (prefs.personality) {
        case 'funny_caring':
          return 'Girl, uterus drama ah? Take care bestie! 😂';
        case 'cute_friendly':
          return 'Sending you a little hug, bestie! 🥰';
        case 'gentle_supportive':
          return 'Listen to your body. Take it easy 💗';
      }
    }

    return 'Hey bestie! Take care of yourself 💗';
  }
}
