import '../models/diary_model.dart';

class DiaryService {
  static List<DiaryModel> allData = [
    DiaryModel(
      title: "Perasaan Hari Ini",
      time: "01.17 pm",
      date: 17,
      month: "MAR",
      year: 2025,
    ),
    DiaryModel(
      title: "Hari Ini Berarti",
      time: "09.27 pm",
      date: 17,
      month: "MAR",
      year: 2025,
    ),
    DiaryModel(
      title: "Mencari Versi Baik",
      time: "08.00 am",
      date: 18,
      month: "MAR",
      year: 2025,
    ),
    DiaryModel(
      title: "Belajar Ikhlas",
      time: "10.00 am",
      date: 19,
      month: "MAR",
      year: 2025,
    ),
  ];

  /// 🔥 FIX: sekarang pakai month + year
  static List<DiaryModel> getByMonth(String month, int year) {
    return allData.where((e) => e.month == month && e.year == year).toList();
  }

  /// (dummy) minggu ini
  static List<DiaryModel> getByWeek() {
    return allData;
  }
}
