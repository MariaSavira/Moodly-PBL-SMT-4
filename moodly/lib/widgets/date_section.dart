import 'package:flutter/material.dart';
import '../models/diary_model.dart';
import 'diary_card.dart';

class DateSection extends StatelessWidget {
  final int date;
  final List<DiaryModel> entries;

  const DateSection({super.key, required this.date, required this.entries});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Text("$date", style: Theme.of(context).textTheme.headlineLarge),
              Text("Sel", style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              children: entries
                  .map((e) => DiaryCard(title: e.title, time: e.time))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
