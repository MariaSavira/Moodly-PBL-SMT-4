import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_calendar.dart';

class MoodYearCalendar extends StatefulWidget {
  const MoodYearCalendar({super.key});

  @override
  State<MoodYearCalendar> createState() => _MoodYearCalendarState();
}

class _MoodYearCalendarState extends State<MoodYearCalendar> {
  int _selectedYear = 2026;
  bool _showYearDropdown = false;
  bool _isLoading = true;
  final List<int> _availableYears = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  Map<String, Map<String, String>> _moodDatabase = {};

  static const String _documentId = 'BeZzql14Y8xGyoLUDb0L';

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _weekDays = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  @override
  void initState() {
    super.initState();
    _loadMoods();
  }

  Future<void> _loadMoods() async {
    Map<String, Map<String, String>> allMoods = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('mood_'));

      for (var key in keys) {
        final datePart = key.replaceFirst('mood_', '');
        final mood = prefs.getString(key);

        if (mood != null) {
          final parts = datePart.split('-');
          if (parts.length == 3) {
            final year = parts[0];
            final month = parts[1];
            final day = parts[2];

            if (!allMoods.containsKey(year)) {
              allMoods[year] = {};
            }

            final monthInt = int.parse(month);
            final dayInt = int.parse(day);
            allMoods[year]!['$monthInt-$dayInt'] = mood;
          }
        }
      }

      final doc = await FirebaseFirestore.instance
          .collection('moods')
          .doc(_documentId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final entries = data?['entries'] as Map<String, dynamic>? ?? {};

        print("✅ Loaded ${entries.length} entries from Firestore for Guest");

        entries.forEach((dateKey, moodValue) {
          final parts = dateKey.split('-');
          if (parts.length == 3) {
            final year = parts[0];
            final month = parts[1];
            final day = parts[2];

            if (!allMoods.containsKey(year)) {
              allMoods[year] = {};
            }

            final monthInt = int.parse(month);
            final dayInt = int.parse(day);
            allMoods[year]!['$monthInt-$dayInt'] = moodValue.toString();
          }
        });
      } else {
        print("⚠️ Document '$_documentId' not found in Firestore");
      }

      setState(() {
        _moodDatabase = allMoods;
        _isLoading = false;
      });

      print("📊 Total years loaded: ${_moodDatabase.keys.toList()}");

    } catch (e) {
      print("❌ Error loading moods: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Color? _getMoodColor(String? mood) {
    if (mood == null) return null;
    switch (mood) {
      case 'Senang': return const Color(0xFFA8F4AB);
      case 'Netral': return const Color(0xFFFFECB3);
      case 'Sedih': return const Color(0xFFC8E6C9);
      case 'Marah': return const Color(0xFFEF9A9A);
      default: return null;
    }
  }

  void _selectYear(int year) {
    setState(() {
      _selectedYear = year;
      _showYearDropdown = false;
    });
  }

  void _navigateToMonthDetail(int month) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodCalendar(
          initialYear: _selectedYear,
          initialMonth: month,
        ),
      ),
    ).then((_) {
      _loadMoods();
    });
  }

  bool _isCurrentMonth(int month) {
    final now = DateTime.now();
    return now.year == _selectedYear && now.month == month;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBE7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Mood Calendar',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMoods,
            tooltip: 'Refresh data',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
          )
              : SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  _buildYearSelector(),
                  const SizedBox(height: 16),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      final month = index + 1;
                      return _buildMonthCard(month);
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_showYearDropdown) _buildYearDropdownOverlay(),
        ],
      ),
    );
  }

  Widget _buildYearSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 36),
          decoration: BoxDecoration(
            color: Colors.lightGreen.shade300,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Text(
            '$_selectedYear',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: () {
            setState(() {
              _showYearDropdown = !_showYearDropdown;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _showYearDropdown ? Colors.green : Colors.lightGreen.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _showYearDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: _showYearDropdown ? Colors.white : Colors.green.shade800,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildYearDropdownOverlay() {
    return GestureDetector(
      onTap: () => setState(() => _showYearDropdown = false),
      child: Container(
        color: Colors.black.withOpacity(0.2),
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 220,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.lightGreen.shade300,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: _availableYears.map((year) {
                  final isSelected = year == _selectedYear;
                  return GestureDetector(
                    onTap: () => _selectYear(year),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.lightGreen.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: Text(
                          '$year',
                          style: GoogleFonts.fredoka(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMonthCard(int month) {
    final isCurrentMonth = _isCurrentMonth(month);

    return GestureDetector(
      onTap: () => _navigateToMonthDetail(month),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCurrentMonth ? Colors.lightGreen.shade200 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isCurrentMonth ? Border.all(color: Colors.green, width: 2) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _monthNames[month - 1],
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isCurrentMonth ? Colors.green.shade800 : Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            _buildMiniCalendar(month),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniCalendar(int month) {
    final daysInMonth = DateTime(_selectedYear, month + 1, 0).day;
    final firstDayOfWeek = DateTime(_selectedYear, month, 1).weekday;

    List<Widget> dayWidgets = [];

    for (var day in _weekDays) {
      dayWidgets.add(
        SizedBox(
          width: 28,
          child: Center(
            child: Text(
              day,
              style: GoogleFonts.fredoka(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
          ),
        ),
      );
    }

    for (int i = 1; i < firstDayOfWeek; i++) {
      dayWidgets.add(const SizedBox(width: 28, height: 28));
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final moodKey = '$month-$day';
      final mood = _moodDatabase['$_selectedYear']?[moodKey];
      final moodColor = _getMoodColor(mood);

      dayWidgets.add(
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: moodColor ?? Colors.transparent,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              '$day',
              style: GoogleFonts.fredoka(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 7,
      mainAxisSpacing: 2,
      crossAxisSpacing: 2,
      childAspectRatio: 1.0,
      children: dayWidgets,
    );
  }
}