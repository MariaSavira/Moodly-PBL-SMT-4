import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'MoodInput.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  DateTime _focusedDate = DateTime.now();

  final Map<String, String> _moodDatabase = {
    '2026-03-01': 'Senang',
    '2026-03-02': 'Netral',
    '2026-03-03': 'Senang',
    '2026-03-04': 'Senang',
    '2026-03-05': 'Netral',
    '2026-03-06': 'Netral',
    '2026-03-07': 'Sedih',
    '2026-03-08': 'Senang',
    '2026-03-09': 'Senang',
    '2026-03-10': 'Sedih',
    '2026-03-11': 'Sedih',
    '2026-03-12': 'Marah',
    '2026-03-13': 'Sedih',
    '2026-03-14': 'Marah',
    '2026-03-15': 'Marah',
    '2026-03-16': 'Sedih',
    '2026-03-17': 'Marah',
    '2026-03-18': 'Senang',
    '2026-03-19': 'Senang',
    '2026-03-20': 'Senang',
    '2026-03-21': 'Senang',
    '2026-03-22': 'Netral',
    '2026-03-23': 'Senang',
    '2026-03-24': 'Netral',
    '2026-03-25': 'Netral',
    '2026-03-26': 'Senang',
    '2026-03-27': 'Netral',
    '2026-03-28': 'Sedih',
    '2026-03-29': 'Senang',
    '2026-03-30': 'Senang',
    '2026-03-31': 'Senang',
    '2026-04-01': 'Senang',
    '2026-04-05': 'Netral',
    '2026-04-10': 'Sedih',
  };

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

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

  void _changeMonth(int offset) {
    setState(() {
      _focusedDate = DateTime(_focusedDate.year, _focusedDate.month + offset, 1);
    });
  }

  void _handleDateTap(DateTime date) {
    final today = DateTime.now();
    final isTodayOrFuture = date.isAfter(today.subtract(const Duration(days: 1))) ||
        (date.year == today.year && date.month == today.month && date.day == today.day);

    if (isTodayOrFuture) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MoodInput()),
      ).then((_) {
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Riwayat mood pada ${date.day}/${date.month}/${date.year}'),
          duration: const Duration(seconds: 1),
          backgroundColor: Colors.black54,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const List<String> monthNames = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];

    const List<String> weekDays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

    final int daysInMonth = DateTime(_focusedDate.year, _focusedDate.month + 1, 0).day;
    final int firstDayOfWeek = DateTime(_focusedDate.year, _focusedDate.month, 1).weekday;

    List<Widget> calendarWidgets = [];

    for (int i = 1; i < firstDayOfWeek; i++) {
      calendarWidgets.add(const SizedBox.shrink());
    }

    for (int day = 1; day <= daysInMonth; day++) {
      final currentDate = DateTime(_focusedDate.year, _focusedDate.month, day);
      final dateKey = _getDateKey(currentDate);
      final mood = _moodDatabase[dateKey];

      final bool isToday = (currentDate.year == DateTime.now().year &&
          currentDate.month == DateTime.now().month &&
          currentDate.day == DateTime.now().day);

      final bool isFuture = currentDate.isAfter(DateTime.now());

      calendarWidgets.add(
        GestureDetector(
          onTap: () => _handleDateTap(currentDate),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // BAGIAN ATAS: Tanggal dengan Background Pink (Hanya untuk Hari Ini)
              SizedBox(
                height: 24, // Tinggi area tanggal
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 1. Background Lingkaran Pink (Layer Belakang) - Hanya muncul jika isToday
                    if (isToday)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100, // Pink muda
                          shape: BoxShape.circle,
                        ),
                      ),

                    // 2. Angka Tanggal (Layer Depan)
                    Text(
                      '$day',
                      style: GoogleFonts.fredoka(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isToday ? Colors.pink.shade800 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 2), // Jarak antara tanggal dan emoji/tombol

              // BAGIAN BAWAH: Emoji atau Tombol + (Tanpa Background Pink)
              mood != null
                  ? SizedBox(
                width: 28,
                height: 28,
                child: Center(
                  child: Text(
                    _getEmoji(mood),
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              )
                  : !isFuture
                  ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
                  // Tidak ada border bold lagi
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 16,
                ),
              )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      );
    }

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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              const SizedBox(height: 25),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 5),
                decoration: BoxDecoration(
                  color: Colors.lightGreen.shade300,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left, color: Colors.black87),
                      onPressed: () => _changeMonth(-1),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                    Text(
                      '${monthNames[_focusedDate.month - 1]} ${_focusedDate.year}',
                      style: GoogleFonts.fredoka(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right, color: Colors.black87),
                      onPressed: () => _changeMonth(1),
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: weekDays.map((day) => SizedBox(
                        width: 32,
                        child: Text(
                          day,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      )).toList(),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 7,
                      mainAxisSpacing: 2,
                      crossAxisSpacing: 2,
                      childAspectRatio: 0.80,
                      children: calendarWidgets,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}