import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadStats();
    await _loadLaporanTerbaru();
  }

  Future<void> _loadStats() async {
    try {
      final reportedUsersSnap = await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .where('userData.hasWarning', isEqualTo: true)
          .get();

      final diarySnap = await FirebaseFirestore.instance
          .collection('diary')
          .where('status', isEqualTo: 'pending')
          .get();

      if (!mounted) return;
      setState(() {
        _laporanBaru = reportedUsersSnap.docs.length;
        _diaryBelumModerasi = diarySnap.docs.length;
      });
    } catch (e) {
      debugPrint('❌ Error loading stats: $e');
    }
  }

  Future<void> _loadLaporanTerbaru() async {
    try {
      final snap = await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .orderBy('userData.updatedAt', descending: true)
          .limit(5)
          .get();

      if (!mounted) return;
      setState(() {
        _laporanTerbaru = snap.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final userData = data['userData'] as Map<String, dynamic>? ?? {};
          return {
            'id': doc.id,
            'type': (userData['avatarPath'] ?? 'Chat Anonim') as String,
            'user': (userData['nickname'] ?? 'User') as String,
            'message': (userData['warningMessage'] ?? '') as String,
            'time': _parseTime(userData['updatedAt']),
          };
        }).toList();
      });
    } catch (e) {
      debugPrint('❌ Error loading latest reports: $e');
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
              title: 'Moderasi',
              subtitle: '$_jumlahNotif laporan menunggu ditinjau',
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
              ..._laporanTerbaru.map(_buildLaporanItem),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(
              context,
              '/admin-moderasi',
            );
          } else if (index == 2) {
            Navigator.pushReplacementNamed(
              context,
              '/admin-laporan',
            );
          } else if (index == 3) {
            Navigator.pushReplacementNamed(
              context,
              '/admin-banding',
            );
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
              const Icon(Icons.notifications_rounded,
                  size: 24, color: Color(0xFF8B8B8B)),
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
                    '$_jumlahNotif',
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
                '👩‍💻',
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
            child: Icon(
              icon,
              size: 24,
              color: iconColor,
            ),
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
    final data = [
      {'day': 'Sen', 'chat': 12, 'diary': 8},
      {'day': 'Sel', 'chat': 15, 'diary': 10},
      {'day': 'Rab', 'chat': 10, 'diary': 18},
      {'day': 'Kam', 'chat': 14, 'diary': 12},
      {'day': 'Jum', 'chat': 8, 'diary': 6},
      {'day': 'Sab', 'chat': 11, 'diary': 9},
      {'day': 'Min', 'chat': 6, 'diary': 4},
    ];

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
                    height: (chatValue / 20 * 80).toDouble(),
                    color: const Color(0xFFFF8EA4),
                  ),
                  const SizedBox(width: 4),
                  _buildBar(
                    height: (diaryValue / 20 * 80).toDouble(),
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
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/admin-laporan');
          },
          child: Text(
            'View All',
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF5F9E4E),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaporanItem(Map<String, dynamic> laporan) {
    final type = (laporan['type'] ?? '') as String;
    final user = (laporan['user'] ?? 'User') as String;
    final message = (laporan['message'] ?? '') as String;
    final time = laporan['time'] is DateTime
        ? laporan['time'] as DateTime
        : DateTime.now();

    final isChat = type == 'Chat Anonim' || type.toLowerCase().contains('chat');

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
                  color: isChat
                      ? const Color(0xFFFFF0F3)
                      : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isChat ? Icons.chat_bubble_rounded : Icons.book_rounded,
                      size: 12,
                      color: isChat
                          ? const Color(0xFFFF8EA4)
                          : const Color(0xFFFFC85E),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      type,
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: isChat
                            ? const Color(0xFFFF8EA4)
                            : const Color(0xFFD4A017),
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
                      user,
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