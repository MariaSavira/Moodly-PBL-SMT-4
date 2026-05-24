import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ================= ADD COMMENT =================

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
          "username": username,
          "profile_image": profileImage,
          "comment": comment,

          "likes": 0,

          "created_at": FieldValue.serverTimestamp(),

          "replies": [],
        });
  }

  // ================= GET COMMENTS =================

  static Stream<QuerySnapshot> getComments(String diaryId) {
    return _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

  // ================= LIKE COMMENT =================

  static Future<void> likeComment({
    required String diaryId,
    required String commentId,
    required bool isLiked,
  }) async {
    await _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .doc(commentId)
        .update({"likes": FieldValue.increment(isLiked ? -1 : 1)});
  }

  // ================= ADD REPLY =================

  static Future<void> addReply({
    required String diaryId,
    required String commentId,
    required String username,
    required String profileImage,
    required String reply,
  }) async {
    await _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .doc(commentId)
        .update({
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

  // ================= DELETE COMMENT =================

  static Future<void> deleteComment({
    required String diaryId,
    required String commentId,
  }) async {
    try {
      await _db
          .collection("public_diary")
          .doc(diaryId)
          .collection("comments")
          .doc(commentId)
          .delete();
    } catch (e) {
      throw Exception("Gagal menghapus komentar: $e");
    }
  }

  // ================= DELETE REPLY =================

  static Future<void> deleteReply({
    required String diaryId,
    required String commentId,
    required Map<String, dynamic> replyData,
  }) async {
    try {
      await _db
          .collection("public_diary")
          .doc(diaryId)
          .collection("comments")
          .doc(commentId)
          .update({
            "replies": FieldValue.arrayRemove([replyData]),
          });
    } catch (e) {
      throw Exception("Gagal menghapus balasan: $e");
    }
  }
}
