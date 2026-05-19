// lib/services/report_diary_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDiaryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference reportRef = _db.collection("reports");

  static Future<void> createReport({
    required String reportedUser,
    required String reportedProfile,
    required String reportCategory,
    required String diaryText,
    required String reportedBy,
    required String diaryId,
  }) async {
    await reportRef.add({
      "reported_user": reportedUser,
      "reported_profile": reportedProfile,
      "report_category": reportCategory,
      "diary_text": diaryText,
      "reported_by": reportedBy,
      "diary_id": diaryId,
      "created_at": FieldValue.serverTimestamp(),
      "status": "pending",
    });
  }
}
