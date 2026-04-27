import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MoodCalendar.dart';

class MoodYearCalendar extends StatefulWidget {
  const MoodYearCalendar({super.key});

  @override
  State<MoodYearCalendar> createState() => _MoodYearCalendarState();
}

class _MoodYearCalendarState extends State<MoodYearCalendar> {
  int _selectedYear = 2026;
  bool _showYearDropdown = false;
  final List<int> _availableYears = [2020, 2021, 2022, 2023, 2024, 2025, 2026];

  final Map<String, Map<String, String>> _moodDatabase = {
    '2026': {
      '1-5': 'Senang', '1-15': 'Sedih', '1-20': 'Netral', '1-25': 'Marah',
      '2-1': 'Netral', '2-14': 'Senang', '2-17': 'Sedih', '2-18': 'Marah', '2-19': 'Sedih', '2-22': 'Netral',
      '3-5': 'Senang', '3-10': 'Sedih', '3-12': 'Marah', '3-15': 'Marah', '3-18': 'Senang', '3-20': 'Senang', '3-25': 'Netral', '3-30': 'Senang',
      '4-1': 'Senang', '4-5': 'Netral', '4-10': 'Sedih',
    },
    '2025': {
      '1-10': 'Senang', '1-20': 'Netral', '1-25': 'Sedih',
      '2-14': 'Senang', '2-20': 'Marah',
      '3-5': 'Netral', '3-15': 'Senang', '3-25': 'Sedih',
      '4-10': 'Senang', '4-20': 'Netral',
      '5-5': 'Marah', '5-15': 'Senang',
      '6-1': 'Netral', '6-15': 'Sedih',
      '7-4': 'Senang', '7-20': 'Netral',
      '8-10': 'Marah', '8-25': 'Senang',
      '9-5': 'Netral', '9-15': 'Sedih',
      '10-10': 'Senang', '10-20': 'Netral',
      '11-1': 'Marah', '11-15': 'Senang',
      '12-25': 'Netral', '12-31': 'Senang',
    },
    '2024': {
      '1-1': 'Senang', '1-15': 'Netral', '1-30': 'Sedih',
      '2-14': 'Marah', '2-28': 'Senang',
      '3-10': 'Netral', '3-20': 'Sedih',
      '4-5': 'Senang', '4-15': 'Netral',
      '5-1': 'Marah', '5-20': 'Senang',
      '6-15': 'Netral', '6-30': 'Sedih',
      '7-4': 'Senang', '7-20': 'Netral',
      '8-10': 'Marah', '8-25': 'Senang',
      '9-5': 'Netral', '9-15': 'Sedih',
      '10-10': 'Senang', '10-20': 'Netral',
      '11-1': 'Marah', '11-15': 'Senang',
      '12-25': 'Netral', '12-31': 'Senang',
    },
    '2023': {
      '1-5': 'Senang', '1-20': 'Netral',
      '2-10': 'Sedih', '2-25': 'Marah',
      '3-1': 'Senang', '3-15': 'Netral', '3-30': 'Sedih',
      '4-10': 'Marah', '4-20': 'Senang',
      '5-5': 'Netral', '5-15': 'Sedih',
      '6-1': 'Senang', '6-20': 'Netral',
      '7-4': 'Marah', '7-15': 'Senang',
      '8-10': 'Netral', '8-25': 'Sedih',
      '9-5': 'Marah', '9-15': 'Senang',
      '10-10': 'Netral', '10-20': 'Sedih',
      '11-1': 'Marah', '11-15': 'Senang',
      '12-25': 'Netral', '12-31': 'Senang',
    },
    '2022': {
      '1-1': 'Senang', '1-15': 'Netral', '1-30': 'Sedih',
      '2-14': 'Marah', '2-28': 'Senang',
      '3-10': 'Netral', '3-20': 'Sedih',
      '4-5': 'Senang', '4-15': 'Netral',
      '5-1': 'Marah', '5-20': 'Senang',
      '6-15': 'Netral', '6-30': 'Sedih',
      '7-4': 'Senang', '7-20': 'Netral',
      '8-10': 'Marah', '8-25': 'Senang',
      '9-5': 'Netral', '9-15': 'Sedih',
      '10-10': 'Senang', '10-20': 'Netral',
      '11-1': 'Marah', '11-15': 'Senang',
      '12-25': 'Netral', '12-31': 'Senang',
    },
  };

  final List<String> _monthNames = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  final List<String> _weekDays = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];

  String _getEmoji(String? mood) {
    if (mood == null) return '';
    switch (mood) {
      case 'Senang': return '😊';
      case 'Netral': return '😐';
      case 'Sedih': return '😔';
      case 'Marah': return '😠';
      default: return '😐';
    }
  }

  Color? _getMoodColor(String? mood) {
    if (mood == null) return null;
    switch (mood) {
      case 'Senang': return Colors.green.shade100;
      case 'Netral': return Colors.grey.shade200;
      case 'Sedih': return Colors.blue.shade100;
      case 'Marah': return Colors.red.shade100;
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
    );
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
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
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
        // Card Tahun
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
        // Tombol Dropdown
        GestureDetector(
          onTap: () {
            setState(() {
              _showYearDropdown = !_showYearDropdown;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(6), // Padding diperkecil
            decoration: BoxDecoration(
              // Ubah warna berdasarkan status dropdown (terbuka/tertutup)
              color: _showYearDropdown ? Colors.green : Colors.lightGreen.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _showYearDropdown ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              // Ubah warna ikon agar kontras dengan background
              color: _showYearDropdown ? Colors.white : Colors.green.shade800,
              size: 20, // Ikon diperkecil
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