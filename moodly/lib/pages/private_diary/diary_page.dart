import 'package:flutter/material.dart';
import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';
import '../../widgets/shared/moodly_app_bar.dart';
import '../../core/styles/moodly_colors.dart';
import 'add_diary_page.dart';

class DiaryPage extends StatelessWidget {
  final String month;
  final int year;

  const DiaryPage({super.key, required this.month, required this.year});

  String getMonthName(String m) {
    const map = {
      "JAN": "Januari",
      "FEB": "Februari",
      "MAR": "Maret",
      "APR": "April",
      "MEI": "Mei",
      "JUN": "Juni",
      "JUL": "Juli",
      "AGS": "Agustus",
      "SEP": "September",
      "OKT": "Oktober",
      "NOV": "November",
      "DES": "Desember",
    };

    return map[m] ?? m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,

      appBar: moodlyAppBar(context, "${getMonthName(month)} $year"),

      floatingActionButton: FloatingActionButton(
        backgroundColor: MoodlyColors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddDiaryPage()),
          );
        },
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: StreamBuilder<List<DiaryModel>>(
          stream: FirestoreDiaryService().getPrivateDiaries(month, year),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return const Center(child: Text("Belum ada diary di bulan ini"));
            }

            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final diary = data[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),

                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: MoodlyColors.greenLight),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TITLE
                      Text(
                        diary.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 6),

                      /// CONTENT
                      Text(
                        diary.content,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),

                      const SizedBox(height: 10),

                      /// DATE
                      Text(
                        "${diary.date} ${diary.month} ${diary.year}",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: MoodlyColors.textGray,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
