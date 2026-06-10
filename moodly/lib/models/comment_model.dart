import 'package:cloud_firestore/cloud_firestore.dart';

class CommentReplyModel {
  final String username;
  final String profileImage;
  final String reply;
  final int likes;
  final DateTime createdAt;
  final String uid;

  CommentReplyModel({
    required this.username,
    required this.profileImage,
    required this.reply,
    required this.likes,
    required this.createdAt,
    required this.uid,
  });

  factory CommentReplyModel.fromMap(Map<String, dynamic> data) {
    final rawCreatedAt = data['created_at'];

    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return CommentReplyModel(
      username: (data['username'] ?? '').toString(),
      profileImage: (data['profile_image'] ?? '').toString(),
      reply: (data['reply'] ?? '').toString(),
      likes: (data['likes'] ?? 0) as int,
      createdAt: parsedCreatedAt,
      uid: (data['uid'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profile_image': profileImage,
      'reply': reply,
      'likes': likes,
      'created_at': createdAt.millisecondsSinceEpoch,
      'uid': uid,
    };
  }
}

class CommentModel {
  final String id;
  final String username;
  final String profileImage;
  final String comment;
  final int likes;
  final List<CommentReplyModel> replies;
  final DateTime createdAt;
  final String uid;

  CommentModel({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.comment,
    required this.likes,
    required this.replies,
    required this.createdAt,
    required this.uid,
  });

  factory CommentModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    final rawCreatedAt = data['created_at'];

    DateTime parsedCreatedAt;
    if (rawCreatedAt is Timestamp) {
      parsedCreatedAt = rawCreatedAt.toDate();
    } else if (rawCreatedAt is int) {
      parsedCreatedAt = DateTime.fromMillisecondsSinceEpoch(rawCreatedAt);
    } else {
      parsedCreatedAt = DateTime.now();
    }

    final rawReplies = List<Map<String, dynamic>>.from(data['replies'] ?? []);

    return CommentModel(
      id: doc.id,
      username: (data['username'] ?? '').toString(),
      profileImage: (data['profile_image'] ?? '').toString(),
      comment: (data['comment'] ?? '').toString(),
      likes: (data['likes'] ?? 0) as int,
      replies: rawReplies.map(CommentReplyModel.fromMap).toList(),
      createdAt: parsedCreatedAt,
      uid: (data['uid'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'profile_image': profileImage,
      'comment': comment,
      'likes': likes,
      'replies': replies.map((e) => e.toMap()).toList(),
      'created_at': createdAt,
      'uid': uid,
    };
  }

  bool get hasReplies => replies.isNotEmpty;
}