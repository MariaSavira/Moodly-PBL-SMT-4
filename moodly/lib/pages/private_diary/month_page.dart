import 'package:flutter/material.dart';
import '../../widgets/month_item.dart';
import '../../widgets/date_section.dart';
import '../../services/diary_service.dart';
import '../../models/diary_model.dart';
import 'diary_page.dart';
import 'add_diary_page.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  bool isMonthMode = true;
  int selectedIndex = 2;

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

  /// ================= GENERATE YEAR =================
  List<int> getYears() {
    int currentYear = DateTime.now().year;
    return List.generate(6, (i) => currentYear - (5 - i));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

      /// FAB (ONLY WEEK)
      floatingActionButton: !isMonthMode
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
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// HEADER
                  Row(
                    children: [
                      const Icon(Icons.arrow_back),
                      const SizedBox(width: 10),
                      Text(
                        "Private Diary",
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// TOGGLE + FILTER
                  Row(
                    children: [
                      _filterButton(),
                      const SizedBox(width: 10),
                      Expanded(child: _toggle()),
                      const SizedBox(width: 10),
                      _circleIcon(Icons.search),
                    ],
                  ),

                  const SizedBox(height: 25),

                  /// TITLE
                  Text(
                    isMonthMode ? "$selectedYear" : "Pekan Ini",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 20),

                  /// CONTENT
                  Expanded(child: isMonthMode ? _monthGrid() : _weekContent()),
                ],
              ),
            ),

            /// FILTER POPUP
            if (showYearFilter) _yearFilter(),
          ],
        ),
      ),
    );
  }

  /// ================= MONTH GRID =================
  Widget _monthGrid() {
    return GridView.builder(
      itemCount: months.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
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

  /// ================= WEEK =================
  Widget _weekContent() {
    final data = DiaryService.getByWeek();

    if (data.isEmpty) {
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
              "Kamu belum menulis diary di minggu ini",
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
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

    final Map<int, List<DiaryModel>> grouped = {};

    for (var d in data) {
      grouped.putIfAbsent(d.date, () => []).add(d);
    }

    return ListView(
      children: grouped.entries.map((e) {
        return DateSection(date: e.key, entries: e.value);
      }).toList(),
    );
  }

  /// ================= TOGGLE =================
  Widget _toggle() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFFF4B6C2),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMonthMode = true),
              child: Container(
                decoration: BoxDecoration(
                  color: isMonthMode
                      ? const Color(0xFFE89AAE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Bulan",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isMonthMode = false),
              child: Container(
                decoration: BoxDecoration(
                  color: !isMonthMode
                      ? const Color(0xFFE89AAE)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Center(
                  child: Text(
                    "Pekan",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= FILTER BUTTON =================
  Widget _filterButton() {
    return GestureDetector(
      onTap: () {
        setState(() => showYearFilter = true);
      },
      child: CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFF4B6C2),
        child: const Icon(Icons.tune, color: Colors.black),
      ),
    );
  }

  /// ================= FILTER UI =================
  Widget _yearFilter() {
    final years = getYears();

    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFFA8D5A2),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.pink),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tahun", style: Theme.of(context).textTheme.titleMedium),

            const SizedBox(height: 20),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: years.map((year) {
                final isSelected = year == selectedYear;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedYear = year);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFFF4B6C2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white),
                    ),
                    child: Text(
                      "$year",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () {
                  setState(() => showYearFilter = false);
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF4B6C2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ICON =================
  Widget _circleIcon(IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF4B6C2),
      child: Icon(icon, color: Colors.black),
    );
  }
}
