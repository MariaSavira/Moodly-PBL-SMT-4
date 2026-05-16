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
    );
  }
}
