// lib/models/comment_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class CommentModel {
  final String id;
  final String username;
  final String profileImage;
  final String comment;
  final int likes;
  final List replies;
  final Timestamp createdAt;

  CommentModel({
    required this.id,
    required this.username,
    required this.profileImage,
    required this.comment,
    required this.likes,
    required this.replies,
    required this.createdAt,
  });

  factory CommentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CommentModel(
      id: doc.id,
      username: data['username'] ?? '',
      profileImage: data['profile_image'] ?? '',
      comment: data['comment'] ?? '',
      likes: data['likes'] ?? 0,
      replies: data['replies'] ?? [],
      createdAt: data['created_at'] ?? Timestamp.now(),
    );
  }
}
