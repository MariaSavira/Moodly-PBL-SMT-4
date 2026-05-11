import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDiaryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference reportRef = _db.collection("report_diary");

  // =========================
  // CREATE REPORT
  // =========================

  static Future<void> createReport({
    required String reportedUser,

    // FOTO PROFIL USER YANG DILAPORKAN
    required String reportedProfile,

    required String reportCategory,

    required String diaryText,

    // USER YANG MELAPORKAN
    required String reportedBy,

    required String diaryId,
  }) async {
    await reportRef.add({
      // USER YANG DILAPORKAN
      "reported_user": reportedUser,

      // FOTO PROFIL USER YANG DILAPORKAN
      "reported_profile": reportedProfile,

      // KATEGORI REPORT
      "report_category": reportCategory,

      // ISI DIARY
      "diary_text": diaryText,

      // USER PELAPOR
      "reported_by": reportedBy,

      // ID DIARY
      "diary_id": diaryId,

      // WAKTU REPORT
      "created_at": FieldValue.serverTimestamp(),

      // STATUS REPORT
      "status": "pending",
    });
  }
}
