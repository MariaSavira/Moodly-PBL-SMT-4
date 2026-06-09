import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCommentService {
  ReportCommentService._();
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference<Map<String, dynamic>> get _reportRef =>
      _db.collection("reports");

  /// ================= REPORT COMMENT / REPLY =================
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

    /// TARGET
    required String diaryId,
    required String commentId,

    /// OPTIONAL
    String? replyId,
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
      "comment_id": commentId,
      "reply_id": replyId,
      "target_type": replyId == null ? "comment" : "reply",

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