import 'package:flutter/material.dart';
import '../../widgets/month_item.dart';
import '../../services/firestore_diary_service.dart';
import '../../models/diary_model.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),

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

                  const SizedBox(height: 20),

                  /// FILTER + TOGGLE + SEARCH
                  Row(
                    children: [
                      _filterButton(),
                      const SizedBox(width: 10),
                      Expanded(child: _toggle()),
                      const SizedBox(width: 10),
                      _searchButton(),
                    ],
                  ),

                  const SizedBox(height: 25),

                  Text(
                    isMonthMode ? "$selectedYear" : "Pekan Ini",
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),

                  const SizedBox(height: 20),

                  Expanded(child: isMonthMode ? _monthGrid() : _weekContent()),
                ],
              ),
            ),

            if (showYearFilter) _yearFilter(),
          ],
        ),
      ),
    );
  }

  // ================= MONTH GRID =================
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

  // ================= WEEK (FIXED STREAM SAFETY) =================
  Widget _weekContent() {
    return StreamBuilder<List<DiaryModel>>(
      stream: FirestoreDiaryService().getWeekDiaries(),

      builder: (context, snapshot) {
        /// LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        /// ERROR (FIX: tampilkan error asli)
        if (snapshot.hasError) {
          debugPrint("🔥 FIRESTORE ERROR: ${snapshot.error}");

          return Center(
            child: Text(
              "Error: ${snapshot.error}",
              textAlign: TextAlign.center,
            ),
          );
        }

        final data = snapshot.data ?? [];

        /// EMPTY STATE
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

        /// LIST DATA
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diary.content,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "${diary.date} ${diary.month} ${diary.year}",
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ================= TOGGLE =================
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
                child: const Center(child: Text("Bulan")),
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
                child: const Center(child: Text("Pekan")),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= FILTER =================
  Widget _filterButton() {
    return GestureDetector(
      onTap: () => setState(() => showYearFilter = true),
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFFF4B6C2),
        child: Icon(Icons.tune, color: Colors.black),
      ),
    );
  }

  // ================= SEARCH =================
  Widget _searchButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SearchPage()),
        );
      },
      child: const CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFFF4B6C2),
        child: Icon(Icons.search, color: Colors.black),
      ),
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
          color: const Color(0xFFDCE3C1),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: const Color(0xFF7FB77E)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Tahun", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 15),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: years.map((year) {
                final isSelected = year == selectedYear;

                return GestureDetector(
                  onTap: () => setState(() => selectedYear = year),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF7FB77E)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF7FB77E)),
                    ),
                    child: Text(
                      "$year",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => setState(() => showYearFilter = false),
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
}