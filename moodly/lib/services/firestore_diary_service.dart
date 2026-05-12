import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/diary_model.dart';

class FirestoreDiaryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference diaryRef = _db.collection("diaries");

  /// ================= ADD DIARY =================
  static Future<void> addDiary({
    required String title,
    required String content,
    required bool isPublic,
  }) async {
    final now = DateTime.now();

    const monthMap = {
      1: "JAN",
      2: "FEB",
      3: "MAR",
      4: "APR",
      5: "MEI",
      6: "JUN",
      7: "JUL",
      8: "AGS",
      9: "SEP",
      10: "OKT",
      11: "NOV",
      12: "DES",
    };

    await diaryRef.add({
      "title": title,

      "content": content,

      "time":
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}",

      "date": now.day,

      "month": monthMap[now.month],

      "year": now.year,

      "isPublic": isPublic,

      "username": "User",

      "createdAt": FieldValue.serverTimestamp(),

      // =========================
      // SOFT DELETE
      // =========================
      "isDeleted": false,
    });
  }

  /// ================= WEEK DIARY =================
  Stream<List<DiaryModel>> getWeekDiaries() {
    return diaryRef
        .where("isPublic", isEqualTo: false)
        .orderBy("createdAt", descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => doc.data() != null)
              .map(
                (doc) => DiaryModel.fromFirestore(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ),
              )
              .toList();
        });
  }

  /// ================= PRIVATE DIARY =================
  Stream<List<DiaryModel>> getPrivateDiaries(String month, int year) {
    return diaryRef
        .where("month", isEqualTo: month)
        .where("year", isEqualTo: year)
        .where("isPublic", isEqualTo: false)
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

  /// ================= PUBLIC DIARY =================
  Stream<List<DiaryModel>> getPublicDiaries() {
    return diaryRef
        .where("isPublic", isEqualTo: true)
        // =========================
        // HANYA TAMPILKAN
        // YANG BELUM DIHAPUS ADMIN
        // =========================
        .where("isDeleted", isEqualTo: false)
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
}
