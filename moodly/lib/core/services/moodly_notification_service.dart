import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/moodly_notification_model.dart';
import 'notification_service.dart';

class MoodlyNotificationService {
  MoodlyNotificationService._();

  static final MoodlyNotificationService instance =
      MoodlyNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _notificationRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, bool>> _loadNotificationPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'dailyNote': prefs.getBool('dailyNote') ?? false,
      'morningAwareness': prefs.getBool('morningAwareness') ?? true,
      'achievementAlert': prefs.getBool('achievementAlert') ?? false,
    };
  }

  Future<String> _loadLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();

    // Kalau key language kamu ternyata beda, cukup ganti satu baris ini.
    final raw = prefs.getString('languageCode') ?? 'id';
    return raw == 'en' ? 'en' : 'id';
  }

  ({String title, String message}) _localTextForType(
    String languageCode,
    String type,
  ) {
    switch (type) {
      case 'daily_checkin':
        return (
          title: languageCode == 'en'
              ? 'Don’t forget your mood check-in'
              : 'Jangan lupa check-in mood',
          message: languageCode == 'en'
              ? 'Try recording how you feel today. One small step still matters.'
              : 'Coba catat perasaanmu hari ini. Satu langkah kecil tetap berarti.',
        );

      case 'low_mood':
        return (
          title: languageCode == 'en'
              ? 'Your mood seems quite heavy'
              : 'Moodmu terlihat cukup berat',
          message: languageCode == 'en'
              ? 'Two of your last three mood entries were heavy. Try opening emergency support or seeking professional help.'
              : 'Dua dari tiga catatan mood terakhirmu cenderung berat. Coba buka bantuan darurat atau cari dukungan profesional.',
        );

      case 'morning_awareness':
        return (
          title: languageCode == 'en'
              ? 'Good morning, take a gentle pause'
              : 'Selamat pagi, ambil jeda sebentar',
          message: languageCode == 'en'
              ? 'Start your day a little more calmly today.'
              : 'Mulai harimu dengan sedikit lebih tenang hari ini.',
        );

      case 'achievement':
        return (
          title: languageCode == 'en'
              ? 'Celebrate your small progress'
              : 'Rayakan progres kecilmu',
          message: languageCode == 'en'
              ? 'Even a small step still counts today.'
              : 'Langkah kecilmu tetap berarti hari ini.',
        );

      default:
        return (
          title: languageCode == 'en' ? 'Notification' : 'Notifikasi',
          message: languageCode == 'en'
              ? 'You have a new Moodly notification.'
              : 'Kamu punya notifikasi baru dari Moodly.',
        );
    }
  }

  Future<Map<String, String>> _loadMoodDatabase(String uid) async {
    final Map<String, String> moods = {};

    final prefs = await SharedPreferences.getInstance();
    final moodPrefix = 'mood_${uid}_';
    final localKeys = prefs.getKeys().where((k) => k.startsWith(moodPrefix));

    for (final key in localKeys) {
      final dateKey = key.replaceFirst(moodPrefix, '');
      final mood = prefs.getString(key);
      if (mood != null && mood.trim().isNotEmpty) {
        moods[dateKey] = mood.trim();
      }
    }

    final doc = await _firestore.collection('moods').doc(uid).get();
    if (doc.exists) {
      final data = doc.data();
      final entries = data?['entries'] as Map<String, dynamic>? ?? {};
      entries.forEach((key, value) {
        final mood = value.toString().trim();
        if (mood.isNotEmpty) {
          moods[key] = mood;
        }
      });
    }

    return moods;
  }

  Future<void> _showLocalIfPossibleForType(String type) async {
    try {
      final languageCode = await _loadLanguageCode();
      final text = _localTextForType(languageCode, type);

      await NotificationService.instance.initialize();
      await NotificationService.instance.showInstantNotification(
        title: text.title,
        body: text.message,
      );
    } catch (_) {
      // Abaikan kalau permission/device belum siap.
    }
  }

  Future<void> _createIfMissing({
    required String uid,
    required String uniqueKey,
    required String type,
    Map<String, dynamic> payload = const {},
    bool showLocalNow = false,
  }) async {
    final existing = await _notificationRef(uid)
        .where('uniqueKey', isEqualTo: uniqueKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _notificationRef(uid).add({
      'type': type,
      'uniqueKey': uniqueKey,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'payload': payload,
    });

    if (showLocalNow) {
      await _showLocalIfPossibleForType(type);
    }
  }

  Future<void> syncForCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final moods = await _loadMoodDatabase(uid);
    final prefs = await _loadNotificationPrefs();
    final todayKey = _dateKey(DateTime.now());

    if (prefs['morningAwareness'] == true) {
      await _syncMorningAwareness(uid, todayKey);
    }

    if (prefs['dailyNote'] == true) {
      await _syncDailyCheckIn(uid, moods, todayKey);
    }

    if (prefs['achievementAlert'] == true) {
      await _syncAchievement(uid, todayKey);
    }

    await _syncLowMoodWarning(uid, moods, todayKey);
  }

  Future<void> createDebugNotificationForCurrentUser({
    required String type,
    bool showLocalNow = true,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final uniqueKey = 'debug_${type}_${DateTime.now().millisecondsSinceEpoch}';

    await _createIfMissing(
      uid: uid,
      uniqueKey: uniqueKey,
      type: type,
      payload: {
        'debug': true,
        'type': type,
        'createdAtMs': DateTime.now().millisecondsSinceEpoch,
      },
      showLocalNow: showLocalNow,
    );
  }

  Future<void> _syncMorningAwareness(
    String uid,
    String todayKey,
  ) async {
    await _createIfMissing(
      uid: uid,
      uniqueKey: 'morning_awareness_$todayKey',
      type: 'morning_awareness',
      payload: {'dateKey': todayKey},
    );
  }

  Future<void> _syncDailyCheckIn(
    String uid,
    Map<String, String> moods,
    String todayKey,
  ) async {
    final hasTodayMood = moods.containsKey(todayKey);

    if (!hasTodayMood) {
      await _createIfMissing(
        uid: uid,
        uniqueKey: 'daily_checkin_$todayKey',
        type: 'daily_checkin',
        payload: {'dateKey': todayKey},
      );
    }
  }

  Future<void> _syncAchievement(
    String uid,
    String todayKey,
  ) async {
    await _createIfMissing(
      uid: uid,
      uniqueKey: 'achievement_$todayKey',
      type: 'achievement',
      payload: {'dateKey': todayKey},
    );
  }

  Future<void> _syncLowMoodWarning(
    String uid,
    Map<String, String> moods,
    String todayKey,
  ) async {
    if (moods.isEmpty) return;

    final sortedKeys = moods.keys.toList()..sort();
    final latestKeys = sortedKeys.reversed.take(3).toList();

    if (latestKeys.length < 3) return;

    final latestMoods = latestKeys
        .map((key) => moods[key] ?? '')
        .where((m) => m.isNotEmpty)
        .toList();

    final lowCount = latestMoods
        .where((m) => m == 'Sedih' || m == 'Marah')
        .length;

    if (lowCount >= 2) {
      await _createIfMissing(
        uid: uid,
        uniqueKey: 'low_mood_$todayKey',
        type: 'low_mood',
        payload: {
          'latestKeys': latestKeys,
        },
        showLocalNow: true,
      );
    }
  }

  Stream<List<MoodlyNotificationModel>> watchNotifications() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _notificationRef(uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MoodlyNotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  Stream<int> unreadCountStream() {
    return watchNotifications().map(
      (items) => items.where((item) => !item.isRead).length,
    );
  }

  Future<void> markAsRead(String id) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _notificationRef(uid).doc(id).set({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> markAllAsRead() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await _notificationRef(uid).get();
    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.set(
        doc.reference,
        {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    }

    await batch.commit();
  }
}