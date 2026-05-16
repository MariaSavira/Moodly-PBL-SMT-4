import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import 'diary_card.dart';

class DateSection extends StatelessWidget {
  final int date;
  final List<DiaryModel> entries;

  const DateSection({super.key, required this.date, required this.entries});

  /// ================= HARI =================
  String getDayName(int day) {
    switch (day % 7) {
      case 1:
        return "Sen";
      case 2:
        return "Sel";
      case 3:
        return "Rab";
      case 4:
        return "Kam";
      case 5:
        return "Jum";
      case 6:
        return "Sab";
      case 0:
        return "Min";
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final firstDiary = entries.first;

    final dayName = getDayName(firstDiary.date);

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          /// TANGGAL
          Column(
            children: [
              Text("$date", style: Theme.of(context).textTheme.headlineLarge),

              Text(dayName, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),

          const SizedBox(width: 15),

          /// LIST DIARY
          Expanded(
            child: Column(
              children: entries.map((e) {
                return DiaryCard(title: e.title, time: e.time);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
