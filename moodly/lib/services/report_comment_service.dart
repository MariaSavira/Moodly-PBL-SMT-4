import 'package:cloud_firestore/cloud_firestore.dart';

class ReportCommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static final CollectionReference reportRef = _db.collection(
    "reported_comments",
  );

  /// ================= REPORT COMMENT =================
  static Future<void> createReport({
    required String reportedUser,
    required String reportedProfile,
    required String reportCategory,
    required String commentText,
    required String reportedBy,
    required String diaryId,
    required String commentId,
  }) async {
    await reportRef.add({
      "reportedUser": reportedUser,

      "reportedProfile": reportedProfile,

      "reportCategory": reportCategory,

      "commentText": commentText,

      "reportedBy": reportedBy,

      "diaryId": diaryId,

      "commentId": commentId,

      "reportedAt": FieldValue.serverTimestamp(),

      // STATUS REPORT
      "status": "pending",
    });
  }
}
