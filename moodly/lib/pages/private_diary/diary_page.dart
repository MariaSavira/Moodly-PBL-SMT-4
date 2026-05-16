import 'package:flutter/material.dart';

import '../../models/diary_model.dart';
import '../../services/firestore_diary_service.dart';

import 'package:moodly/pages/private_diary/add_diary_page.dart';

class DiaryPage extends StatelessWidget {
  final String month;
  final int year;

  const DiaryPage({super.key, required this.month, required this.year});

  /// ================= MONTH NAME =================
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

  /// ================= MONTH NUMBER =================
  int getMonthNumber(String m) {
    const map = {
      "JAN": 1,
      "FEB": 2,
      "MAR": 3,
      "APR": 4,
      "MEI": 5,
      "JUN": 6,
      "JUL": 7,
      "AGS": 8,
      "SEP": 9,
      "OKT": 10,
      "NOV": 11,
      "DES": 12,
    };

    return map[m] ?? DateTime.now().month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final selectedMonth = getMonthNumber(month);
    final selectedYear = year;

    final currentMonth = now.month;
    final currentYear = now.year;

    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

      floatingActionButton:
          (selectedYear == currentYear && selectedMonth == currentMonth)
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7FB77E),

              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDiaryPage()),
                );
              },

              child: const Icon(Icons.add, color: Colors.black),
            )
          : null,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const SizedBox(height: 10),

              /// HEADER
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),

                    child: const Icon(Icons.arrow_back),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "Private Diary",

                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// TITLE
              Text(
                "${getMonthName(month)} $year",

                style: Theme.of(context).textTheme.titleMedium,
              ),

              const SizedBox(height: 20),

              /// FIREBASE
              Expanded(
                child: StreamBuilder<List<DiaryModel>>(
                  stream: FirestoreDiaryService().getPrivateDiaries(
                    month,
                    year,
                  ),

                  builder: (context, snapshot) {
                    /// LOADING
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    /// ERROR
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          "Terjadi error",

                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      );
                    }

                    final data = snapshot.data ?? [];

                    /// FUTURE
                    if (selectedYear > currentYear ||
                        (selectedYear == currentYear &&
                            selectedMonth > currentMonth)) {
                      return _centerMessage(
                        context,
                        "Belum waktunya 😶",
                        "Kamu belum bisa menulis diary di waktu ini.",
                      );
                    }

                    /// EMPTY
                    if (data.isEmpty) {
                      return _emptyCurrentMonth(context);
                    }

                    return _buildList(data);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= LIST =================
  Widget _buildList(List<DiaryModel> data) {
    return ListView.builder(
      itemCount: data.length,

      itemBuilder: (context, index) {
        final diary = data[index];

        return Container(
          margin: const EdgeInsets.only(bottom: 12),

          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            color: Colors.white,

            borderRadius: BorderRadius.circular(20),
          ),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                diary.title,

                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(diary.content, maxLines: 3, overflow: TextOverflow.ellipsis),

              const SizedBox(height: 12),

              Text(
                "${diary.date} ${diary.month} ${diary.year}",

                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        );
      },
    );
  }

  /// ================= EMPTY =================
  Widget _emptyCurrentMonth(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const Icon(Icons.edit_note, size: 60, color: Colors.grey),

          const SizedBox(height: 15),

          Text(
            "Belum ada diary",

            style: Theme.of(context).textTheme.titleMedium,
          ),

          const SizedBox(height: 5),

          Text(
            "Mulai tulis cerita harimu sekarang ✨",

            style: Theme.of(context).textTheme.bodyMedium,
          ),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddDiaryPage()),
              );
            },

            icon: const Icon(Icons.add),

            label: const Text("Tulis Diary"),
          ),
        ],
      ),
    );
  }

  /// ================= MESSAGE =================
  Widget _centerMessage(BuildContext context, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          const Icon(Icons.lock_outline, size: 60, color: Colors.grey),

          const SizedBox(height: 15),

          Text(title, style: Theme.of(context).textTheme.titleMedium),

          const SizedBox(height: 5),

          Text(
            subtitle,

            style: Theme.of(context).textTheme.bodyMedium,

            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}