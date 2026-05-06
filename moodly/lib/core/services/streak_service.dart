import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/streak_model.dart';

class StreakService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<StreakModel> getStreak(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).collection('streak').doc('current').get();
    if (doc.exists) {
      return StreakModel.fromMap(doc.data()!);
    } else {
      // buat default jika belum ada
      final streak = StreakModel(
        currentDay: 1,
        totalPoints: 0,
        freezeLeft: 2,
        freezeActive: false,
        completed: [false, false, false],
        lastUpdate: DateTime.now(),
      );
      await _firestore.collection('users').doc(uid).collection('streak').doc('current').set(streak.toMap());
      return streak;
    }
  }

  Future<void> updateStreak(String uid, StreakModel streak) async {
    await _firestore.collection('users').doc(uid).collection('streak').doc('current').set(streak.toMap());
  }
}