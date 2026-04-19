import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  // ─────────────────────────────────────────────
  // NOTIFICATION SETUP
  // ─────────────────────────────────────────────
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // AudioPlayer للتيك تاك — static بحيث نتحكم فيه من أي مكان
  static final AudioPlayer _tickPlayer = AudioPlayer();
  static final AudioPlayer _alertPlayer = AudioPlayer();

  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(initSettings);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
    _initialized = true;
  }

  static Future<void> showLiveTimer({
    required String timeLeft,
    required String sessionType, // 'Focus' or 'Break'
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'pomodoro_live_timer', // channel id
      'Live Timer', // channel name
      channelDescription: 'Shows remaining time for current Pomodoro session',
      importance: Importance.low, // low = no sound with each update
      priority: Priority.low,
      ongoing: true, // لا يمكن تمريره للحذف
      onlyAlertOnce: true, // ما يصدر صوت عند كل تحديث
      showWhen: false,
      autoCancel: false,
      icon: '@mipmap/ic_launcher',
    );

    const details = NotificationDetails(android: androidDetails);

    final emoji = sessionType == 'Focus' ? '🍅' : '☕';
    final title = '$emoji $sessionType Session';
    final body = 'Time remaining: $timeLeft';

    await _notifications.show(
      1, // notification id ثابت حتى يُحدَّث نفس الإشعار
      title,
      body,
      details,
    );
  }

  // إلغاء الإشعار الحي عند الإيقاف أو الانتهاء
  static Future<void> cancelLiveTimer() async {
    await _notifications.cancel(1);
  }

  // ─────────────────────────────────────────────
  // COMPLETION NOTIFICATIONS
  // ─────────────────────────────────────────────
  static Future<void> showWorkComplete({bool withSound = true}) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_complete',
      'Session Complete',
      channelDescription: 'Notifies when a Pomodoro session ends',
      importance: Importance.high,
      priority: Priority.high,
      playSound: withSound,
      autoCancel: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      2,
      '🎉 Work Session Complete!',
      'Great job! Time for a break.',
      details,
    );
  }

  static Future<void> showBreakComplete({bool withSound = true}) async {
    final androidDetails = AndroidNotificationDetails(
      'pomodoro_break_complete',
      'Break Complete',
      channelDescription: 'Notifies when a break ends',
      importance: Importance.high,
      priority: Priority.high,
      playSound: withSound,
      autoCancel: true,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      3,
      '💪 Break Over!',
      'Ready to focus again?',
      details,
    );
  }

  // ─────────────────────────────────────────────
  // TICK SOUND
  // ─────────────────────────────────────────────

  // يشغّل صوت تيك تاك — نستخدم frequency على asset
  static Future<void> startTickingSound() async {
    // نشغّل ملف صوتي على loop
    await _tickPlayer.setReleaseMode(ReleaseMode.loop);
    await _tickPlayer.play(AssetSource('sounds/tick.mp3'));
  }

  static Future<void> stopTickingSound() async {
    await _tickPlayer.stop();
  }

  // للتوافق مع الكود القديم في timer_provider
  static Future<void> playTickSound() async {
    // هذا الميثود موجود للتوافق — الـ loop يتم عبر startTickingSound
  }

  // ─────────────────────────────────────────────
  // ALERT SOUND (work/break complete)
  // ─────────────────────────────────────────────
  static Future<void> playAlertSound() async {
    await _alertPlayer.play(AssetSource('sounds/complete.mp3'));
  }

  static Future<void> dispose() async {
    await _tickPlayer.dispose();
    await _alertPlayer.dispose();
  }
}
