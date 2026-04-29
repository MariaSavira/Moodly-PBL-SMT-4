import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodAnalysis extends StatefulWidget {
  const MoodAnalysis({super.key});

  @override
  State<MoodAnalysis> createState() => _MoodAnalysisState();
}

class _MoodAnalysisState extends State<MoodAnalysis> {
  int _selectedIndex = 0; // 0 = Pekan, 1 = Bulan

  // Default akan di-override di initState agar real-time saat pertama buka
  DateTime _selectedMonth = DateTime.now();
  late int _selectedWeek;

  // Database Mood (Dummy Data)
  final Map<String, String> _moodDatabase = {
    // Maret 2026
    '2026-03-01': 'Senang', '2026-03-02': 'Netral', '2026-03-03': 'Senang',
    '2026-03-04': 'Senang', '2026-03-05': 'Netral', '2026-03-06': 'Netral',
    '2026-03-07': 'Sedih', '2026-03-08': 'Senang', '2026-03-09': 'Senang',
    '2026-03-10': 'Sedih', '2026-03-11': 'Sedih', '2026-03-12': 'Marah',
    '2026-03-13': 'Sedih', '2026-03-14': 'Marah', '2026-03-15': 'Marah',
    '2026-03-16': 'Sedih', '2026-03-17': 'Marah', '2026-03-18': 'Senang',
    '2026-03-19': 'Senang', '2026-03-20': 'Senang', '2026-03-21': 'Senang',
    '2026-03-22': 'Netral', '2026-03-23': 'Senang', '2026-03-24': 'Netral',
    '2026-03-25': 'Netral', '2026-03-26': 'Senang', '2026-03-27': 'Netral',
    '2026-03-28': 'Sedih', '2026-03-29': 'Senang', '2026-03-30': 'Senang',
    '2026-03-31': 'Senang',

    // April 2026
    '2026-04-01': 'Senang', '2026-04-02': 'Netral', '2026-04-03': 'Sedih',
    '2026-04-04': 'Marah', '2026-04-05': 'Netral', '2026-04-06': 'Senang',
    '2026-04-07': 'Senang', '2026-04-08': 'Netral', '2026-04-09': 'Sedih',
    '2026-04-10': 'Sedih', '2026-04-11': 'Marah', '2026-04-12': 'Senang',
    '2026-04-13': 'Netral', '2026-04-14': 'Senang', '2026-04-15': 'Netral',
    '2026-04-16': 'Sedih', '2026-04-17': 'Marah', '2026-04-18': 'Senang',
    '2026-04-19': 'Netral', '2026-04-20': 'Senang', '2026-04-21': 'Netral',
    '2026-04-22': 'Sedih', '2026-04-23': 'Marah', '2026-04-24': 'Senang',
    '2026-04-25': 'Netral', '2026-04-26': 'Senang', '2026-04-27': 'Netral',
    '2026-04-28': 'Sedih', '2026-04-29': 'Marah', '2026-04-30': 'Senang',
  };

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedWeek = _calculateWeekNumber(now);
  }

  String _getEmoji(String mood) {
    switch (mood) {
      case 'Senang': return '😊';
      case 'Netral': return '😐';
      case 'Sedih': return '😔';
      case 'Marah': return '😠';
      default: return '😐';
    }
  }

  Color _getMoodColor(String mood) {
    switch (mood) {
      case 'Senang': return Colors.green.shade300;
      case 'Netral': return Colors.orange.shade200;
      case 'Sedih': return Colors.blue.shade300;
      case 'Marah': return Colors.red.shade300;
      default: return Colors.grey.shade200;
    }
  }

  double _getMoodValue(String mood) {
    switch (mood) {
      case 'Senang': return 1.0;
      case 'Netral': return 0.6;
      case 'Sedih': return 0.4;
      case 'Marah': return 0.2;
      default: return 0.0;
    }
  }

  int _calculateWeekNumber(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    return ((date.day + firstDayOfMonth.weekday - 1) / 7).ceil();
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    List<Map<String, dynamic>> data = [];

    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    int daysBeforeWeek = (_selectedWeek - 1) * 7;
    int startDay = daysBeforeWeek + 1;

    for (int i = 0; i < 7; i++) {
      int day = startDay + i;

      if (day > lastDayOfMonth.day || day < 1) {
        data.add({
          'day': _getDayName((firstDayOfMonth.weekday + i) % 7 == 0 ? 7 : (firstDayOfMonth.weekday + i) % 7),
          'date': day,
          'mood': null,
          'emoji': '',
          'color': Colors.grey.shade100,
          'value': 0.0,
          'isEmpty': true,
        });
      } else {
        final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
        final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final mood = _moodDatabase[dateKey];
        final hasMood = mood != null;

        data.add({
          'day': _getDayName(date.weekday),
          'date': day,
          'mood': mood,
          'emoji': hasMood ? _getEmoji(mood) : '',
          'color': hasMood ? _getMoodColor(mood) : Colors.grey.shade100,
          'value': hasMood ? _getMoodValue(mood) : 0.0,
          'isEmpty': !hasMood,
        });
      }
    }

    return data;
  }

  Map<String, int> _getMonthlyStats() {
    Map<String, int> stats = {'Senang': 0, 'Netral': 0, 'Sedih': 0, 'Marah': 0};

    _moodDatabase.forEach((key, mood) {
      if (key.startsWith('${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}')) {
        stats[mood] = (stats[mood] ?? 0) + 1;
      }
    });
    return stats;
  }

  // ✅ FUNGSI BARU: Dapatkan insight berdasarkan mood
  String _getInsightMessage() {
    final stats = _getMonthlyStats();
    final totalDays = stats.values.fold(0, (sum, count) => sum + count);

    if (totalDays == 0) {
      return "Yuk, mulai catat moodmu hari ini!";
    }

    final sedihMarah = stats['Sedih']! + stats['Marah']!;
    final senang = stats['Senang']!;

    if (sedihMarah > senang) {
      return "Aku melihat kamu sedang merasa agak berat hari ini.";
    } else if (senang > sedihMarah * 2) {
      return "Wah, kamu sedang dalam kondisi sangat positif! Pertahankan ya!";
    } else {
      return "Hari-harimu cukup stabil, tapi masih ada ruang untuk lebih bahagia.";
    }
  }

  // ✅ FUNGSI BARU: Hitung persentase heavy vs growth
  Map<String, double> _getReflectionPercentages() {
    final stats = _getMonthlyStats();
    final totalDays = stats.values.fold(0, (sum, count) => sum + count);

    if (totalDays == 0) {
      return {'heavy': 0.0, 'growth': 1.0};
    }

    final heavy = stats['Sedih']! + stats['Marah']!;
    final heavyPercent = heavy / totalDays;
    final growthPercent = 1.0 - heavyPercent;

    return {
      'heavy': heavyPercent,
      'growth': growthPercent,
    };
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }

  int _getTotalWeeksInMonth() {
    final daysInMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
    return (daysInMonth / 7).ceil();
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
      _selectedWeek = 1;
    });
  }

  void _changeWeek(int offset) {
    setState(() {
      _selectedWeek += offset;

      if (_selectedWeek < 1) {
        _changeMonth(-1);
        _selectedWeek = _getTotalWeeksInMonth();
      } else if (_selectedWeek > _getTotalWeeksInMonth()) {
        _changeMonth(1);
        _selectedWeek = 1;
      }
    });
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
          'Mood Analysis',
          style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTabSelector(),
              const SizedBox(height: 10),

              if (_selectedIndex == 0) _buildWeekNavigation() else _buildMonthNavigation(),

              const SizedBox(height: 16),

              if (_selectedIndex == 0) _buildWeeklyChart() else _buildMonthlyStats(),

              const SizedBox(height: 20),

              // ✅ MOOD INSIGHT SECTION
              _buildMoodInsight(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 ? Colors.pink.shade200 : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(child: Text('Pekan', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: _selectedIndex == 0 ? Colors.black : Colors.grey))),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1 ? Colors.pink.shade200 : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(child: Text('Bulan', style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: _selectedIndex == 1 ? Colors.black : Colors.grey))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: Colors.lightGreen.shade300, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 20), onPressed: () => _changeWeek(-1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
          Text('Minggu $_selectedWeek, ${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 20), onPressed: () => _changeWeek(1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(color: Colors.lightGreen.shade300, borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 20), onPressed: () => _changeMonth(-1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
          Text('${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}', style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          IconButton(icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 20), onPressed: () => _changeMonth(1), padding: EdgeInsets.zero, constraints: const BoxConstraints(minWidth: 32, minHeight: 32)),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    final weeklyData = _getWeeklyData();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.lightGreen.shade100, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          SizedBox(
            height: 240, // ← UBAH dari 200 ke 240 (beri ruang lebih)
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyData.map((item) => _buildBar(item)).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeklyData.map((item) => SizedBox(width: 30, child: Text(
                item['isEmpty'] && item['date'] < 1 || item['date'] > DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day
                    ? ''
                    : item['day'],
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54)
            ))).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final stats = _getMonthlyStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.lightGreen.shade200, borderRadius: BorderRadius.circular(24)),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildStatCard('😊', '${stats['Senang']} Hari', 'Hari penuh kebahagiaan.', Colors.green.shade100)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('😐', '${stats['Netral']} Hari', 'Hari yang terasa biasa saja.', Colors.yellow.shade100)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard('😔', '${stats['Sedih']} Hari', 'Hari dengan perasaan sedih.', Colors.green.shade50)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard('😠', '${stats['Marah']} Hari', 'Hari dengan emosi marah.', Colors.red.shade100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String title, String description, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(title, style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(description, style: GoogleFonts.openSans(fontSize: 10, color: Colors.black87)),
        ],
      ),
    );
  }

  Widget _buildBar(Map<String, dynamic> item) {
    final double barValue = item['value'];
    final double maxHeight = 160.0;
    final double barHeight = maxHeight * barValue;
    final bool isEmpty = item['isEmpty'] ?? false;
    final double emojiSize = 24.0; // ← Ubah variabel ini juga jadi 24
    final double barWidth = 32.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: barWidth + 10,
          height: maxHeight + 20, // ← Kurangi height container jika emoji lebih kecil
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Container(
                width: barWidth,
                height: maxHeight,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(barWidth / 2),
                    bottom: Radius.circular(8),
                  ),
                ),
              ),
              if (!isEmpty && barHeight > 0)
                Container(
                  width: barWidth,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: item['color'],
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(barWidth / 2),
                      bottom: barHeight < barWidth / 2
                          ? Radius.circular(barHeight / 2)
                          : Radius.zero,
                    ),
                  ),
                ),
              if (!isEmpty && barHeight > 0)
                Positioned(
                  bottom: barHeight - (emojiSize / 3), // ← Sesuaikan posisi
                  child: Text(
                    item['emoji'],
                    style: const TextStyle(fontSize: 24), // ← Emoji lebih kecil
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  // ✅ MOOD INSIGHT SECTION
  Widget _buildMoodInsight() {
    final reflection = _getReflectionPercentages();
    final heavyPercent = reflection['heavy']!;
    final growthPercent = reflection['growth']!;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            'Mood Insight',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          // Insight Message
          Text(
            _getInsightMessage(),
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.black87,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // Current Reflection
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Reflection',
                  style: GoogleFonts.fredoka(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildReflectionCircle(
                      '${(heavyPercent * 100).toInt()}%',
                      'Heavy',
                      Colors.red.shade300,
                    ),
                    _buildReflectionCircle(
                      '${(growthPercent * 100).toInt()}%',
                      'Growth space',
                      Colors.green.shade300,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Activities for You
          Text(
            'Activities for You',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
            children: [
              _buildActivityCard(
                Icons.nights_stay_rounded,
                'Sleep',
                '8h recommended',
                Colors.purple,
              ),
              _buildActivityCard(
                Icons.restaurant_rounded,
                'Food',
                'Nourish your body',
                Colors.orange,
              ),
              _buildActivityCard(
                Icons.fitness_center_rounded,
                'Exercise',
                'Release tension',
                Colors.blue,
              ),
              _buildActivityCard(
                Icons.music_note_rounded,
                'Music',
                'Healing frequencies',
                Colors.pink,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReflectionCircle(String percentage, String label, Color color) {
    return Column(
      children: [
        SizedBox(
          width: 80,
          height: 80,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 8,
                backgroundColor: color.withOpacity(0.3),
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    percentage,
                    style: GoogleFonts.fredoka(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 12,
            color: Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityCard(IconData icon, String title, String subtitle, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 24,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.openSans(
              fontSize: 10,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}