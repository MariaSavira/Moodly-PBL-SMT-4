import 'package:cloud_firestore/cloud_firestore.dart';

class DiaryModel {
  final String id;

  /// ================= UID =================
  final String uid;

  final String title;
  final String content;

  final String time;
  final int date;
  final String month;
  final int year;

  final bool isPublic;

  final String username;

  /// ================= IMAGE =================
  final String imageUrl;
  final String profileImage;

  /// MULTI IMAGE
  final List<String> images;

  final DateTime createdAt;

  final List<String> likedBy;

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
    required this.imageUrl,
    required this.profileImage,
    required this.images,
    required this.createdAt,
    required this.likedBy,
    this.likes = 0,
    this.comments = 0,
    this.isLiked = false,
  });

  factory DiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    final rawImages = data['images'];
    final parsedImages = rawImages is List
        ? rawImages.map((e) => e.toString()).where((e) => e.isNotEmpty).toList()
        : <String>[];

    final fallbackImageUrl = data['image_url']?.toString() ?? '';
    final mergedImages = <String>[
      ...parsedImages,
      if (fallbackImageUrl.isNotEmpty && !parsedImages.contains(fallbackImageUrl))
        fallbackImageUrl,
    ];

    final createdAtRaw = data['createdAt'];

    DateTime parsedCreatedAt;
    if (createdAtRaw is Timestamp) {
      parsedCreatedAt = createdAtRaw.toDate();
    } else if (createdAtRaw is DateTime) {
      parsedCreatedAt = createdAtRaw;
    } else if (createdAtRaw is String) {
      parsedCreatedAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      parsedCreatedAt = DateTime.now();
    }

    final likedByRaw = data['likedBy'];
    final parsedLikedBy = likedByRaw is List
        ? likedByRaw.map((e) => e.toString()).toList()
        : <String>[];

    return DiaryModel(
      id: id,
      uid: data['uid']?.toString() ?? '',
      title: data['title']?.toString() ?? '',
      content: data['content']?.toString() ?? '',
      time: data['time']?.toString() ?? '',
      date: _parseInt(data['date'], fallback: 1),
      month: data['month']?.toString() ?? '',
      year: _parseInt(data['year'], fallback: DateTime.now().year),
      isPublic: data['isPublic'] == true,
      username: data['username']?.toString() ?? 'Anonymous',
      imageUrl: fallbackImageUrl,
      profileImage: data['profileImage']?.toString() ?? '',
      images: mergedImages,
      likes: _parseInt(data['likes'], fallback: 0),
      comments: _parseInt(data['comments'], fallback: 0),
      likedBy: parsedLikedBy,
      createdAt: parsedCreatedAt,
      isLiked: false,
    );
  }

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
      "image_url": imageUrl.isNotEmpty
          ? imageUrl
          : (images.isNotEmpty ? images.first : ""),
      "profileImage": profileImage,
      "images": images,
      "likes": likes,
      "comments": comments,
      "likedBy": likedBy,
      "createdAt": Timestamp.fromDate(createdAt),
    };
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
    String? imageUrl,
    String? profileImage,
    List<String>? images,
    DateTime? createdAt,
    List<String>? likedBy,
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
      imageUrl: imageUrl ?? this.imageUrl,
      profileImage: profileImage ?? this.profileImage,
      images: images ?? this.images,
      createdAt: createdAt ?? this.createdAt,
      likedBy: likedBy ?? this.likedBy,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      isLiked: isLiked ?? this.isLiked,
    );
  }

  bool get hasImages => images.isNotEmpty;

  String get coverImage =>
      images.isNotEmpty ? images.first : imageUrl;

  static int _parseInt(dynamic value, {required int fallback}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }
}