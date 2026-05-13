class PublicDiaryModel {
  final String id;
  final String title;
  final String content;
  final String username;

  final String time;
  final int date;
  final String month;
  final int year;

  final int likes;
  final int comments;

  final DateTime createdAt;

  PublicDiaryModel({
    required this.id,
    required this.title,
    required this.content,
    required this.username,
    required this.time,
    required this.date,
    required this.month,
    required this.year,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory PublicDiaryModel.fromFirestore(String id, Map<String, dynamic> data) {
    return PublicDiaryModel(
      id: id,
      title: data["title"] ?? "",
      content: data["content"] ?? "",
      username: data["username"] ?? "Unknown",

      time: data["time"] ?? "",

      date: data["date"] ?? 1,
      month: data["month"] ?? "",
      year: data["year"] ?? DateTime.now().year,

      likes: data["likes"] ?? 0,
      comments: data["comments"] ?? 0,

      createdAt: (data["createdAt"] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
