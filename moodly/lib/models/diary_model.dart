import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;

  final String title;
  final String content;

  final String time;
  final int date;
  final String month;
  final int year;

  final bool isPublic;

  final String username;
  final String profileImage;

  // LIKE & COMMENT
  int likes;
  int comments;

  // NEW SYSTEM
  final List<String> likedBy;

  // NEW
  final DateTime createdAt;

  DiaryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.time,
    required this.date,
    required this.month,
    required this.year,
    required this.isPublic,
    required this.username,
    required this.profileImage,

    required this.createdAt,

    this.likes = 0,
    this.comments = 0,
    this.likedBy = const [],
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiaryModel(
      id: id,

      title: data["title"] ?? "",
      content: data["content"] ?? "",

      time: data["time"] ?? "",

      date: (data["date"] ?? 1) is int
          ? data["date"]
          : int.tryParse(data["date"].toString()) ?? 1,

      month: data["month"] ?? "",

      year: (data["year"] ?? DateTime.now().year) is int
          ? data["year"]
          : int.tryParse(data["year"].toString()) ?? DateTime.now().year,

      isPublic: data["isPublic"] ?? false,

      username: data["username"] ?? "Unknown",

      profileImage: data["profileImage"] ?? "",

      likes: data["likes"] ?? 0,

      comments: data["comments"] ?? 0,

      likedBy: List<String>.from(data["likedBy"] ?? []),

      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
