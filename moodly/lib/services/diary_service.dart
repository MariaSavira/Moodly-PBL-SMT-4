import '../models/diary_model.dart';

class DiaryService {
  static List<DiaryModel> allData = [
    DiaryModel(
      title: "Perasaan Hari Ini",
      time: "01.17 pm",
      date: 17,
      month: "MAR",
    ),
    DiaryModel(
      title: "Hari Ini Berarti",
      time: "09.27 pm",
      date: 17,
      month: "MAR",
    ),
    DiaryModel(
      title: "Mencari Versi Baik",
      time: "08.00 am",
      date: 18,
      month: "MAR",
    ),
    DiaryModel(
      title: "Belajar Ikhlas",
      time: "10.00 am",
      date: 19,
      month: "MAR",
    ),
  ];

  static List<DiaryModel> getByMonth(String month) {
    return allData.where((e) => e.month == month).toList();
  }

  static List<DiaryModel> getByWeek() {
    return allData; // dummy minggu ini
  }
}
