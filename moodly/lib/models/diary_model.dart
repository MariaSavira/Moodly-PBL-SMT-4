import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;
  final String uid;

  final String title;
  final String content;

  final String time;
  final int date;
  final String month;
  final int year;

  final bool isPublic;
  final String username;
  final String mood;

  final String imageUrl;
  final String profileImage;
  final List<String> images;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final List likedBy;

  int likes;
  int comments;
  bool isLiked;

  DiaryModel({
    required this.id,
    this.uid = '',
    required this.title,
    required this.content,
    required this.time,
    required this.date,
    required this.month,
    required this.year,
    required this.isPublic,
    required this.username,
    required this.mood,
    required this.imageUrl,
    required this.profileImage,
    required this.images,
    required this.createdAt,
    this.updatedAt,
    required this.likedBy,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawImages = List<String>.from(data['images'] ?? const []);
    final rawImageUrl = data['image_url']?.toString() ?? '';

    return DiaryModel(
      id: id,
      uid: data['uid']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      date: data['date'] ?? 1,
      month: data['month']?.toString() ?? '',
      year: data['year'] ?? 2025,
      isPublic: data['isPublic'] ?? false,
      username: data['username']?.toString() ?? 'Anonymous',
      mood: data['mood']?.toString() ?? 'netral',
      imageUrl: rawImageUrl,
      profileImage: data['profileImage']?.toString() ?? '',
      images: rawImages,
      likes: data['likes'] ?? 0,
      comments: data['comments'] ?? 0,
      likedBy: List.from(data['likedBy'] ?? const []),
      createdAt: _readDateTime(
        data['createdAt'] ?? data['created_at'],
      ),
      updatedAt: _readNullableDateTime(
        data['updatedAt'] ?? data['updated_at'],
      ),
      isLiked: data['isLiked'] ?? false,
    );
  }

  DiaryModel copyWith({
    String? id,
    String? uid,
    String? title,
    String? content,
    String? time,
    int? date,
    String? month,
    int? year,
    bool? isPublic,
    String? username,
    String? mood,
    String? imageUrl,
    String? profileImage,
    List<String>? images,
    DateTime? createdAt,
    DateTime? updatedAt,
    List? likedBy,
    int? likes,
    int? comments,
    bool? isLiked,
  }) {
    return DiaryModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      title: title ?? this.title,
      content: content ?? this.content,
      time: time ?? this.time,
      date: date ?? this.date,
      month: month ?? this.month,
      year: year ?? this.year,
      isPublic: isPublic ?? this.isPublic,
      username: username ?? this.username,
      mood: mood ?? this.mood,
      imageUrl: imageUrl ?? this.imageUrl,
      profileImage: profileImage ?? this.profileImage,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likedBy: likedBy ?? this.likedBy,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  DateTime get entryDateTime {
    final parts = time.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;

    return DateTime(
      year,
      _monthNumber(month),
      date,
      hour,
      minute,
    );
  }

  bool get hasImages => images.isNotEmpty;
  bool get hasMultipleImages => images.length > 1;

  String get primaryImage {
    if (images.isNotEmpty) return images.first;
    return imageUrl;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uid': uid,
      'title': title,
      'content': content,
      'time': time,
      'date': date,
      'month': month,
      'year': year,
      'isPublic': isPublic,
      'username': username,
      'mood': mood,
      'image_url': imageUrl,
      'profileImage': profileImage,
      'images': images,
      'likes': likes,
      'comments': comments,
      'likedBy': likedBy,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime _readDateTime(dynamic raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return DateTime.now();
  }

  static DateTime? _readNullableDateTime(dynamic raw) {
    if (raw == null) return null;
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    return null;
  }

  static int _monthNumber(String code) {
    const map = {
      'JAN': 1,
      'FEB': 2,
      'MAR': 3,
      'APR': 4,
      'MEI': 5,
      'JUN': 6,
      'JUL': 7,
      'AGS': 8,
      'SEP': 9,
      'OKT': 10,
      'NOV': 11,
      'DES': 12,
    };
    return map[code.toUpperCase()] ?? 1;
  }
}