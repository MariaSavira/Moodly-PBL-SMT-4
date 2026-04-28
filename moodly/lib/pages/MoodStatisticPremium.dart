import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MoodStatisticPremium extends StatefulWidget {
  const MoodStatisticPremium({super.key});

  @override
  State<MoodStatisticPremium> createState() => _MoodStatisticPremiumState();
}

class _MoodStatisticPremiumState extends State<MoodStatisticPremium> {
  int _selectedIndex = 1; // Default ke Bulan (index 1) untuk non-premium
  DateTime _selectedMonth = DateTime(2026, 3, 1);
  int _selectedWeek = 1;

  // ✅ PREMIUM STATUS - Ganti dengan logic real nanti
  bool _isPremium = false; // Set true untuk test premium, false untuk free user

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
      case 'Senang': return Colors.green.shade200;
      case 'Netral': return Colors.grey.shade200;
      case 'Sedih': return Colors.blue.shade200;
      case 'Marah': return Colors.red.shade200;
      default: return Colors.grey.shade100;
    }
  }

  List<Map<String, dynamic>> _getWeeklyData() {
    List<Map<String, dynamic>> data = [];
    final firstDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final lastDayOfMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0);

    int daysBeforeWeek = (_selectedWeek - 1) * 7;
    int startDay = daysBeforeWeek + 1;

    for (int i = 0; i < 7; i++) {
      int day = startDay + i;
      if (day > lastDayOfMonth.day) break;

      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      final mood = _moodDatabase[dateKey] ?? 'Netral';

      data.add({
        'day': _getDayName(date.weekday),
        'date': day,
        'mood': mood,
        'emoji': _getEmoji(mood),
        'color': _getMoodColor(mood),
      });
    }

    return data;
  }

  Map<String, int> _getMonthlyStats() {
    Map<String, int> stats = {
      'Senang': 0,
      'Netral': 0,
      'Sedih': 0,
      'Marah': 0,
    };

    _moodDatabase.forEach((key, mood) {
      if (key.startsWith('${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}')) {
        stats[mood] = (stats[mood] ?? 0) + 1;
      }
    });

    return stats;
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
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

  // ✅ SHOW UPGRADE DIALOG
  void _showUpgradeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.diamond, color: Colors.amber, size: 32),
            const SizedBox(width: 8),
            Text(
              'Upgrade to Premium',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
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
            _buildFeatureItem(Icons.insights, 'Insight mendalam & tren'),
            _buildFeatureItem(Icons.notifications_active, 'Notifikasi personal'),
            _buildFeatureItem(Icons.cloud_download, 'Export data ke PDF'),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.local_offer, color: Colors.amber.shade700),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Diskon 50% untuk upgrade pertama!',
                      style: GoogleFonts.fredoka(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.amber.shade900,
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
              style: GoogleFonts.openSans(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // ✅ UPGRADE ACTION - Simulasi upgrade
              setState(() {
                _isPremium = true;
                _selectedIndex = 0; // Auto switch to Pekan
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🎉 Selamat! Anda sekarang Premium!'),
                  backgroundColor: Colors.green,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(
              'Upgrade Sekarang',
              style: GoogleFonts.fredoka(
                fontSize: 14,
                fontWeight: FontWeight.bold,
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
          Icon(icon, size: 18, color: Colors.green.shade700),
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
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          // ✅ PREMIUM BADGE DI APPBAR
          if (!_isPremium)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade400, Colors.amber.shade700],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(Icons.diamond, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Premium',
                    style: GoogleFonts.fredoka(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
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
              const SizedBox(height: 16),

              if (_selectedIndex == 0)
                _buildWeekNavigation()
              else
                _buildMonthNavigation(),

              const SizedBox(height: 16),

              if (_selectedIndex == 0)
                _buildWeeklyChart()
              else
                _buildMonthlyStats(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.pink.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          // ✅ TAB PEKAN DENGAN PREMIUM BADGE
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (_isPremium) {
                  setState(() {
                    _selectedIndex = 0;
                  });
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
                child: Center(
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
                        Icon(
                          Icons.diamond,
                          size: 14,
                          color: Colors.amber.shade700,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
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
                      color: _selectedIndex == 1
                          ? Colors.black
                          : Colors.grey,
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
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
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
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade300,
        borderRadius: BorderRadius.circular(30),
      ),
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
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
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
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weeklyData.map((item) {
                return _buildBar(item);
              }).toList(),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: weeklyData.map((item) {
              return SizedBox(
                width: 30,
                child: Text(
                  item['day'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyStats() {
    final stats = _getMonthlyStats();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.lightGreen.shade200,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '😊',
                  '${stats['Senang']} Hari',
                  'Hari penuh kebahagiaan dan perasaan sangat positif.',
                  Colors.green.shade100,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '😐',
                  '${stats['Netral']} Hari',
                  'Hari yang terasa biasa saja, tidak terlalu senang tapi juga tidak terlalu sedih.',
                  Colors.yellow.shade100,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  '😔',
                  '${stats['Sedih']} Hari',
                  'Hari dengan perasaan sedih atau kurang semangat.',
                  Colors.green.shade50,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  '😠',
                  '${stats['Marah']} Hari',
                  'Hari dengan emosi marah atau kesal.',
                  Colors.red.shade100,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String emoji, String title, String description, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: GoogleFonts.openSans(
              fontSize: 10,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(Map<String, dynamic> item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 30,
                height: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Container(
                width: 30,
                height: 120,
                decoration: BoxDecoration(
                  color: item['color'],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              Text(
                item['emoji'],
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
        ),
      ],
    );
  }
}