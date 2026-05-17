import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class MoodAnalysis extends StatefulWidget {
  const MoodAnalysis({super.key});

  @override
  State<MoodAnalysis> createState() => _MoodAnalysisState();
}

class _MoodAnalysisState extends State<MoodAnalysis> {
  int _selectedIndex = 1;
  bool _isPremium = false;
  bool _isLoading = true;

  DateTime _selectedMonth = DateTime.now();
  late int _selectedWeek;

  Map<String, String> _moodDatabase = {};

  static const String _documentId = 'BeZzql14Y8xGyoLUDb0L';

  @override
  void initState() {
    super.initState();
    _checkPremiumStatus();
    _loadMoods();
    final now = DateTime.now();
    _selectedMonth = DateTime(now.year, now.month, 1);
    _selectedWeek = _calculateWeekNumber(now);
  }

  String _getEmojiImagePath(String? mood) {
    if (mood == null) return '';
    switch (mood) {
      case 'Senang': return 'assets/emoji/emoji_senang.png';
      case 'Netral': return 'assets/emoji/emoji_netral.png';
      case 'Sedih': return 'assets/emoji/emoji_sedih.png';
      case 'Marah': return 'assets/emoji/emoji_marah.png';
      default: return 'assets/emoji/emoji_netral.png';
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

      final doc = await FirebaseFirestore.instance
          .collection('moods')
          .doc(_documentId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        final entries = data?['entries'] as Map<String, dynamic>? ?? {};

        entries.forEach((key, value) {
          moods[key] = value.toString();
        });

        print("✅ Loaded ${entries.length} entries from Firestore for Analysis");
      }

      setState(() {
        _moodDatabase = moods;
      });

      print("📊 Total moods loaded for analysis: ${moods.length}");
    } catch (e) {
      print("❌ Error loading moods for analysis: $e");
    }
  }

  Future<void> _checkPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    bool isPremium = prefs.getBool('isPremium') ?? false;

    setState(() {
      _isPremium = isPremium;
      _isLoading = false;
    });
  }

  Future<void> _upgradeToPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', true);

    setState(() {
      _isPremium = true;
      _selectedIndex = 0;
    });
  }

  Future<void> _resetPremium() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isPremium', false);

    setState(() {
      _isPremium = false;
      _selectedIndex = 1;
    });
  }

  void _showUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.amber.shade700, size: 32),
            const SizedBox(width: 8),
            Text(
              'Upgrade Premium',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dapatkan akses ke fitur eksklusif:',
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeatureItem(Icons.bar_chart, 'Analisis mood mingguan'),
            _buildFeatureItem(Icons.insights, 'Insight mendalam'),
            _buildFeatureItem(Icons.notifications_active, 'Notifikasi personal'),

            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.pink.shade400, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.pinkAccent.shade200),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gratis untuk demo PBL!',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.pinkAccent.shade200,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Nanti',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _upgradeToPremium();

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(
                        '🎉 Premium activated!',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.pink.shade200,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pink.shade100,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Aktifkan Sekarang',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.pinkAccent.shade200),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
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
          'emoji': hasMood ? _getEmojiImagePath(mood) : '',
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
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF9FBE7),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
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
          'Mood Analysis',
          style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.black),
        ),
        actions: [
          if (!_isPremium)
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: ElevatedButton.icon(
                onPressed: _showUpgradeDialog,
                icon: Icon(Icons.diamond, size: 16, color: Colors.black),
                label: Text(
                  'Premium',
                  style: GoogleFonts.fredoka(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),

          if (!kReleaseMode)
            IconButton(
              icon: Icon(Icons.refresh, color: Colors.purple),
              onPressed: () async {
                await _loadMoods();
                await _resetPremium();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Data di-refresh & Premium status direset')),
                );
              },
              tooltip: 'Refresh Data (Debug)',
            ),
        ],
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
              onTap: () {
                if (_isPremium) {
                  setState(() => _selectedIndex = 0);
                } else {
                  _showUpgradeDialog();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 0 && _isPremium
                      ? Colors.pink.shade200
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pekan',
                      style: GoogleFonts.fredoka(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: (_selectedIndex == 0 && _isPremium)
                            ? Colors.black
                            : Colors.grey,
                      ),
                    ),
                    if (!_isPremium) ...[
                      const SizedBox(width: 4),
                      Icon(Icons.lock, size: 12, color: Colors.amber.shade700),
                    ],
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _selectedIndex = 1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: _selectedIndex == 1
                      ? Colors.pink.shade200
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    'Bulan',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedIndex == 1 ? Colors.black : Colors.grey,
                    ),
                  ),
                ),
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
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 20),
            onPressed: () => _changeWeek(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            'Minggu $_selectedWeek, ${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 20),
            onPressed: () => _changeWeek(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
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
          IconButton(
            icon: const Icon(Icons.chevron_left, color: Colors.black87, size: 20),
            onPressed: () => _changeMonth(-1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          Text(
            '${_getMonthName(_selectedMonth.month)} ${_selectedMonth.year}',
            style: GoogleFonts.fredoka(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, color: Colors.black87, size: 20),
            onPressed: () => _changeMonth(1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
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
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyData.map((item) => _buildBar(item)).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeklyData.map((item) => SizedBox(
              width: 30,
              child: Text(
                item['isEmpty'] && item['date'] < 1 || item['date'] > DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day
                    ? ''
                    : item['day'],
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.black54),
              ),
            )).toList(),
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
              Expanded(child: _buildStatCard(_getEmojiImagePath('Senang'), '${stats['Senang']} Hari', 'Hari penuh kebahagiaan.', Colors.green.shade100)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(_getEmojiImagePath('Netral'), '${stats['Netral']} Hari', 'Hari yang terasa biasa saja.', Colors.yellow.shade100)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildStatCard(_getEmojiImagePath('Sedih'), '${stats['Sedih']} Hari', 'Hari dengan perasaan sedih.', Colors.green.shade50)),
              const SizedBox(width: 12),
              Expanded(child: _buildStatCard(_getEmojiImagePath('Marah'), '${stats['Marah']} Hari', 'Hari dengan emosi marah.', Colors.red.shade100)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emojiPath, String title, String description, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            emojiPath,
            width: 48,
            height: 48,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.sentiment_satisfied, size: 32);
            },
          ),
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
    final double maxHeight = 140.0;
    final double barHeight = maxHeight * barValue;
    final bool isEmpty = item['isEmpty'] ?? false;
    final double emojiSize = 28.0;
    final double barWidth = 32.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: barWidth + 10,
          height: maxHeight + 35,
          child: Stack(
            alignment: Alignment.bottomCenter,
            clipBehavior: Clip.none,
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
                Positioned(
                  bottom: 0,
                  child: Container(
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
                ),
              if (!isEmpty && barHeight > 0)
                Positioned(
                  bottom: barHeight - (emojiSize / 2.5),
                  child: Image.asset(
                    item['emoji'],
                    width: emojiSize,
                    height: emojiSize,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox.shrink();
                    },
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoodInsight() {
    final reflection = _getReflectionPercentages();
    final heavyPercent = reflection['heavy']!;
    final growthPercent = reflection['growth']!;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            'Mood Insight',
            style: GoogleFonts.fredoka(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),

          Text(
            _getInsightMessage(),
            style: GoogleFonts.openSans(
              fontSize: 14,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Reflection',
                  style: GoogleFonts.fredoka(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CustomPaint(
                              painter: _BottomFilledCirclePainter(
                                color: Colors.green.shade600,
                                progress: heavyPercent,
                                backgroundColor: Colors.green.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  '${(heavyPercent * 100).toInt()}%',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Beban Emosi',
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 2,
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(1),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 80,
                            child: CustomPaint(
                              painter: _BottomFilledCirclePainter(
                                color: Colors.green.shade600,
                                progress: growthPercent,
                                backgroundColor: Colors.green.shade100,
                              ),
                              child: Center(
                                child: Text(
                                  '${(growthPercent * 100).toInt()}%',
                                  style: GoogleFonts.fredoka(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Ruang Pertumbuhan',
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Aktivitas untuk Kamu',
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
            childAspectRatio: 1.1,
            children: [
              _buildActivityCard(
                Icons.nights_stay_rounded,
                'Tidur',
                '8 jam direkomendasikan',
                Colors.purple,
              ),
              _buildActivityCard(
                Icons.restaurant_rounded,
                'Makanan',
                'Nutrisi tubuhmu',
                Colors.orange,
              ),
              _buildActivityCard(
                Icons.fitness_center_rounded,
                'Olahraga',
                'Lepaskan ketegangan',
                Colors.blue,
              ),
              _buildActivityCard(
                Icons.music_note_rounded,
                'Musik',
                'Frekuensi penyembuhan',
                Colors.pink,
              ),
            ],
          ),
        ],
      ),
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

class _BottomFilledCirclePainter extends CustomPainter {
  final Color color;
  final double progress;
  final Color backgroundColor;

  _BottomFilledCirclePainter({
    required this.color,
    required this.progress,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;

    final Paint bgPaint = Paint()..color = backgroundColor;
    canvas.drawCircle(Offset(centerX, centerY), radius, bgPaint);

    final double fillHeight = size.height * progress;
    final double topY = size.height - fillHeight;

    final Paint fillPaint = Paint()..color = color;

    final Path circlePath = Path()
      ..addOval(Rect.fromCircle(center: Offset(centerX, centerY), radius: radius));

    canvas.save();
    canvas.clipPath(circlePath);

    final Rect fillRect = Rect.fromLTRB(0, topY, size.width, size.height);
    canvas.drawRect(fillRect, fillPaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}