import 'package:cloud_firestore/cloud_firestore.dart';

class ReportDiaryService {
  ReportDiaryService._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _reportRef =>
      _db.collection("reports");

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
    required String diaryId,
  }) async {
    final payload = <String, dynamic>{
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
      "diary_id": diaryId,

      /// EXTRA CONTEXT
      "comment_id": null,
      "reply_id": null,
      "target_type": "diary",

      /// SYSTEM
      "status": "pending",
      "created_at": FieldValue.serverTimestamp(),
    };

    await _reportRef.add(payload);
  }

  /// ================= WATCH MY REPORTS (OPTIONAL) =================
  static Stream<QuerySnapshot<Map<String, dynamic>>> getReportsByReporter(
    String reporterUid,
  ) {
    return _reportRef
        .where("reported_by_uid", isEqualTo: reporterUid)
        .orderBy("created_at", descending: true)
        .snapshots();
  }
}