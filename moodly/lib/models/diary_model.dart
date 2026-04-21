class DiaryModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;

  // Formatting manual pakai fitur bawaan Dart
  String get date => createdAt.day.toString().padLeft(2, '0');
  String get time =>
      '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';

  String get dayName {
    const days = ['', 'SEN', 'SEL', 'RAB', 'KAM', 'JUM', 'SAB', 'MIN'];
    return days[createdAt.weekday];
  }

  String get monthName {
    const months = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return months[createdAt.month];
  }

  int get year => createdAt.year;
  int get month => createdAt.month;

  DiaryModel({
    required this.id,
    required this.title,
    required this.content,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}
