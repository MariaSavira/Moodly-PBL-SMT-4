import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'moderasi_admin.dart';
import 'profil_admin_page.dart';

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _jumlahNotif = 0;
  int _laporanBaru = 0;
  int _diaryBelumModerasi = 0;
  List<Map<String, dynamic>> _laporanTerbaru = [];
  List<Map<String, dynamic>> _graphData = [];

  StreamSubscription<QuerySnapshot>? _reportsSubscription;
  StreamSubscription<QuerySnapshot>? _diarySubscription;

  @override
  void initState() {
    super.initState();
    _setupRealtimeListeners();
    _loadLaporanTerbaru();
    _loadGraphData();
  }

  void _setupRealtimeListeners() {
    _reportsSubscription = FirebaseFirestore.instance
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _jumlahNotif = snapshot.docs.length;
        _laporanBaru = snapshot.docs.length;
      });
    });

    _diarySubscription = FirebaseFirestore.instance
        .collection('diary')
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .listen((snapshot) {
      if (!mounted) return;
      setState(() {
        _diaryBelumModerasi = snapshot.docs.length;
      });
    });
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    _diarySubscription?.cancel();
    super.dispose();
  }

  Future<void> _loadLaporanTerbaru() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reports')
          .orderBy('created_at', descending: true)
          .limit(5)
          .get();

      if (!mounted) return;
      setState(() {
        _laporanTerbaru = snap.docs.map((doc) {
          final data = doc.data();

          DateTime time = DateTime.now();
          if (data['created_at'] is Timestamp) {
            time = (data['created_at'] as Timestamp).toDate();
          } else if (data['created_at'] is DateTime) {
            time = data['created_at'];
          }

          return {
            'id': doc.id,
            'type': (data['report_category'] ?? 'Umum') as String,
            'user': (data['reported_by_username'] ?? 'Anonim') as String,
            'message': (data['report_reason'] ?? 'Tidak ada deskripsi') as String,
            'target': (data['reported_user'] ?? 'User') as String,
            'time': time,
            'status': (data['status'] ?? 'unknown') as String,
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('❌ Error loading latest reports: $e');
    }
  }

  Future<void> _loadGraphData() async {
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));

      final snap = await FirebaseFirestore.instance
          .collection('reports')
          .where('created_at', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .where('created_at', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      final Map<String, Map<String, int>> dataMap = {
        'Sen': {'chat': 0, 'diary': 0},
        'Sel': {'chat': 0, 'diary': 0},
        'Rab': {'chat': 0, 'diary': 0},
        'Kam': {'chat': 0, 'diary': 0},
        'Jum': {'chat': 0, 'diary': 0},
        'Sab': {'chat': 0, 'diary': 0},
        'Min': {'chat': 0, 'diary': 0},
      };

      const hariMap = {
        1: 'Sen', 2: 'Sel', 3: 'Rab', 4: 'Kam', 5: 'Jum', 6: 'Sab', 7: 'Min'
      };

      for (var doc in snap.docs) {
        final data = doc.data();
        final createdAt = (data['created_at'] as Timestamp).toDate();
        final category = (data['report_category'] ?? '').toString().toLowerCase();

        final dayOfWeek = createdAt.weekday;
        final dayName = hariMap[dayOfWeek] ?? 'Sen';

        final isChat = category.contains('chat') ||
            category.contains('anonim') ||
            category == 'spam';
        final typeKey = isChat ? 'chat' : 'diary';

        dataMap[dayName]![typeKey] = dataMap[dayName]![typeKey]! + 1;
      }

      if (!mounted) return;
      setState(() {
        _graphData = dataMap.entries.map((entry) {
          return {
            'day': entry.key,
            'chat': entry.value['chat'] ?? 0,
            'diary': entry.value['diary'] ?? 0,
          };
        }).toList();
      });

      debugPrint('📊 Total reports loaded: ${snap.docs.length}');
      debugPrint('📊 Graph data: $_graphData');

    } catch (e) {
      debugPrint('❌ Error loading graph data: $e');
    }
  }

  DateTime _parseTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    const hari = ['Minggu', 'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu'];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month]} ${d.year}';
  }

  String _formatWaktu(DateTime d) {
    return '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')} - ${_formatTanggal(d).split(',')[1].trim()}';
  }

  void _showNotifPopup() {
    showMenu(
      context: context,
      position: const RelativeRect.fromLTRB(190, 72, 16, 0),
      color: Colors.transparent,
      elevation: 0,
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: 245,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6FA),
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: _notifItem(
              icon: Icons.shield_rounded,
              title: 'Laporan Baru',
              subtitle: '$_jumlahNotif laporan menunggu tinjauan',
              color: const Color(0xFFFF8EA4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _notifItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withOpacity(0.22),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0C0E0C),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              const SizedBox(height: 20),
              _buildGreeting(),
              const SizedBox(height: 14),
              _buildStatCards(),
              const SizedBox(height: 18),
              _buildStatistikLaporan(),
              const SizedBox(height: 18),
              _buildLaporanTerbaruHeader(),
              const SizedBox(height: 12),

              if (_laporanTerbaru.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'Belum ada laporan terbaru',
                      style: GoogleFonts.openSans(color: Colors.grey),
                    ),
                  ),
                )
              else
                ..._laporanTerbaru.map(_buildLaporanItem),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-moderasi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-laporan');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/admin-banding');
          }
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Text(
          'Moodly',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFFFFB6CC),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showNotifPopup,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.notifications_rounded, size: 24, color: Color(0xFF8B8B8B)),
              if (_jumlahNotif > 0)
                Positioned(
                  top: -5,
                  right: -2,
                  child: Container(
                    width: 15,
                    height: 15,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFF9AB2),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _jumlahNotif > 9 ? '9+' : '$_jumlahNotif',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfilAdminPage(),
              ),
            );
          },
          child: Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              color: Color(0xFFFFC4D7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text(
                '👩🏻‍💻',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          'Admin',
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: const Color(0xFF0C0E0C),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting() {
    final now = DateTime.now();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Halo! Admin',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFF486253),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _formatTanggal(now),
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCards() {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildStatCard(
              icon: Icons.description_rounded,
              iconColor: const Color(0xFFFF8EA4),
              number: '$_laporanBaru',
              label: 'Laporan Baru',
              bgColor: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              icon: Icons.book_rounded,
              iconColor: const Color(0xFFB7E3A1),
              number: '$_diaryBelumModerasi',
              label: 'Laporan Belum di Moderasi',
              bgColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String number,
    required String label,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 24, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            number,
            style: GoogleFonts.fredoka(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              height: 22 / 28,
              color: const Color(0xFF0C0E0C),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 22 / 12,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatistikLaporan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Statistik Laporan',
            style: GoogleFonts.fredoka(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 22 / 16,
              color: const Color(0xFF0C0E0C),
            ),
          ),
          const SizedBox(height: 16),
          _buildLegend(),
          const SizedBox(height: 12),
          _buildBarChart(),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Row(
      children: [
        _buildLegendItem(
          color: const Color(0xFFFF8EA4),
          label: 'Chat',
        ),
        const SizedBox(width: 16),
        _buildLegendItem(
          color: const Color(0xFFFFC85E),
          label: 'Diary',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.openSans(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart() {
    final data = _graphData.isEmpty ? [
      {'day': 'Sen', 'chat': 0, 'diary': 0},
      {'day': 'Sel', 'chat': 0, 'diary': 0},
      {'day': 'Rab', 'chat': 0, 'diary': 0},
      {'day': 'Kam', 'chat': 0, 'diary': 0},
      {'day': 'Jum', 'chat': 0, 'diary': 0},
      {'day': 'Sab', 'chat': 0, 'diary': 0},
      {'day': 'Min', 'chat': 0, 'diary': 0},
    ] : _graphData;

    int maxValue = 1;
    for (var item in data) {
      final chatVal = (item['chat'] ?? 0) as int;
      final diaryVal = (item['diary'] ?? 0) as int;
      if (chatVal > maxValue) maxValue = chatVal;
      if (diaryVal > maxValue) maxValue = diaryVal;
    }

    return SizedBox(
      height: 120,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final chatValue = (item['chat'] ?? 0) as int;
          final diaryValue = (item['diary'] ?? 0) as int;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(
                    height: chatValue > 0
                        ? (chatValue / maxValue * 80).toDouble()
                        : 4,
                    color: const Color(0xFFFF8EA4),
                  ),
                  const SizedBox(width: 4),
                  _buildBar(
                    height: diaryValue > 0
                        ? (diaryValue / maxValue * 80).toDouble()
                        : 4,
                    color: const Color(0xFFFFC85E),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                item['day'] as String,
                style: GoogleFonts.openSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B6B6B),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBar({required double height, required Color color}) {
    return Container(
      width: 12,
      height: height > 0 ? height : 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildLaporanTerbaruHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'Laporan Terbaru',
          style: GoogleFonts.fredoka(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            height: 22 / 16,
            color: const Color(0xFF0C0E0C),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanItem(Map<String, dynamic> laporan) {
    final type = (laporan['type'] ?? 'Umum') as String;
    final userPelapor = (laporan['user'] ?? 'Anonim') as String;
    final message = (laporan['message'] ?? '') as String;
    final target = (laporan['target'] ?? 'User') as String;
    final time = (laporan['time'] as DateTime?) ?? DateTime.now();

    final isChat = type.toLowerCase().contains('chat') || type == 'Chat Anonim';
    final badgeColor = isChat ? const Color(0xFFFF8EA4) : const Color(0xFFFFC85E);
    final badgeBg = isChat ? const Color(0xFFFFF0F3) : const Color(0xFFFFF9E6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChat ? Icons.chat_bubble_rounded : Icons.book_rounded,
                      size: 12,
                      color: badgeColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: badgeColor,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                _formatWaktu(time),
                style: GoogleFonts.openSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF8B8B8B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD18B),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text(
                    '☁',
                    style: TextStyle(
                      fontSize: 16,
                      color: Color(0xFF2B2B2B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userPelapor,
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0C0E0C),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message.length > 30
                          ? '${message.substring(0, 30)}...'
                          : message,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}