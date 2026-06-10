import 'package:flutter/foundation.dart';
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
      final notifGranted =
          await androidPlugin.requestNotificationsPermission();
      debugPrint('Moodly notification permission granted: $notifGranted');

      try {
        final exactGranted =
            await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Moodly exact alarm permission granted: $exactGranted');
      } catch (e) {
        debugPrint(
          'Moodly exact alarm permission request skipped/error: $e',
        );
      }
    }

    _isInitialized = true;
    debugPrint('Moodly NotificationService initialized');
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<void> debugDumpPendingSchedules() async {
    await _ensureInitialized();

    final pending = await notificationsPlugin.pendingNotificationRequests();
    debugPrint('Moodly pending notifications count: ${pending.length}');

    for (final item in pending) {
      debugPrint(
        'Pending notification -> id: ${item.id}, title: ${item.title}, body: ${item.body}, payload: ${item.payload}',
      );
    }
  }

  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    await _ensureInitialized();

    await notificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
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

  Future<void> syncSchedulesFromPrefs({
    required String languageCode,
    required bool dailyNote,
    required bool morningAwareness,
    required bool achievementAlert,
  }) async {
    await _ensureInitialized();

    debugPrint(
      'Moodly sync schedules -> language: $languageCode, dailyNote: $dailyNote, morningAwareness: $morningAwareness, achievementAlert: $achievementAlert',
    );

    await notificationsPlugin.cancel(id: 1);
    await notificationsPlugin.cancel(id: 2);
    await notificationsPlugin.cancel(id: 3);

    if (dailyNote) {
      await scheduleDailyMoodReminder(languageCode: languageCode);
    }

    if (morningAwareness) {
      await scheduleMorningAwarenessReminder(languageCode: languageCode);
    }

    if (achievementAlert) {
      await scheduleAchievementReminder(languageCode: languageCode);
    }

    await debugDumpPendingSchedules();
  }

  Future<void> scheduleDailyMoodReminder({
    required String languageCode,
  }) async {
    final title = 'Moodly 🌿';
    final body = languageCode == 'en'
        ? 'Do not forget to log your mood today.'
        : 'Jangan lupa catat suasana hatimu hari ini.';

    await _scheduleDaily(
      id: 1,
      title: title,
      body: body,
      channelId: 'daily_mood_channel',
      channelName: 'Daily Mood Reminder',
      channelDescription: 'Pengingat pencatatan mood harian',
      hour: 12,
      minute: 0,
    );
  }

  Future<void> scheduleMorningAwarenessReminder({
    required String languageCode,
  }) async {
    final title = languageCode == 'en'
        ? 'Good morning 🌱'
        : 'Selamat pagi 🌱';

    final body = languageCode == 'en'
        ? 'Take a short breath and start your day more calmly.'
        : 'Ambil napas sebentar dan mulai hari dengan tenang.';

    await _scheduleDaily(
      id: 2,
      title: title,
      body: body,
      channelId: 'morning_awareness_channel',
      channelName: 'Morning Awareness Reminder',
      channelDescription: 'Pengingat kesadaran pagi',
      hour: 8,
      minute: 0,
    );
  }

  Future<void> scheduleAchievementReminder({
    required String languageCode,
  }) async {
    final title = languageCode == 'en'
        ? 'Moodly Achievement ✨'
        : 'Pencapaian Moodly ✨';

    final body = languageCode == 'en'
        ? 'Celebrate your small progress today. You are still trying.'
        : 'Rayakan progres kecilmu hari ini. Kamu sudah berusaha.';

    await _scheduleDaily(
      id: 3,
      title: title,
      body: body,
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

    debugPrint(
      'Moodly scheduling notification -> id: $id, channel: $channelId, nextTime: $scheduleTime',
    );

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
    await debugDumpPendingSchedules();
  }

  Future<void> cancelMorningAwarenessReminder() async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id: 2);
    await debugDumpPendingSchedules();
  }

  Future<void> cancelAchievementReminder() async {
    await _ensureInitialized();
    await notificationsPlugin.cancel(id: 3);
    await debugDumpPendingSchedules();
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