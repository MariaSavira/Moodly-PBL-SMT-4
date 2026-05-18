import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // COLLECTION REPORT
  // =========================

  static final CollectionReference reportRef = _db.collection("reports");

  // =========================
  // ADD COMMENT
  // =========================

  static Future<void> addComment({
    required String diaryId,
    required String username,
    required String profileImage,
    required String comment,
  }) async {
    await _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .add({
          "diary_id": diaryId,

          "username": username,

          "profile_image": profileImage,

          "comment": comment,

          "likes": 0,

          "created_at": FieldValue.serverTimestamp(),

          "replies": [],
        });
  }

  // =========================
  // GET COMMENTS REALTIME
  // =========================

  static Stream<QuerySnapshot> getComments(String diaryId) {
    return _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  // =========================
  // LIKE COMMENT
  // =========================

  static Future<void> likeComment({
    required String diaryId,
    required String commentId,
    required bool isLiked,
  }) async {
    final doc = _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .doc(commentId);

    await doc.update({"likes": FieldValue.increment(isLiked ? -1 : 1)});
  }

  // =========================
  // ADD REPLY
  // =========================

  static Future<void> addReply({
    required String diaryId,
    required String commentId,
    required String username,
    required String profileImage,
    required String reply,
  }) async {
    final doc = _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .doc(commentId);

    await doc.update({
      "replies": FieldValue.arrayUnion([
        {
          "username": username,

          "profile_image": profileImage,

          "reply": reply,

          "likes": 0,

          "created_at": FieldValue.serverTimestamp(),
        },
      ]),
    });
  }

  // =========================
  // REPORT COMMENT
  // =========================

  static Future<void> reportComment({
    required String diaryId,
    required String commentId,
    required String reportedUser,
    required String reportedProfile,
    required String commentText,
    required String reportedBy,
    required String reportCategory,
  }) async {
    await reportRef.add({
      "type": "comment",

      "diary_id": diaryId,

      "comment_id": commentId,

      "reported_user": reportedUser,

      "reported_profile": reportedProfile,

      "comment_text": commentText,

      "reported_by": reportedBy,

      "report_category": reportCategory,

      "status": "pending",

      "created_at": FieldValue.serverTimestamp(),
    });
  }
}
