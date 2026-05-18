import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/moodly_notification_model.dart';

class MoodlyNotificationService {
  MoodlyNotificationService._();

  static final MoodlyNotificationService instance =
      MoodlyNotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const String _moodDocumentId = 'BeZzql14Y8xGyoLUDb0L';

  CollectionReference<Map<String, dynamic>> _notificationRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('notifications');
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<Map<String, String>> _loadMoodDatabase() async {
    final Map<String, String> moods = {};

    final prefs = await SharedPreferences.getInstance();
    final localKeys = prefs.getKeys().where((k) => k.startsWith('mood_'));

    for (final key in localKeys) {
      final dateKey = key.replaceFirst('mood_', '');
      final mood = prefs.getString(key);
      if (mood != null && mood.trim().isNotEmpty) {
        moods[dateKey] = mood.trim();
      }
    }

    final doc = await _firestore.collection('moods').doc(_moodDocumentId).get();
    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>?;
      final entries = data?['entries'] as Map<String, dynamic>? ?? {};
      entries.forEach((key, value) {
        moods[key] = value.toString();
      });
    }

    return moods;
  }

  Future<void> _createIfMissing({
    required String uid,
    required String uniqueKey,
    required String title,
    required String message,
    required String type,
    String? ctaLabel,
    Map<String, dynamic> payload = const {},
  }) async {
    final existing = await _notificationRef(uid)
        .where('uniqueKey', isEqualTo: uniqueKey)
        .limit(1)
        .get();

    if (existing.docs.isNotEmpty) return;

    await _notificationRef(uid).add({
      'title': title,
      'message': message,
      'type': type,
      'uniqueKey': uniqueKey,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
      'ctaLabel': ctaLabel,
      'payload': payload,
    });
  }

  Future<void> syncForCurrentUser() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final moods = await _loadMoodDatabase();
    final todayKey = _dateKey(DateTime.now());

    await _syncDailyCheckIn(uid, moods, todayKey);
    await _syncLowMoodWarning(uid, moods, todayKey);
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
        title: 'Jangan lupa check-in mood',
        message: 'Coba catat perasaanmu hari ini. Satu langkah kecil tetap berarti.',
        type: 'daily_checkin',
        ctaLabel: 'Isi mood',
        payload: {'dateKey': todayKey},
      );
    }
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
        title: 'Moodmu terlihat cukup berat',
        message:
            'Dua dari tiga catatan mood terakhirmu cenderung berat. Coba buka bantuan darurat atau cari dukungan profesional.',
        type: 'low_mood',
        ctaLabel: 'Lihat bantuan',
        payload: {
          'latestKeys': latestKeys,
        },
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