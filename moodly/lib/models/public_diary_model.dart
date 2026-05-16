class PublicDiaryModel {
  String id;
  String username;
  String text;
  String profileImage;

  bool hasImage;

  int likes;
  int comments;

  bool isLiked;

  DateTime createdAt;

  PublicDiaryModel({
    required this.id,
    required this.username,
    required this.text,
    required this.profileImage,
    required this.hasImage,
    required this.likes,
    required this.comments,
    required this.createdAt,

    this.isLiked = false,
  });
}
