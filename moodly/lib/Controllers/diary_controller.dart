import '../models/diary_model.dart';
import '../services/diary_service.dart';

class DiaryController {
  final DiaryService _service = DiaryService();
  List<DiaryModel> diaries = [];
  bool isSelectionMode = false;
  Set<String> selectedIds = {};
  String viewMode = 'month'; // 'month' atau 'week'

  bool isFutureMonth(int month, int year) {
    final now = DateTime.now();
    return (year > now.year) || (year == now.year && month > now.month);
  }

  bool isCurrentMonth(int month, int year) {
    final now = DateTime.now();
    return month == now.month && year == now.year;
  }

  void loadData(int? month, int? year) {
    if (month != null && year != null) {
      diaries = _service.getByMonthAndYear(month, year);
    } else {
      diaries = _service.getByCurrentWeek();
    }
  }

  void changeViewMode(String mode) {
    viewMode = mode;
    loadData(null, null);
  }

  void deleteSingle(String id) {
    _service.delete(id);
  }

  void toggleSelectionMode() {
    isSelectionMode = !isSelectionMode;
    if (!isSelectionMode) selectedIds.clear();
  }

  void toggleSelection(String id) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
  }

  void selectAll() {
    if (selectedIds.length == diaries.length) {
      selectedIds.clear();
    } else {
      selectedIds = diaries.map((d) => d.id).toSet();
    }
  }
}
