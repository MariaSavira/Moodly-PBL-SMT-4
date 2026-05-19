import 'package:flutter/material.dart';
import '../../widgets/month_item.dart';
import '../../services/firestore_diary_service.dart';
import '../../models/diary_model.dart';
import '../../widgets/shared/moodly_app_bar.dart';
import '../../core/styles/moodly_colors.dart';
import 'diary_page.dart';
import 'add_diary_page.dart';
import 'search_page.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  bool isMonthMode = true;

  int selectedIndex = -1;
  int selectedYear = DateTime.now().year;

  bool showYearFilter = false;

  final months = [
    "JAN",
    "FEB",
    "MAR",
    "APR",
    "MEI",
    "JUN",
    "JUL",
    "AGS",
    "SEP",
    "OKT",
    "NOV",
    "DES",
  ];

  List<int> getYears() {
    final currentYear = DateTime.now().year;
    const startYear = 2024;
    return List.generate(currentYear - startYear + 1, (i) => startYear + i);
  }

  String getTitle() {
    if (selectedIndex < 0) return "Diary Privat";
    return "${months[selectedIndex]} $selectedYear";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      appBar: moodlyAppBar(context, "Diary Privat"),

      floatingActionButton: !isMonthMode
          ? FloatingActionButton(
              backgroundColor: MoodlyColors.green,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddDiaryPage()),
                );
              },
              child: const Icon(Icons.add),
            )
          : null,

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                const SizedBox(height: 10),

                /// TOGGLE + SEARCH
                Row(
                  children: [
                    Expanded(child: _toggle()),
                    const SizedBox(width: 10),
                    _searchButton(),
                  ],
                ),

                const SizedBox(height: 20),

                /// TITLE
                Text(
                  getTitle(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 20),

                /// CONTENT
                Expanded(child: isMonthMode ? _monthGrid() : _weekContent()),
              ],
            ),
          ),

          if (showYearFilter) _yearFilter(),
        ],
      ),
    );
  }

  // ================= TOGGLE =================
  Widget _toggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: MoodlyColors.pinkLight,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMonthMode = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isMonthMode ? MoodlyColors.pinkAccent : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: Text("Bulan")),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMonthMode = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isMonthMode ? MoodlyColors.pinkAccent : null,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Center(child: Text("Pekan")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= MONTH GRID =================
  Widget _monthGrid() {
    return GridView.builder(
      itemCount: months.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        return MonthItem(
          label: months[i],
          isSelected: selectedIndex == i,
          onTap: () {
            setState(() => selectedIndex = i);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DiaryPage(month: months[i], year: selectedYear),
              ),
            );
          },
        );
      },
    );
  }

  // ================= WEEK CONTENT =================
  Widget _weekContent() {
    return StreamBuilder<List<DiaryModel>>(
      stream: FirestoreDiaryService.getWeekDiaries(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? [];

        if (data.isEmpty) {
          return const Center(child: Text("Belum ada diary minggu ini"));
        }

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (_, i) {
            final d = data[i];

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    d.title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(d.content, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= SEARCH =================
  Widget _searchButton() {
    return IconButton(
      icon: const Icon(Icons.search),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
    );
  }

  // ================= YEAR FILTER =================
  Widget _yearFilter() {
    final years = getYears();

    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: MoodlyColors.bgLight,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Wrap(
          spacing: 10,
          children: years.map((y) {
            return ChoiceChip(
              label: Text("$y"),
              selected: y == selectedYear,
              onSelected: (_) => setState(() => selectedYear = y),
            );
          }).toList(),
        ),
      ),
    );
  }
}
