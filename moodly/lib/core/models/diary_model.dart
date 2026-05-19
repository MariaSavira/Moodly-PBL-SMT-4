// lib/models/diary_model.dart

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

  int likes;
  int comments;
  bool isLiked;

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
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DiaryModel(
      id: id,
      title: data['title'] ?? '',
      content: data['content'] ?? '',
      time: data['time'] ?? '',
      date: data['date'] ?? 1,
      month: data['month'] ?? '',
      year: data['year'] ?? 2025,
      isPublic: data['isPublic'] ?? false,
      username: data['username'] ?? '',
      profileImage: data['profileImage'] ?? '',
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
    );
  }
}
