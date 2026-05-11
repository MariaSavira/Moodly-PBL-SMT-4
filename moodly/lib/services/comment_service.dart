import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // =========================
  // COLLECTION
  // =========================

  static CollectionReference commentsRef(String diaryId) {
    return _db.collection("public_diary").doc(diaryId).collection("comments");
  }

  // =========================
  // ADD COMMENT
  // =========================

  static Future<void> addComment({
    required String diaryId,

    required String username,

    required String profileImage,

    required String comment,
  }) async {
    await commentsRef(diaryId).add({
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
    return commentsRef(
      diaryId,
    ).orderBy("created_at", descending: true).snapshots();
  }

  // =========================
  // LIKE COMMENT
  // =========================

  static Future<void> likeComment({
    required String diaryId,

    required String commentId,

    required bool isLiked,
  }) async {
    final doc = commentsRef(diaryId).doc(commentId);

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
    final doc = commentsRef(diaryId).doc(commentId);

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
}
