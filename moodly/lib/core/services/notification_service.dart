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

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/launcher_icon',
    );

    const settings = InitializationSettings(
      android: androidSettings,
    );

    await notificationsPlugin.initialize(
      settings: settings,
    );

    await notificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _isInitialized = true;
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
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
        ),
      ),
    );
  }

  Future<void> scheduleDailyMoodReminder() async {
    await notificationsPlugin.zonedSchedule(
      id: 1,
      title: 'Moodly 🌿',
      body: 'Jangan lupa catat suasana hatimu hari ini.',
      scheduledDate: _nextInstanceOfTime(
        hour: 20,
        minute: 0,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_mood_channel',
          'Daily Mood Reminder',
          channelDescription: 'Pengingat pencatatan mood harian',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleMorningAwarenessReminder() async {
    await notificationsPlugin.zonedSchedule(
      id: 2,
      title: 'Selamat pagi 🌱',
      body: 'Ambil napas sebentar dan mulai hari dengan tenang.',
      scheduledDate: _nextInstanceOfTime(
        hour: 8,
        minute: 0,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'morning_awareness_channel',
          'Morning Awareness Reminder',
          channelDescription: 'Pengingat kesadaran pagi',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleAchievementReminder() async {
    await notificationsPlugin.zonedSchedule(
      id: 3,
      title: 'Moodly Achievement ✨',
      body: 'Rayakan progres kecilmu hari ini. Kamu sudah berusaha.',
      scheduledDate: _nextInstanceOfTime(
        hour: 19,
        minute: 0,
      ),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'achievement_channel',
          'Achievement Reminder',
          channelDescription: 'Pengingat pencapaian Moodly',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyMoodReminder() async {
    await notificationsPlugin.cancel(
      id: 1,
    );
  }

  Future<void> cancelMorningAwarenessReminder() async {
    await notificationsPlugin.cancel(
      id: 2,
    );
  }

  Future<void> cancelAchievementReminder() async {
    await notificationsPlugin.cancel(
      id: 3,
    );
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
      scheduledDate = scheduledDate.add(
        const Duration(days: 1),
      );
    }

    return scheduledDate;
  }
}