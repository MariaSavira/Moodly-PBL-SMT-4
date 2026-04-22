import 'package:flutter/material.dart';
import '../../widgets/month_item.dart';
import '../../widgets/date_section.dart';
import '../../services/diary_service.dart';
import '../../models/diary_model.dart';
import 'diary_page.dart';

class MonthPage extends StatefulWidget {
  const MonthPage({super.key});

  @override
  State<MonthPage> createState() => _MonthPageState();
}

class _MonthPageState extends State<MonthPage> {
  bool isMonthMode = true;
  int selectedIndex = 2;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDCE3C1),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

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

              Row(
                children: [
                  _circleIcon(Icons.tune),
                  const SizedBox(width: 10),
                  Expanded(child: _toggle()),
                  const SizedBox(width: 10),
                  _circleIcon(Icons.search),
                ],
              ),

              const SizedBox(height: 25),

              Text(
                isMonthMode ? "2025" : "Pekan Ini",
                style: Theme.of(context).textTheme.headlineLarge,
              ),

              const SizedBox(height: 20),

              Expanded(child: isMonthMode ? _monthGrid() : _weekList()),
            ],
          ),
        ),
      ),
    );
  }

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
              MaterialPageRoute(builder: (_) => DiaryPage(month: months[i])),
            );
          },
        );
      },
    );
  }

  Widget _weekList() {
    final data = DiaryService.getByWeek();

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

  Widget _circleIcon(IconData icon) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: const Color(0xFFF4B6C2),
      child: Icon(icon, color: Colors.black),
    );
  }
}
