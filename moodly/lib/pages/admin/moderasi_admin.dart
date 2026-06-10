import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/admin_bottom_navbar.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'profil_admin_page.dart';
import 'tinjau_moderasi_admin.dart';

enum ModerasiStatus { pending, diproses, selesai, ditolak }

extension ModerasiStatusLabel on ModerasiStatus {
  String get label {
    switch (this) {
      case ModerasiStatus.pending:
        return 'Pending';
      case ModerasiStatus.diproses:
        return 'Diproses';
      case ModerasiStatus.selesai:
        return 'Selesai';
      case ModerasiStatus.ditolak:
        return 'Ditolak';
    }
  }
}

class ModerasiModel {
  final String id;
  final String contentText;
  final String reportCategory;
  final String reportReason;
  final String reportedByUid;
  final String reportedByUsername;
  final String reportedProfile;
  final String reportedUid;
  final String reportedUser;
  final String targetId;
  final String status;
  final String catatanAdmin;
  final DateTime createdAt;
  final String type;

  ModerasiModel({
    required this.id,
    required this.contentText,
    required this.reportCategory,
    required this.reportReason,
    required this.reportedByUid,
    required this.reportedByUsername,
    required this.reportedProfile,
    required this.reportedUid,
    required this.reportedUser,
    required this.targetId,
    required this.status,
    required this.catatanAdmin,
    required this.createdAt,
    required this.type,
  });

  factory ModerasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    DateTime parseDate() {
      final raw = data['created_at'] ?? data['createdAt'];
      if (raw is Timestamp) return raw.toDate();
      if (raw is DateTime) return raw;
      if (raw is String) return DateTime.tryParse(raw) ?? DateTime.now();
      return DateTime.now();
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

    String extractReporterName() {
      final direct = (data['reported_by_username'] ?? '').toString().trim();
      if (direct.isNotEmpty) return direct;

      final reporterInfo = data['reporterInfo'];
      if (reporterInfo is Map<String, dynamic>) {
        final displayName = (reporterInfo['displayName'] ?? '').toString().trim();
        if (displayName.isNotEmpty) return displayName;
      }

      return 'Pelapor';
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

    return ModerasiModel(
      id: doc.id,
      contentText: (data['content_text'] ?? data['isiLaporan'] ?? '').toString(),
      reportCategory:
          (data['report_category'] ?? data['reportCategory'] ?? '').toString(),
      reportReason:
          (data['report_reason'] ?? data['reportReason'] ?? '').toString(),
      reportedByUid: (data['reported_by_uid'] ?? '').toString(),
      reportedByUsername: extractReporterName(),
      reportedProfile: extractAvatar(),
      reportedUid:
          (data['reported_uid'] ?? data['reportedUid'] ?? '').toString(),
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
      type: extractType(),
    );
  }

  ModerasiStatus get statusEnum {
    switch (status.toLowerCase()) {
      case 'diproses':
        return ModerasiStatus.diproses;
      case 'selesai':
        return ModerasiStatus.selesai;
      case 'ditolak':
        return ModerasiStatus.ditolak;
      default:
        return ModerasiStatus.pending;
    }
  }

  String get reporterDisplayName =>
      reportedByUsername.trim().isNotEmpty ? reportedByUsername : 'Pelapor';

  String get reportedDisplayName =>
      reportedUser.trim().isNotEmpty ? reportedUser : 'User';

  String get shortContent {
    final clean = contentText.trim();
    if (clean.isEmpty) return 'Konten tidak tersedia';
    if (clean.length <= 120) return clean;
    return '${clean.substring(0, 120)}...';
  }

  String get typeLabel {
    final lower = type.toLowerCase();
    if (lower.contains('chat')) return 'Chat';
    if (lower.contains('comment') || lower.contains('reply')) return 'Komentar';
    return 'Diary';
  }

  String get uniqueUserKey {
    if (reportedUid.trim().isNotEmpty) return reportedUid.trim();
    return reportedDisplayName.toLowerCase().trim();
  }
}

class ModerasiService {
  final CollectionReference<Map<String, dynamic>> _col =
      FirebaseFirestore.instance.collection('reports');

  Stream<QuerySnapshot<Map<String, dynamic>>> getReportsStream() {
    return _col.snapshots();
  }

  Stream<int> getPendingCountStream() {
    return _col
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
}

class ModerasiAdminPage extends StatefulWidget {
  const ModerasiAdminPage({super.key});

  @override
  State<ModerasiAdminPage> createState() => _ModerasiAdminPageState();
}

class _ModerasiAdminPageState extends State<ModerasiAdminPage> {
  final ModerasiService _service = ModerasiService();
  final TextEditingController _searchController = TextEditingController();

  List<ModerasiModel> _list = [];
  Map<String, int> _userViolationMap = {};
  int _jumlahNotif = 0;
  bool _hasLoaded = false;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reportsSubscription;
  StreamSubscription<int>? _pendingCountSubscription;

  String _selectedTab = 'Semua';
  String _selectedTipe = 'Semua tipe';
  String _selectedTanggal = 'Terbaru';
  String _selectedUserMode = 'Semua user';

  final List<String> _tabs = ['Semua', 'Pending', 'Diproses', 'Selesai'];
  final List<String> _tipeOptions = [
    'Semua tipe',
    'Diary',
    'Komentar',
    'Chat',
  ];
  final List<String> _tanggalOptions = ['Terbaru', 'Terlama'];
  final List<String> _userOptions = [
    'Semua user',
    'Pelanggar berulang',
    'Sudah ditindak',
  ];

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
        ),
      ];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    _reportsSubscription = _service.getReportsStream().listen((snapshot) {
      if (!mounted) return;

      final data = snapshot.docs.map((d) => ModerasiModel.fromFirestore(d)).toList();
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final Map<String, int> counts = {};
      for (final item in data) {
        counts[item.uniqueUserKey] = (counts[item.uniqueUserKey] ?? 0) + 1;
      }

      setState(() {
        _list = data;
        _userViolationMap = counts;
        _hasLoaded = true;
      });
    });

    _pendingCountSubscription = _service.getPendingCountStream().listen((count) {
      if (!mounted) return;
      setState(() {
        _jumlahNotif = count;
      });
    });
  }

  int _violationCountFor(ModerasiModel model) {
    return _userViolationMap[model.uniqueUserKey] ?? 1;
  }

  bool _isRepeatOffender(ModerasiModel model) {
    return _violationCountFor(model) >= 2;
  }

  int get _repeatOffenderCount {
    final seen = <String>{};
    int total = 0;

    for (final item in _list) {
      if (_isRepeatOffender(item) && !seen.contains(item.uniqueUserKey)) {
        seen.add(item.uniqueUserKey);
        total++;
      }
    }

    return total;
  }

  List<ModerasiModel> get _filtered {
    final kw = _searchController.text.toLowerCase().trim();

    var filtered = _list.where((m) {
      final matchKeyword = kw.isEmpty ||
          m.id.toLowerCase().contains(kw) ||
          m.reporterDisplayName.toLowerCase().contains(kw) ||
          m.reportedDisplayName.toLowerCase().contains(kw) ||
          m.reportedByUid.toLowerCase().contains(kw) ||
          m.reportedUid.toLowerCase().contains(kw) ||
          m.contentText.toLowerCase().contains(kw) ||
          m.reportReason.toLowerCase().contains(kw) ||
          m.reportCategory.toLowerCase().contains(kw);

      final matchTab = _selectedTab == 'Semua'
          ? true
          : m.statusEnum.label.toLowerCase() == _selectedTab.toLowerCase();

      final matchType = _selectedTipe == 'Semua tipe'
          ? true
          : m.typeLabel.toLowerCase() == _selectedTipe.toLowerCase();

      final matchUserMode = _selectedUserMode == 'Semua user'
          ? true
          : _selectedUserMode == 'Pelanggar berulang'
              ? _isRepeatOffender(m)
              : m.statusEnum != ModerasiStatus.pending;

      return matchKeyword && matchTab && matchType && matchUserMode;
    }).toList();

    if (_selectedTanggal == 'Terlama') {
      filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  int _countByStatus(ModerasiStatus status) {
    return _list.where((m) => m.statusEnum == status).length;
  }

  String _formatTanggalJam(DateTime d) {
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

  Map<String, dynamic> _statusStyle(ModerasiStatus status) {
    switch (status) {
      case ModerasiStatus.pending:
        return {
          'bg': _yellowSoft,
          'text': const Color(0xFFB07A10),
          'icon': Icons.schedule_rounded,
        };
      case ModerasiStatus.diproses:
        return {
          'bg': _greenSoft,
          'text': _greenDark,
          'icon': Icons.hourglass_top_rounded,
        };
      case ModerasiStatus.selesai:
        return {
          'bg': const Color(0xFFDDF4E1),
          'text': const Color(0xFF43804D),
          'icon': Icons.check_circle_rounded,
        };
      case ModerasiStatus.ditolak:
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.close_rounded,
        };
    }
  }

  Map<String, dynamic> _categoryStyle(ModerasiModel model) {
    final type = model.type.toLowerCase();

    if (type.contains('chat')) {
      return {
        'bg': _pinkSoft,
        'text': const Color(0xFFE78BA0),
        'icon': Icons.forum_rounded,
      };
    }

    if (type.contains('comment') || type.contains('reply')) {
      return {
        'bg': _blueSoft,
        'text': const Color(0xFF68A8C8),
        'icon': Icons.mode_comment_rounded,
      };
    }

    return {
      'bg': _peachSoft,
      'text': const Color(0xFFD6984E),
      'icon': Icons.book_rounded,
    };
  }

  String _shortId(String id) {
    if (id.length <= 8) return id.toUpperCase();
    return id.substring(0, 8).toUpperCase();
  }

  String _initialOf(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }

  Widget _buildUserAvatar({
    required String imagePath,
    required String fallbackName,
    required Color accent,
  }) {
    if (imagePath.trim().isNotEmpty) {
      if (imagePath.startsWith('http')) {
        return ClipOval(
          child: Image.network(
            imagePath,
            width: 54,
            height: 54,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => _fallbackAvatar(fallbackName, accent),
          ),
        );
      }

      return ClipOval(
        child: Image.asset(
          imagePath,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallbackAvatar(fallbackName, accent),
        ),
      );
    }

    return _fallbackAvatar(fallbackName, accent);
  }

  Widget _fallbackAvatar(String name, Color accent) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.14),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialOf(name),
        style: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: accent,
        ),
      ),
    );
  }

  void _showNotifPopup() {
    showCuteTopPopup(
      context,
      title: 'Moderasi',
      message: _jumlahNotif == 0
          ? 'Belum ada laporan baru.'
          : 'Ada $_jumlahNotif laporan pending.',
      type: _jumlahNotif > 0 ? CutePopupType.warning : CutePopupType.info,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _reportsSubscription?.cancel();
    _pendingCountSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
            bottom: 100,
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
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        _buildHeroCard(),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
                        const SizedBox(height: 12),
                        _buildFilterWrap(),
                        const SizedBox(height: 16),
                        _buildTabs(),
                        const SizedBox(height: 16),
                        if (!_hasLoaded)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 56),
                              child: CircularProgressIndicator(),
                            ),
                          )
                        else if (filtered.isEmpty)
                          _buildEmptyState()
                        else
                          ...filtered.map(_buildCard),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
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
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProfilAdminPage(),
              ),
            );
          },
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
                        'Pusat Moderasi',
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Moderasi',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeroChip(
                          icon: Icons.schedule_rounded,
                          text: '${_countByStatus(ModerasiStatus.pending)} pending',
                          bg: _yellowSoft,
                          iconColor: const Color(0xFFB07A10),
                        ),
                        _buildHeroChip(
                          icon: Icons.hourglass_top_rounded,
                          text: '${_countByStatus(ModerasiStatus.diproses)} diproses',
                          bg: _greenSoft,
                          iconColor: _greenDark,
                        ),
                        _buildHeroChip(
                          icon: Icons.gpp_good_rounded,
                          text: '$_repeatOffenderCount berulang',
                          bg: _pinkSoft,
                          iconColor: const Color(0xFFE78BA0),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.95),
                  boxShadow: _softShadow,
                ),
                child: const Icon(
                  Icons.gavel_rounded,
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

  Widget _buildHeroChip({
    required IconData icon,
    required String text,
    required Color bg,
    required Color iconColor,
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
              color: _textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow,
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _textDark,
        ),
        decoration: InputDecoration(
          hintText: 'Cari ID, user, atau alasan...',
          hintStyle: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF9AA097),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: _greenDark,
            size: 22,
          ),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Color(0xFF9AA097),
                  ),
                ),
          filled: true,
          fillColor: _card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterWrap() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        SizedBox(
          width: 155,
          child: _buildDropdown(
            value: _selectedTipe,
            items: _tipeOptions,
            onChanged: (value) {
              setState(() => _selectedTipe = value!);
            },
          ),
        ),
        SizedBox(
          width: 155,
          child: _buildDropdown(
            value: _selectedUserMode,
            items: _userOptions,
            onChanged: (value) {
              setState(() => _selectedUserMode = value!);
            },
          ),
        ),
        SizedBox(
          width: 155,
          child: _buildDropdown(
            value: _selectedTanggal,
            items: _tanggalOptions,
            onChanged: (value) {
              setState(() => _selectedTanggal = value!);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _softShadow,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: _textDark,
          ),
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _textDark,
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Row(
      children: _tabs.map((tab) {
        final isSelected = _selectedTab == tab;

        final count = tab == 'Pending'
            ? _countByStatus(ModerasiStatus.pending)
            : tab == 'Diproses'
                ? _countByStatus(ModerasiStatus.diproses)
                : tab == 'Selesai'
                    ? _countByStatus(ModerasiStatus.selesai)
                    : _list.length;

        Color chipColor;
        Color chipTextColor;

        if (tab == 'Pending') {
          chipColor = _yellowSoft;
          chipTextColor = const Color(0xFFB07A10);
        } else if (tab == 'Diproses') {
          chipColor = _greenSoft;
          chipTextColor = _greenDark;
        } else if (tab == 'Selesai') {
          chipColor = const Color(0xFFDDF4E1);
          chipTextColor = const Color(0xFF43804D);
        } else {
          chipColor = _greenMint;
          chipTextColor = _greenDark;
        }

        return Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() => _selectedTab = tab);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? _card : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isSelected ? _softShadow : null,
              ),
              child: Column(
                children: [
                  Text(
                    tab,
                    style: GoogleFonts.openSans(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: chipColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '$count',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: chipTextColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: isSelected ? 34 : 0,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE78BA0),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCard(ModerasiModel m) {
    final statusStyle = _statusStyle(m.statusEnum);
    final categoryStyle = _categoryStyle(m);
    final avatarAccent = categoryStyle['text'] as Color;
    final violationCount = _violationCountFor(m);

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TinjauModerasiAdmin(moderasi: m),
          ),
        );

        if (result == true && mounted) {
          showCuteTopPopup(
            context,
            title: 'Moderasi diperbarui',
            message: 'Perubahan sudah diterapkan.',
            type: CutePopupType.success,
          );
        }
      },
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
                color: avatarAccent,
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
                            color: _greenMint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            '#${_shortId(m.id)}',
                            style: GoogleFonts.openSans(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _greenDark,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (violationCount >= 2)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 7,
                            ),
                            decoration: BoxDecoration(
                              color: _pinkSoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${violationCount}x',
                              style: GoogleFonts.openSans(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFE78BA0),
                              ),
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
                                m.statusEnum.label,
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: categoryStyle['bg'] as Color,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryStyle['icon'] as IconData,
                                size: 14,
                                color: categoryStyle['text'] as Color,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                m.typeLabel,
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: categoryStyle['text'] as Color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _greenMint,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 14,
                                color: _greenDark,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTanggalJam(m.createdAt),
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: _textSoft,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildUserAvatar(
                          imagePath: m.reportedProfile,
                          fallbackName: m.reportedDisplayName,
                          accent: avatarAccent,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                m.reportedDisplayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.fredoka(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: _textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.reporterDisplayName,
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
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFFC5CBC0),
                          size: 30,
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: categoryStyle['bg'] as Color,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        '“${m.shortContent}”',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.openSans(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w700,
                          color: _textDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      m.reportReason.trim().isEmpty
                          ? 'Tanpa alasan tambahan'
                          : m.reportReason,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w700,
                        color: _textSoft,
                      ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 28),
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
            'Ruang moderasi lagi tenang.',
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
}