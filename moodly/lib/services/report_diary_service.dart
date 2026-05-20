// lib/services/report_diary_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDiaryService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference reportRef = _db.collection("reports");

  /// ================= CREATE REPORT =================
  static Future<void> createReport({
    required String type,

    /// USER YANG DILAPORKAN
    required String reportedUser,
    required String reportedProfile,
    required String reportedUid,

    /// PELAPOR
    required String reportedByUid,
    required String reportedByUsername,

    /// REPORT
    required String reportCategory,
    required String reportReason,

    /// CONTENT
    required String contentText,

    /// TARGET ID
    required String targetId,
  }) async {
    await reportRef.add({
      /// TYPE
      "type": type,

      /// REPORTED USER
      "reported_user": reportedUser,
      "reported_profile": reportedProfile,
      "reported_uid": reportedUid,

      /// REPORTER
      "reported_by_uid": reportedByUid,
      "reported_by_username": reportedByUsername,

      /// REPORT DETAIL
      "report_category": reportCategory,
      "report_reason": reportReason,

      /// CONTENT
      "content_text": contentText,

      /// TARGET
      "target_id": targetId,

      /// SYSTEM
      "status": "pending",

      "created_at": FieldValue.serverTimestamp(),
    });
  }
}
