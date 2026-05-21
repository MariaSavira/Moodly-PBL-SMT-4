// lib/models/diary_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;

  // ================= UID =================
  final String uid;

  final String title;
  final String content;

  final String time;
  final int date;
  final String month;
  final int year;

  final bool isPublic;

  final String username;

  // ================= IMAGE =================
  final String imageUrl;
  final String profileImage;

  /// MULTI IMAGE
  final List<String> images;

  final DateTime createdAt;

  final List likedBy;

  int likes;
  int comments;
  bool isLiked;

  DiaryModel({
    required this.id,

    // ================= UID =================
    this.uid = '',

    required this.title,
    required this.content,

    required this.time,
    required this.date,
    required this.month,
    required this.year,

    required this.isPublic,

    required this.username,

    // ================= IMAGE =================
    required this.imageUrl,
    required this.profileImage,

    /// MULTI IMAGE
    required this.images,

    required this.createdAt,
    required this.likedBy,

    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiaryModel(
      id: id,

      // ================= UID =================
      uid: data['uid']?.toString() ?? '',

      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',

      time: data['time']?.toString() ?? '',

      date: data['date'] ?? 1,

      month: data['month']?.toString() ?? '',

      year: data['year'] ?? 2025,

      isPublic: data['isPublic'] ?? false,

      username: data['username']?.toString() ?? 'Anonymous',

      // ================= IMAGE =================
      imageUrl: data['image_url']?.toString() ?? '',

      profileImage: data['profileImage']?.toString() ?? '',

      /// MULTI IMAGE
      images: List<String>.from(data['images'] ?? []),

      likes: data['likes'] ?? 0,

      comments: data['comments'] ?? 0,

      likedBy: data['likedBy'] ?? [],

      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // ================= TO MAP =================

  Map<String, dynamic> toMap() {
    return {
      "id": id,
      "uid": uid,

      "title": title,
      "content": content,

      "time": time,
      "date": date,
      "month": month,
      "year": year,

      "isPublic": isPublic,

      "username": username,

      // ================= IMAGE =================
      "image_url": imageUrl,
      "profileImage": profileImage,

      /// MULTI IMAGE
      "images": images,

      "likes": likes,
      "comments": comments,

      "likedBy": likedBy,

      "createdAt": createdAt,
    };
  }
}
