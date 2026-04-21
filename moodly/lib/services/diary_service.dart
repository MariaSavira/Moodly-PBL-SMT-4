import '../models/diary_model.dart';

class DiaryService {
  final List<DiaryModel> _storage = [];

  List<DiaryModel> get all => List.unmodifiable(_storage);

  List<DiaryModel> getByMonthAndYear(int month, int year) {
    return _storage.where((d) => d.month == month && d.year == year).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<DiaryModel> getByCurrentWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final end = start.add(const Duration(days: 6, hours: 23, minutes: 59));
    return _storage
        .where((d) => d.createdAt.isAfter(start) && d.createdAt.isBefore(end))
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void add(String title, String content) {
    _storage.add(
      DiaryModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        content: content,
      ),
    );
  }

  void delete(String id) => _storage.removeWhere((d) => d.id == id);
  void deleteMultiple(List<String> ids) =>
      _storage.removeWhere((d) => ids.contains(d.id));
}
