// lib/services/firestore_diary_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/diary_model.dart';

class FirestoreDiaryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference diaryRef = _db.collection("diaries");

  /// ================= PUBLIC DIARY =================
  static Stream<List<DiaryModel>> getPublicDiaries() {
    return diaryRef
        .where("isPublic", isEqualTo: true)
        .orderBy("createdAt", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DiaryModel.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  /// ================= PRIVATE DIARY =================
  Stream<List<DiaryModel>> getPrivateDiaries(String month, int year) {
    return diaryRef
        .where("isPublic", isEqualTo: false)
        .where("month", isEqualTo: month)
        .where("year", isEqualTo: year)
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DiaryModel.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  /// ================= WEEK DIARY =================
  static Stream<List<DiaryModel>> getWeekDiaries() {
    final now = DateTime.now();

    return diaryRef
        .where("isPublic", isEqualTo: false)
        .where("month", isEqualTo: _getMonth(now.month))
        .where("year", isEqualTo: now.year)
        .orderBy("date", descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DiaryModel.fromFirestore(
              doc.id,
              doc.data() as Map<String, dynamic>,
            );
          }).toList();
        });
  }

  /// ================= TOGGLE LIKE =================
  static Future<void> toggleDiaryLike({
    required String diaryId,
    required String userId,
  }) async {
    final doc = diaryRef.doc(diaryId);

    final snapshot = await doc.get();

    final data = snapshot.data() as Map<String, dynamic>;

    List likedBy = data["likedBy"] ?? [];

    if (likedBy.contains(userId)) {
      await doc.update({
        "likedBy": FieldValue.arrayRemove([userId]),

        "likes": FieldValue.increment(-1),
      });
    } else {
      await doc.update({
        "likedBy": FieldValue.arrayUnion([userId]),

        "likes": FieldValue.increment(1),
      });
    }
  }

  /// ================= COMMENT COUNT =================
  static Future<void> updateCommentCount({
    required String diaryId,
    required int total,
  }) async {
    await diaryRef.doc(diaryId).update({"comments": total});
  }

  /// ================= DELETE DIARY =================
  static Future<void> deleteDiary({required String diaryId}) async {
    try {
      // ================= DELETE COMMENTS =================
      final commentsSnapshot = await diaryRef
          .doc(diaryId)
          .collection("comments")
          .get();

      for (var commentDoc in commentsSnapshot.docs) {
        // ================= DELETE REPLIES =================
        final repliesSnapshot = await commentDoc.reference
            .collection("replies")
            .get();

        for (var replyDoc in repliesSnapshot.docs) {
          await replyDoc.reference.delete();
        }

        // ================= DELETE COMMENT =================
        await commentDoc.reference.delete();
      }

      // ================= DELETE DIARY =================
      await diaryRef.doc(diaryId).delete();
    } catch (e) {
      throw Exception("Gagal menghapus diary: $e");
    }
  }

  /// ================= ADD DIARY =================
  static Future<void> addDiary({
    required String title,
    required String content,
    required String time,
    required int date,
    required String month,
    required int year,
    required bool isPublic,
    required List<String> images,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    await diaryRef.add({
      "title": title,
      "content": content,

      "images": images,

      "time": time,
      "date": date,
      "month": month,
      "year": year,

      "isPublic": isPublic,

      /// ================= USER INFO =================
      "uid": user?.uid ?? "",

      "username": user?.displayName ?? "Anonymous",

      "profileImage": user?.photoURL ?? "",

      /// ================= SOCIAL =================
      "likes": 0,
      "comments": 0,
      "likedBy": [],

      /// ================= TIME =================
      "createdAt": FieldValue.serverTimestamp(),
    });
  }

  /// ================= MONTH FORMAT =================
  static String _getMonth(int month) {
    const months = [
      "JAN",
      "FEB",
      "MAR",
      "APR",
      "MEI",
      "JUN",
      "JUL",
      "AGS",
      "SEP",
      "OKT",
      "NOV",
      "DES",
    ];

    return months[month - 1];
  }
}
