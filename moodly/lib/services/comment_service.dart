import 'package:cloud_firestore/cloud_firestore.dart';

class CommentService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

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

  static Stream<QuerySnapshot> getComments(String diaryId) {
    return _db
        .collection("public_diary")
        .doc(diaryId)
        .collection("comments")
        .orderBy("created_at", descending: true)
        .snapshots();
  }

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
}
