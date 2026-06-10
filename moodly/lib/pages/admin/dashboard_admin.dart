import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/admin_bottom_navbar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'list_ajuan_banding_admin_page.dart';
import 'moderasi_admin.dart';
import 'profil_admin_page.dart';
import 'tinjau_moderasi_admin.dart';

class _DashboardReportPreview {
  final String documentId;
  final String type;
  final String reportCategory;
  final String reportReason;
  final String contentText;
  final String reportedByUid;
  final String reportedByUsername;
  final String reportedProfile;
  final String reportedUid;
  final String reportedUser;
  final String targetId;
  final String status;
  final String catatanAdmin;
  final DateTime createdAt;

  const _DashboardReportPreview({
    required this.documentId,
    required this.type,
    required this.reportCategory,
    required this.reportReason,
    required this.contentText,
    required this.reportedByUid,
    required this.reportedByUsername,
    required this.reportedProfile,
    required this.reportedUid,
    required this.reportedUser,
    required this.targetId,
    required this.status,
    required this.catatanAdmin,
    required this.createdAt,
  });

  factory _DashboardReportPreview.fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    DateTime parseDate() {
      final raw = data['created_at'] ?? data['createdAt'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
    }

    String extractReporterName() {
      final direct = (data['reported_by_username'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;

      final reporterInfo = data['reporterInfo'];
      if (reporterInfo is Map<String, dynamic>) {
        final displayName = (reporterInfo['displayName'] ?? '').toString().trim();
        if (displayName.isNotEmpty) return displayName;
      }

      return 'Anonim';
    }

    String extractReportedUser() {
      final direct = (data['reported_user'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;

      final reportedUserInfo = data['reportedUserInfo'];
      if (reportedUserInfo is Map<String, dynamic>) {
        final userData = reportedUserInfo['userData'];
        if (userData is Map<String, dynamic>) {
          final nickname = (userData['nickname'] ?? '').toString().trim();
          if (nickname.isNotEmpty) return nickname;

          final fullName = (userData['fullName'] ?? '').toString().trim();
          if (fullName.isNotEmpty) return fullName;
        }
      }

      return 'User';
    }

    String extractAvatar() {
      final direct = (data['reported_profile'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;

      final reportedUserInfo = data['reportedUserInfo'];
      if (reportedUserInfo is Map<String, dynamic>) {
        final userData = reportedUserInfo['userData'];
        if (userData is Map<String, dynamic>) {
          final photoUrl = (userData['photoUrl'] ?? '').toString().trim();
          if (photoUrl.isNotEmpty) return photoUrl;

          final avatarId = (userData['avatarId'] ?? '').toString().trim();
          if (avatarId.isNotEmpty) return avatarId;
        }
      }

      return '';
    }

    String extractType() {
      final direct = (data['type'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;

      final targetType = (data['target_type'] ?? '').toString().trim();
      if (targetType.isNotEmpty) return targetType;

      if (data['reportedMessages'] != null) return 'chat';
      if (data['reply_id'] != null) return 'reply';
      if (data['comment_id'] != null) return 'comment';
      return 'diary';
    }

    return _DashboardReportPreview(
      documentId: doc.id,
      type: extractType(),
      reportCategory: (data['report_category'] ?? data['reportCategory'] ?? 'Umum')
          .toString(),
      reportReason: (data['report_reason'] ?? data['reportReason'] ?? '')
          .toString(),
      contentText: (data['content_text'] ?? data['isiLaporan'] ?? '')
          .toString(),
      reportedByUid: (data['reported_by_uid'] ?? '').toString(),
      reportedByUsername: extractReporterName(),
      reportedProfile: extractAvatar(),
      reportedUid: (data['reported_uid'] ?? data['reportedUid'] ?? '').toString(),
      reportedUser: extractReportedUser(),
      targetId: (data['diary_id'] ??
              data['comment_id'] ??
              data['reply_id'] ??
              data['target_id'] ??
              '')
          .toString(),
      status: (data['status'] ?? 'pending').toString(),
      catatanAdmin: (data['catatanAdmin'] ?? '').toString(),
      createdAt: parseDate(),
    );
  }

  ModerasiModel toModerasiModel() {
    return ModerasiModel(
      id: documentId,
      contentText: contentText,
      reportCategory: reportCategory,
      reportReason: reportReason,
      reportedByUid: reportedByUid,
      reportedByUsername: reportedByUsername,
      reportedProfile: reportedProfile,
      reportedUid: reportedUid,
      reportedUser: reportedUser,
      targetId: targetId,
      status: status,
      catatanAdmin: catatanAdmin,
      createdAt: createdAt,
      type: type,
    );
  }
}

class DashboardAdminPage extends StatefulWidget {
  const DashboardAdminPage({super.key});

  @override
  State<DashboardAdminPage> createState() => _DashboardAdminPageState();
}

class _DashboardAdminPageState extends State<DashboardAdminPage> {
  int _jumlahNotif = 0;
  int _laporanPending = 0;
  int _laporanDiproses = 0;
  int _bandingPending = 0;
  List<_DashboardReportPreview> _laporanTerbaru = [];
  List<Map<String, dynamic>> _graphData = [];
  bool _hasLoaded = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reportsSubscription;

  static const Color _bg = Color(0xFFF6F9EE);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF4E7D45);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEEF7E6);
  static const Color _pinkSoft = Color(0xFFFFF1F4);
  static const Color _peachSoft = Color(0xFFFFEFD9);
  static const Color _yellowSoft = Color(0xFFFFF6DA);
  static const Color _blueSoft = Color(0xFFEAF7FF);
  static const Color _textDark = Color(0xFF243127);
  static const Color _textSoft = Color(0xFF6E776B);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 8),
          blurRadius: 24,
          spreadRadius: 0,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _listenReports();
  }

  void _listenReports() {
    _reportsSubscription = FirebaseFirestore.instance
        .collection('reports')
        .snapshots()
        .listen((snapshot) {
      final docs = snapshot.docs.toList();

      docs.sort((a, b) {
        final aDate = _extractDate(a.data());
        final bDate = _extractDate(b.data());
        return bDate.compareTo(aDate);
      });

      int pending = 0;
      int diproses = 0;
      int bandingPending = 0;

      for (final doc in docs) {
        final data = doc.data();
        final status = (data['status'] ?? 'pending').toString().toLowerCase();

        if (status == 'pending') {
          pending++;
        } else if (status == 'diproses') {
          diproses++;
        }

        final alasanBanding = (data['alasanBanding'] ?? '').toString().trim();
        final statusBanding =
            (data['statusBanding'] ?? 'pending').toString().toLowerCase();

        if (alasanBanding.isNotEmpty && statusBanding == 'pending') {
          bandingPending++;
        }
      }

      final latest = docs.take(5).map(_DashboardReportPreview.fromDoc).toList();
      final graph = _buildGraphDataFromDocs(docs);

      if (!mounted) return;
      setState(() {
        _jumlahNotif = pending;
        _laporanPending = pending;
        _laporanDiproses = diproses;
        _bandingPending = bandingPending;
        _laporanTerbaru = latest;
        _graphData = graph;
        _hasLoaded = true;
      });
    });
  }

  DateTime _extractDate(Map<String, dynamic> data) {
    final raw = data['created_at'] ?? data['createdAt'];
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
    return DateTime.now();
  }

  List<Map<String, dynamic>> _buildGraphDataFromDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    const hariPendek = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    final now = DateTime.now();
    final List<DateTime> days = List.generate(
      7,
      (index) => DateTime(now.year, now.month, now.day)
          .subtract(Duration(days: 6 - index)),
    );

    final Map<String, Map<String, int>> bucket = {
      for (final day in days)
        hariPendek[day.weekday % 7]: {
          'chat': 0,
          'diary': 0,
        }
    };

    for (final doc in docs) {
      final data = doc.data();
      final created = _extractDate(data);
      final normalizedDay = DateTime(created.year, created.month, created.day);

      final exists = days.any((d) => d == normalizedDay);
      if (!exists) continue;

      final key = hariPendek[normalizedDay.weekday % 7];
      final type = (data['type'] ?? data['target_type'] ?? '').toString().toLowerCase();

      final isChat = type.contains('chat');
      if (isChat) {
        bucket[key]!['chat'] = (bucket[key]!['chat'] ?? 0) + 1;
      } else {
        bucket[key]!['diary'] = (bucket[key]!['diary'] ?? 0) + 1;
      }
    }

    return days.map((day) {
      final key = hariPendek[day.weekday % 7];
      return {
        'day': key,
        'chat': bucket[key]!['chat'] ?? 0,
        'diary': bucket[key]!['diary'] ?? 0,
      };
    }).toList();
  }

  @override
  void dispose() {
    _reportsSubscription?.cancel();
    super.dispose();
  }

  String _formatTanggal(DateTime d) {
    const bulan = [
      '',
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    const hari = [
      'Senin',
      'Selasa',
      'Rabu',
      'Kamis',
      'Jumat',
      'Sabtu',
      'Minggu',
    ];
    return '${hari[d.weekday - 1]}, ${d.day} ${bulan[d.month]} ${d.year}';
  }

  String _formatWaktu(DateTime d) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '$hh:$mm • ${d.day} ${bulan[d.month]} ${d.year}';
  }

  String _statusLabel(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'diproses':
        return 'Diproses';
      case 'selesai':
        return 'Selesai';
      case 'ditolak':
        return 'Ditolak';
      default:
        return 'Unknown';
    }
  }

  Map<String, dynamic> _statusStyle(String raw) {
    switch (raw.toLowerCase()) {
      case 'pending':
        return {
          'bg': _yellowSoft,
          'text': const Color(0xFFB07A10),
          'icon': Icons.schedule_rounded,
        };
      case 'diproses':
        return {
          'bg': _greenSoft,
          'text': _greenDark,
          'icon': Icons.hourglass_top_rounded,
        };
      case 'selesai':
        return {
          'bg': const Color(0xFFDDF4E1),
          'text': const Color(0xFF43804D),
          'icon': Icons.check_circle_rounded,
        };
      case 'ditolak':
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.close_rounded,
        };
      default:
        return {
          'bg': const Color(0xFFEDEDED),
          'text': const Color(0xFF6B6B6B),
          'icon': Icons.help_outline_rounded,
        };
    }
  }

  Map<String, dynamic> _typeStyle(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('chat')) {
      return {
        'label': 'Chat',
        'bg': _pinkSoft,
        'accent': const Color(0xFFE78BA0),
        'icon': Icons.forum_rounded,
      };
    }

    if (lower.contains('comment') || lower.contains('reply')) {
      return {
        'label': 'Komentar',
        'bg': _blueSoft,
        'accent': const Color(0xFF68A8C8),
        'icon': Icons.mode_comment_rounded,
      };
    }

    return {
      'label': 'Diary',
      'bg': _peachSoft,
      'accent': const Color(0xFFD6984E),
      'icon': Icons.book_rounded,
    };
  }

  String _initialOf(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'A';
    return trimmed[0].toUpperCase();
  }

  void _showNotifPopup() {
    showCuteTopPopup(
      context,
      title: 'Dashboard Admin',
      message: _jumlahNotif == 0
          ? 'Belum ada laporan baru.'
          : 'Ada $_jumlahNotif laporan pending.',
      type: _jumlahNotif > 0 ? CutePopupType.warning : CutePopupType.info,
    );
  }

  void _openModerasi() {
    Navigator.pushReplacementNamed(context, '/admin-moderasi');
  }

  void _openBanding() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ListAjuanBandingAdminPage(),
      ),
    );
  }

  void _openProfil() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfilAdminPage(),
      ),
    );
  }

  Future<void> _openLatestReport(_DashboardReportPreview report) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TinjauModerasiAdmin(
          moderasi: report.toModerasiModel(),
        ),
      ),
    );

    if (result == true && mounted) {
      showCuteTopPopup(
        context,
        title: 'Moderasi diperbarui',
        message: 'Perubahan sudah disimpan.',
        type: CutePopupType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned(
            top: -70,
            left: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.65),
              ),
            ),
          ),
          Positioned(
            top: 170,
            right: -70,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenSoft.withOpacity(0.50),
              ),
            ),
          ),
          Positioned(
            bottom: 90,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.90),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(),
                  const SizedBox(height: 18),
                  _buildHeroCard(),
                  const SizedBox(height: 16),
                  _buildQuickActions(),
                  const SizedBox(height: 16),
                  _buildStatCards(),
                  const SizedBox(height: 16),
                  _buildStatistikLaporan(),
                  const SizedBox(height: 18),
                  _buildLaporanTerbaruHeader(),
                  const SizedBox(height: 12),
                  if (!_hasLoaded)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 28),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_laporanTerbaru.isEmpty)
                    _buildEmptyState()
                  else
                    ..._laporanTerbaru.map(_buildLaporanItem),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-moderasi');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/admin-banding');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/admin-profil');
          }
        },
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(20),
            boxShadow: _softShadow,
          ),
          child: Text(
            'Moodly',
            style: GoogleFonts.fredoka(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE78BA0),
            ),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: _showNotifPopup,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: _card,
                  shape: BoxShape.circle,
                  boxShadow: _softShadow,
                ),
                child: const Icon(
                  Icons.notifications_rounded,
                  size: 24,
                  color: Color(0xFF7C8579),
                ),
              ),
              if (_jumlahNotif > 0)
                Positioned(
                  top: -2,
                  right: -1,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE85E73),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _jumlahNotif > 9 ? '9+' : '$_jumlahNotif',
                      style: GoogleFonts.openSans(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _openProfil,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(22),
              boxShadow: _softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC9D7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👩🏻‍💻', style: TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Admin',
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard() {
    final now = DateTime.now();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            top: -18,
            child: Container(
              width: 118,
              height: 118,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.95),
              ),
            ),
          ),
          Positioned(
            right: 18,
            bottom: -12,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenSoft.withOpacity(0.80),
              ),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _greenMint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        'Panel Admin',
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Halo, Admin',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatTanggal(now),
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeroChip(
                          icon: Icons.schedule_rounded,
                          text: '$_laporanPending pending',
                          bg: _yellowSoft,
                          iconColor: const Color(0xFFB07A10),
                          textColor: _textDark,
                        ),
                        _buildHeroChip(
                          icon: Icons.hourglass_top_rounded,
                          text: '$_laporanDiproses diproses',
                          bg: _greenSoft,
                          iconColor: _greenDark,
                          textColor: _textDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: _softShadow,
                ),
                child: const Icon(
                  Icons.shield_rounded,
                  size: 38,
                  color: _greenDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickButton(
            icon: Icons.gavel_rounded,
            label: 'Moderasi',
            bg: _greenMint,
            color: _greenDark,
            onTap: _openModerasi,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildQuickButton(
            icon: Icons.description_rounded,
            label: 'Banding',
            bg: _pinkSoft,
            color: const Color(0xFFE78BA0),
            onTap: _openBanding,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButton({
    required IconData icon,
    required String label,
    required Color bg,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(22),
          boxShadow: _softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroChip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color iconColor,
    required Color textColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: iconColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'Pending',
            value: '$_laporanPending',
            subtitle: 'Buka Moderasi',
            icon: Icons.flag_rounded,
            iconColor: const Color(0xFFE78BA0),
            bgColor: _pinkSoft,
            lineColor: const Color(0xFFF0B8C5),
            onTap: _openModerasi,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'Banding',
            value: '$_bandingPending',
            subtitle: 'Buka Banding',
            icon: Icons.mark_email_unread_rounded,
            iconColor: _greenDark,
            bgColor: _greenMint,
            lineColor: const Color(0xFFCBE6B7),
            onTap: _openBanding,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required Color lineColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(26),
          boxShadow: _softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 5,
              width: 44,
              decoration: BoxDecoration(
                color: lineColor,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, size: 22, color: iconColor),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              value,
              style: GoogleFonts.fredoka(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: _textDark,
                height: 1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: GoogleFonts.openSans(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: _textSoft,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatistikLaporan() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Statistik',
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: _greenMint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  '7 hari',
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _greenDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildLegend(),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            decoration: BoxDecoration(
              color: _greenMint,
              borderRadius: BorderRadius.circular(22),
            ),
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 14,
      runSpacing: 8,
      children: [
        _buildLegendItem(
          color: const Color(0xFFE78BA0),
          label: 'Chat',
        ),
        _buildLegendItem(
          color: const Color(0xFFD6A14F),
          label: 'Diary / Komentar',
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    final data = _graphData.isEmpty
        ? [
            {'day': 'Sen', 'chat': 0, 'diary': 0},
            {'day': 'Sel', 'chat': 0, 'diary': 0},
            {'day': 'Rab', 'chat': 0, 'diary': 0},
            {'day': 'Kam', 'chat': 0, 'diary': 0},
            {'day': 'Jum', 'chat': 0, 'diary': 0},
            {'day': 'Sab', 'chat': 0, 'diary': 0},
            {'day': 'Min', 'chat': 0, 'diary': 0},
          ]
        : _graphData;

    int maxValue = 1;
    for (final item in data) {
      final chatVal = (item['chat'] ?? 0) as int;
      final diaryVal = (item['diary'] ?? 0) as int;
      if (chatVal > maxValue) maxValue = chatVal;
      if (diaryVal > maxValue) maxValue = diaryVal;
    }

    return SizedBox(
      height: 150,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final chatValue = (item['chat'] ?? 0) as int;
          final diaryValue = (item['diary'] ?? 0) as int;

          final chatHeight =
              chatValue > 0 ? (chatValue / maxValue * 86).toDouble() : 6.0;
          final diaryHeight =
              diaryValue > 0 ? (diaryValue / maxValue * 86).toDouble() : 6.0;

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _buildBar(
                    height: chatHeight,
                    color: const Color(0xFFE78BA0),
                  ),
                  const SizedBox(width: 5),
                  _buildBar(
                    height: diaryHeight,
                    color: const Color(0xFFD6A14F),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item['day'] as String,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
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
      width: 14,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(7),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.18),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanTerbaruHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Laporan Terbaru',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
        ),
        GestureDetector(
          onTap: _openModerasi,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: _pinkSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Lihat semua',
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE78BA0),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 22, 18, 22),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: _greenMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inbox_rounded,
              color: _greenDark,
              size: 30,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Belum ada laporan',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Dashboard lagi tenang.',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanItem(_DashboardReportPreview laporan) {
    final typeStyle = _typeStyle(laporan.type);
    final statusStyle = _statusStyle(laporan.status);

    return GestureDetector(
      onTap: () => _openLatestReport(laporan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 7,
              decoration: BoxDecoration(
                color: typeStyle['accent'] as Color,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  bottomLeft: Radius.circular(28),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: typeStyle['bg'] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                typeStyle['icon'] as IconData,
                                size: 14,
                                color: typeStyle['accent'] as Color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                typeStyle['label'] as String,
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: typeStyle['accent'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: statusStyle['bg'] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                statusStyle['icon'] as IconData,
                                size: 14,
                                color: statusStyle['text'] as Color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _statusLabel(laporan.status),
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: statusStyle['text'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            color: typeStyle['bg'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              _initialOf(laporan.reportedByUsername),
                              style: GoogleFonts.fredoka(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: typeStyle['accent'] as Color,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laporan.reportedByUsername,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.openSans(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                laporan.reportedUser,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: _textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFC5CBC0),
                          size: 28,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: typeStyle['bg'] as Color,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        laporan.reportReason.trim().isEmpty
                            ? '"${laporan.contentText.trim().isEmpty ? '-' : laporan.contentText.trim()}"'
                            : '"${laporan.reportReason.trim()}"',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          height: 1.5,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildMetaChip(
                          icon: Icons.schedule_rounded,
                          text: _formatWaktu(laporan.createdAt),
                        ),
                        _buildMetaChip(
                          icon: Icons.tag_rounded,
                          text:
                              '#${laporan.documentId.length > 8 ? laporan.documentId.substring(0, 8).toUpperCase() : laporan.documentId.toUpperCase()}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaChip({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: _greenMint,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: _greenDark),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.openSans(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }
}