import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// NotificationService handles showing notifications when timer ends
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _initialized = false;

  /// Call this once in main.dart before the app starts
  static Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(initSettings);
    _initialized = true;
  }

  /// Show a notification — withSound controls if it makes noise
  static Future<void> _showNotification({
    required String title,
    required String body,
    required bool withSound,
  }) async {
    // When withSound is true  → use default notification sound
    // When withSound is false → silent notification (no sound)
    final androidDetails = AndroidNotificationDetails(
      withSound ? 'pomodoro_sound' : 'pomodoro_silent',
      withSound ? 'Pomodoro Timer (Sound)' : 'Pomodoro Timer (Silent)',
      channelDescription: 'Pomodoro timer completion notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: withSound, // KEY: true = sound, false = silent
      silent: !withSound, // KEY: true = silent, false = sound
    );

    const iosDetails = DarwinNotificationDetails();

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(0, title, body, details);
  }

  /// Show notification: work session ended
  static Future<void> showWorkComplete({bool withSound = true}) async {
    await _showNotification(
      title: '🎉 Work Session Complete!',
      body: 'Great job! Time for a well-deserved break.',
      withSound: withSound,
    );
  }

  /// Show notification: break ended
  static Future<void> showBreakComplete({bool withSound = true}) async {
    await _showNotification(
      title: '⏰ Break Over!',
      body: 'Ready to focus again? Start your next Pomodoro!',
      withSound: withSound,
    );
  }

  /// Play a subtle tick sound (called every second if ticking enabled)
  /// Note: on mobile this plays the default short notification sound
  static Future<void> playTickSound() async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_tick',
      'Pomodoro Tick',
      channelDescription: 'Subtle tick sound every second',
      importance: Importance.low,
      priority: Priority.low,
      playSound: true,
      silent: false,
      onlyAlertOnce: true, // don't keep interrupting
    );

    final details = NotificationDetails(android: androidDetails);
    await _notifications.show(1, '', '', details);
  }

  /// Cancel all pending notifications
  static Future<void> cancelAll() async {
    await _notifications.cancelAll();
  }
}
