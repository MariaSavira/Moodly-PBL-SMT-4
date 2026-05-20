import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference reportRef = _db.collection(
    "reported_comments",
  );

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
      "diary_id": diaryId,
      "comment_id": commentId,
      "reply_id": replyId,

      /// SYSTEM
      "status": "pending",

      "created_at": FieldValue.serverTimestamp(),
    });
  }
}
