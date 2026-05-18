import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  String id;

  String diaryId;

  String username;

  String profileImage;

  String comment;

  DateTime createdAt;

  int likes;

  bool isLiked;

  // REPLY
  List<CommentReplyModel> replies;

  CommentModel({
    required this.id,
    required this.diaryId,
    required this.username,
    required this.profileImage,
    required this.comment,
    required this.createdAt,
    required this.likes,
    required this.replies,

    this.isLiked = false,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentModel(
      id: doc.id,

      diaryId: data["diary_id"] ?? "",

      username: data["username"] ?? "",

      profileImage: data["profile_image"] ?? "",

      comment: data["comment"] ?? "",

      createdAt: (data["created_at"] as Timestamp).toDate(),

      likes: data["likes"] ?? 0,

      replies: (data["replies"] as List<dynamic>? ?? [])
          .map((reply) => CommentReplyModel.fromMap(reply))
          .toList(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "diary_id": diaryId,

      "username": username,

      "profile_image": profileImage,

      "comment": comment,

      "created_at": FieldValue.serverTimestamp(),

      "likes": likes,

      "replies": replies.map((e) => e.toMap()).toList(),
    };
  }
}

// =========================
// REPLY MODEL
// =========================

class CommentReplyModel {
  String username;

  String profileImage;

  String reply;

  DateTime createdAt;

  int likes;

  bool isLiked;

  CommentReplyModel({
    required this.username,
    required this.profileImage,
    required this.reply,
    required this.createdAt,
    required this.likes,

    this.isLiked = false,
  });

  factory CommentReplyModel.fromMap(Map<String, dynamic> data) {
    return CommentReplyModel(
      username: data["username"] ?? "",

      profileImage: data["profile_image"] ?? "",

      reply: data["reply"] ?? "",

      createdAt: (data["created_at"] as Timestamp).toDate(),

      likes: data["likes"] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "username": username,

      "profile_image": profileImage,

      "reply": reply,

      "created_at": FieldValue.serverTimestamp(),

      "likes": likes,
    };
  }
}
