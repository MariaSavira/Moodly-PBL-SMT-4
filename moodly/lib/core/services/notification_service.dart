import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    tz.initializeTimeZones();

    const androidSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');
    const settings = InitializationSettings(android: androidSettings);

    await notificationsPlugin.initialize(settings: settings);

    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.requestNotificationsPermission();
      try {
        await androidPlugin.requestExactAlarmsPermission();
      } catch (_) {
        // Beberapa versi plugin / Android API tidak punya method ini.
      }
    }

    _isInitialized = true;
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();

    await notificationsPlugin.show(
      id: 0,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'moodly_channel',
          'Moodly Notifications',
          channelDescription: 'Notification channel for Moodly',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/launcher_icon',
        ),
      ),
    );
  }

  Future<void> scheduleDailyMoodReminder() async {
    await _scheduleDaily(
      id: 1,
      title: 'Moodly 🌿',
      body: 'Jangan lupa catat suasana hatimu hari ini.',
      channelId: 'daily_mood_channel',
      channelName: 'Daily Mood Reminder',
      channelDescription: 'Pengingat pencatatan mood harian',
      hour: 20,
      minute: 0,
    );
  }

  Future<void> scheduleMorningAwarenessReminder() async {
    await _scheduleDaily(
      id: 2,
      title: 'Selamat pagi 🌱',
      body: 'Ambil napas sebentar dan mulai hari dengan tenang.',
      channelId: 'morning_awareness_channel',
      channelName: 'Morning Awareness Reminder',
      channelDescription: 'Pengingat kesadaran pagi',
      hour: 8,
      minute: 0,
    );
  }

  Future<void> scheduleAchievementReminder() async {
    await _scheduleDaily(
      id: 3,
      title: 'Moodly Achievement ✨',
      body: 'Rayakan progres kecilmu hari ini. Kamu sudah berusaha.',
      channelId: 'achievement_channel',
      channelName: 'Achievement Reminder',
      channelDescription: 'Pengingat pencapaian Moodly',
      hour: 19,
      minute: 0,
    );
  }

  Future<void> _scheduleDaily({
    required int id,
    required String title,
    required String body,
    required String channelId,
    required String channelName,
    required String channelDescription,
    required int hour,
    required int minute,
  }) async {
    await _ensureInitialized();

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/launcher_icon',
      ),
    );

    final scheduleTime = _nextInstanceOfTime(hour: hour, minute: minute);

    await notificationsPlugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: scheduleTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'moodly_daily',
    );
  }

  Future<void> cancelDailyMoodReminder() async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id: 1);
  }

  Future<void> cancelMorningAwarenessReminder() async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id: 2);
  }

  Future<void> cancelAchievementReminder() async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id: 3);
  }

  tz.TZDateTime _nextInstanceOfTime({
    required int hour,
    required int minute,
  }) {
    final now = tz.TZDateTime.now(tz.local);

    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }
}
