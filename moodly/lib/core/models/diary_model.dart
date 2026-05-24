// lib/models/diary_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;
  final String uid;
  final String title;
  final String content;
  final List<String> images;

  final String time;
  final int date;
  final String month;
  final int year;

  final bool isPublic;

  final String username;
  final String profileImage;

  final DateTime createdAt;
  final List likedBy;

  int likes;
  int comments;
  bool isLiked;

  DiaryModel({
    required this.id,
    required this.uid,
    required this.title,
    required this.content,
    required this.images,

    required this.time,
    required this.date,
    required this.month,
    required this.year,

    required this.isPublic,

    required this.username,
    required this.profileImage,

    required this.createdAt,
    required this.likedBy,

    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiaryModel(
      id: id,
      uid: data['uid'] ?? '',
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      images: List<String>.from(data['images'] ?? []),

      time: data['time'] ?? '',
      date: data['date'] ?? 1,
      month: data['month'] ?? '',
      year: data['year'] ?? 2025,

      isPublic: data['isPublic'] ?? false,

      username: data['username'] ?? 'Anonymous',
      profileImage: data['profileImage'] ?? '',

      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,

      likedBy: data['likedBy'] ?? [],

      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
