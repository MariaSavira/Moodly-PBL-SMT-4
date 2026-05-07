import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'mood_input.dart';

class MoodCalendar extends StatefulWidget {
  final int initialYear;
  final int initialMonth;

  const MoodCalendar({
    super.key,
    this.initialYear = 2026,
    this.initialMonth = 1,
  });

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  late DateTime _focusedDate;
  bool _isLoading = true;
  Map<String, String> _moodDatabase = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDate = DateTime(now.year, now.month, 1);
    _loadMoods();
  }

  String _getEmojiImagePath(String? mood) {
    if (mood == null) return '';
    switch (mood) {
      case 'Senang':
        return 'assets/emoji/emoji_senang.png';
      case 'Netral':
        return 'assets/emoji/emoji_netral.png';
      case 'Sedih':
        return 'assets/emoji/emoji_sedih.png';
      case 'Marah':
        return 'assets/emoji/emoji_marah.png';
      default:
        return 'assets/emoji/emoji_netral.png';
    }
  }

  Future<void> _loadMoods() async {
    Map<String, String> moods = {};

    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((k) => k.startsWith('mood_'));
      for (var key in keys) {
        final dateKey = key.replaceFirst('mood_', '');
        final mood = prefs.getString(key);
        if (mood != null) {
          moods[dateKey] = mood;
        }
      }

      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('moods')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
          final entries = data?['entries'] as Map<String, dynamic>? ?? {};
          entries.forEach((key, value) {
            moods[key] = value.toString();
          });
        }
      }

      setState(() {
        _moodDatabase = moods;
        _isLoading = false;
      });
    } catch (e) {
      print("❌ Error loading moods: $e");
      setState(() {
        _moodDatabase = moods;
        _isLoading = false;
      });
    }
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
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
        MaterialPageRoute(
          builder: (_) => MoodInput(selectedDate: date),
        ),
      ).then((_) {

        _loadMoods();
      });
    } else {
      final dateKey = _getDateKey(date);
      final mood = _moodDatabase[dateKey];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mood != null
                ? 'Mood pada ${date.day}/${date.month}/${date.year}: $mood'
                : 'Belum ada catatan mood pada ${date.day}/${date.month}/${date.year}',
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.black54,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
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
            style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      );
    }

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
              SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (isToday)
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.pink.shade100,
                          shape: BoxShape.circle,
                        ),
                      ),
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
              const SizedBox(height: 2),

              mood != null
                  ? SizedBox(
                width: 28,
                height: 28,
                child: Image.asset(
                  _getEmojiImagePath(mood),
                  fit: BoxFit.contain,
                ),
              )
                  : !isFuture
                  ? Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.lightGreen,
                  borderRadius: BorderRadius.circular(6),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadMoods,
            tooltip: 'Refresh data',
          ),
        ],
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