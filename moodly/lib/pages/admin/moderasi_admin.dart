import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tinjau_moderasi_admin.dart';
import '../../core/services/auth_service.dart';
import 'login_admin.dart';

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
  final String uid;
  final String nickname;
  final String avatarId;
  final String status; // String, bukan enum
  final bool hasWarning;
  final String warningMessage;
  final DateTime updatedAt;
  final DateTime? warningUpdatedAt;
  final String? currentRoomId;

  ModerasiModel({
    required this.id,
    required this.uid,
    required this.nickname,
    required this.avatarId,
    required this.status,
    required this.hasWarning,
    required this.warningMessage,
    required this.updatedAt,
    this.warningUpdatedAt,
    this.currentRoomId,
  });

  factory ModerasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userData = data['userData'] as Map<String, dynamic>? ?? {};

    return ModerasiModel(
      id: doc.id,
      uid: userData['uid'] ?? data['uid'] ?? '',
      nickname: userData['nickname'] ?? 'Unknown',
      avatarId: userData['avatarId'] ?? '',
      status: userData['status'] ?? 'unknown',
      hasWarning: userData['hasWarning'] ?? false,
      warningMessage: userData['warningMessage'] ?? '',
      updatedAt: _parseTimestamp(userData['updatedAt']) ?? DateTime.now(),
      warningUpdatedAt: _parseTimestamp(userData['warningUpdatedAt']),
      currentRoomId: userData['currentRoomId'],
    );
  }

  static DateTime? _parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is DateTime) {
      return value;
    }
    return null;
  }

  // ✅ Helper untuk konversi String status ke enum
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

  String get displayName => nickname.isNotEmpty ? nickname : 'User';
  String get avatarPath => avatarId.isNotEmpty ? avatarId : '';
}

class ModerasiService {
  final _col = FirebaseFirestore.instance.collection('reportedUserInfo');

  Future<List<ModerasiModel>> getModerasiList() async {
    try {
      final snap = await _col.get();
      final list = snap.docs.map((d) => ModerasiModel.fromFirestore(d)).toList();
      list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      return list;
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      return [];
    }
  }

  Future<int> getPendingCount() async {
    try {
      final snap = await _col
          .where('userData.hasWarning', isEqualTo: true)
          .get();
      return snap.docs.length;
    } catch (e) {
      debugPrint('❌ Error counting pending: $e');
      return 0;
    }
  }

  Future<bool> giveWarning({
    required String uid,
    required String message,
  }) async {
    try {
      await _col.doc(uid).update({
        'userData.hasWarning': true,
        'userData.warningMessage': message,
        'userData.warningUpdatedAt': FieldValue.serverTimestamp(),
        'userData.chatNotice': message,
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error giving warning: $e');
      return false;
    }
  }

  Future<bool> clearWarning({required String uid}) async {
    try {
      await _col.doc(uid).update({
        'userData.hasWarning': false,
        'userData.warningMessage': '',
        'userData.chatNotice': null,
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error clearing warning: $e');
      return false;
    }
  }

  Future<bool> banUser({
    required String uid,
    required String durasi,
  }) async {
    try {
      await _col.doc(uid).update({
        'userData.status': 'banned',
        'userData.hasWarning': true,
        'userData.warningMessage': 'Akun Anda dibanned selama $durasi',
      });
      return true;
    } catch (e) {
      debugPrint('❌ Error banning user: $e');
      return false;
    }
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
  final ScrollController _scrollController = ScrollController();

  List<ModerasiModel> _list = [];
  int _jumlahNotif = 0;

  String _selectedTab = 'Semua';
  final List<String> _tabs = ['Semua', 'Pending', 'Diproses', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadData();
    _loadNotif();
  }

  Future<void> _loadData() async {
    final data = await _service.getModerasiList();
    if (!mounted) return;
    setState(() => _list = data);
  }

  Future<void> _loadNotif() async {
    final count = await _service.getPendingCount();
    if (!mounted) return;
    setState(() => _jumlahNotif = count);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<ModerasiModel> get _filtered {
    final kw = _searchController.text.toLowerCase();

    final result = _list.where((m) {
      final matchSearch = m.id.toLowerCase().contains(kw) ||
          m.nickname.toLowerCase().contains(kw) ||
          m.uid.toLowerCase().contains(kw);

      // ✅ Gunakan statusEnum untuk perbandingan
      final matchTab = _selectedTab == 'Semua' ||
          m.statusEnum.label.toLowerCase() == _selectedTab.toLowerCase();

      return matchSearch && matchTab;
    }).toList();

    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return result;
  }

  int _countByStatus(ModerasiStatus s) =>
      _list.where((m) => m.statusEnum == s).length;

  String _formatTanggal(DateTime d) {
    const bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${bulan[d.month]} ${d.year}';
  }

  Color _badgeColor(ModerasiStatus s) {
    switch (s) {
      case ModerasiStatus.pending:
        return const Color(0xFFF2F4D9);
      case ModerasiStatus.diproses:
        return const Color(0xFFDDF1D2);
      case ModerasiStatus.selesai:
        return const Color(0xFFAEDB9A);
      case ModerasiStatus.ditolak:
        return const Color(0xFFF8D7DA);
    }
  }

  Color _badgeTextColor(ModerasiStatus s) {
    switch (s) {
      case ModerasiStatus.pending:
        return const Color(0xFF9A5606);
      case ModerasiStatus.diproses:
        return const Color(0xFF49A828);
      case ModerasiStatus.selesai:
        return const Color(0xFF20560A);
      case ModerasiStatus.ditolak:
        return const Color(0xFF721C24);
    }
  }

  double _scrollbarTop(double viewportH) {
    const startTop = 300.0;
    const bottomSpace = 95.0;
    const thumbH = 45.0;
    final trackH = viewportH - startTop - bottomSpace;

    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0 ||
        trackH <= thumbH) return startTop;

    final frac =
    (_scrollController.offset / _scrollController.position.maxScrollExtent)
        .clamp(0.0, 1.0);

    return startTop + (trackH - thumbH) * frac;
  }

  // 🔔 NOTIFICATION POPUP
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

  // 🚪 LOGOUT DIALOG
  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: const Color(0xFFF1FBD8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings_rounded,
                    color: Color(0xFFFF8EA4), size: 48),
                const SizedBox(height: 14),
                Text(
                  'Keluar dari Akun Admin?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF486253),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Anda akan kembali ke halaman login admin.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Batal',
                        color: const Color(0xFFDDF5C5),
                        textColor: const Color(0xFF486253),
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'Keluar',
                        color: const Color(0xFFFFD7DD),
                        textColor: const Color(0xFF721C24),
                        onTap: () async {
                          Navigator.pop(context);

                          try {
                            await AuthService.instance.signOut();

                            if (!mounted) return;

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const AdminLoginPage(),
                              ),
                                  (route) => false,
                            );
                          } catch (e) {
                            debugPrint('❌ Admin logout error: $e');

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Logout gagal: ${e.toString()}',
                                  style: GoogleFonts.openSans(color: Colors.white),
                                ),
                                backgroundColor: const Color(0xFF721C24),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 20),
                      _buildTitleSection(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      const SizedBox(height: 18),
                      _buildTabs(),
                      const SizedBox(height: 18),
                      if (filtered.isEmpty)
                        _buildEmptyState()
                      else
                        ...filtered.map(_buildCard),
                    ],
                  ),
                ),
                Positioned(
                  right: 4,
                  top: _scrollbarTop(constraints.maxHeight),
                  child: Container(
                    width: 5,
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),

      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(
              context,
              '/admin-dashboard',
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
          onTap: _showLogoutDialog,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEF1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFFF8EA4), width: 1),
            ),
            child: Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC4D7),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text('👩‍💻', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'Admin',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0C0E0C),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.logout_rounded,
                    size: 14, color: Color(0xFF721C24)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Moderasi',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFF486253),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Kelola Laporan untuk Moderasi',
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

  Widget _buildSearchBar() {
    return SizedBox(
      height: 36,
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        style: GoogleFonts.openSans(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 22 / 14,
          color: const Color(0xFF0C0E0C),
        ),
        decoration: InputDecoration(
          hintText: 'Cari ID, user atau kata kunci...',
          hintStyle: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            color: const Color(0xFF8F8F8F),
          ),
          prefixIcon: const Icon(Icons.search_rounded,
              color: Color(0xFF0C0E0C), size: 22),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 0, vertical: 7),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(19),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Column(
      children: [
        SizedBox(
          height: 28,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _tabs.map((tab) {
              final isSelected = _selectedTab == tab;
              final count = tab == 'Pending'
                  ? _countByStatus(ModerasiStatus.pending)
                  : tab == 'Diproses'
                  ? _countByStatus(ModerasiStatus.diproses)
                  : null;

              return GestureDetector(
                onTap: () => setState(() => _selectedTab = tab),
                child: SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            tab,
                            style: GoogleFonts.openSans(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              height: 22 / 12,
                              color: const Color(0xFF0C0E0C),
                            ),
                          ),
                          if (count != null) ...[
                            const SizedBox(width: 3),
                            Container(
                              width: 13,
                              height: 13,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: tab == 'Pending'
                                    ? const Color(0xFFE5EA75)
                                    : const Color(0xFF9FDFB0),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.openSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: tab == 'Pending'
                                      ? const Color(0xFFB7A82E)
                                      : const Color(0xFF37A75B),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        height: 3,
                        width: isSelected ? 44 : 0,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF8EA4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Container(height: 1, color: const Color(0xFFD9E3C8)),
      ],
    );
  }

  Widget _buildCard(ModerasiModel m) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TinjauModerasiAdmin(moderasi: m),
          ),
        );
        if (result == true) _loadData();
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(left: 20, right: 12, bottom: 20),
        padding: const EdgeInsets.fromLTRB(17, 14, 17, 17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCardTop(m),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildUserIcon(m),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m.nickname,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C0E0C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.uid,
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (m.hasWarning)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD9DD),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '⚠️ Warning',
                      style: GoogleFonts.openSans(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF721C24),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (m.warningMessage.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F4D9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  m.warningMessage,
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF9A5606),
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: const Color(0xFF6B6B6B),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTanggal(m.updatedAt),
                  style: GoogleFonts.openSans(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B6B6B),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTop(ModerasiModel m) {
    return Row(
      children: [
        SizedBox(
          width: 88,
          height: 28,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '#MD-${m.id.substring(0, 4).toUpperCase()}',
              style: GoogleFonts.fredoka(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 22 / 16,
                color: Colors.black.withOpacity(0.8),
              ),
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: 70,
          height: 14,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _badgeColor(m.statusEnum),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            m.statusEnum.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1,
              color: _badgeTextColor(m.statusEnum),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserIcon(ModerasiModel m) {
    if (m.avatarPath.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          m.avatarPath,
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD18B),
        shape: BoxShape.circle,
      ),
      child: const Text(
        '☁',
        style: TextStyle(
          fontSize: 20,
          color: Color(0xFF2B2B2B),
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20, right: 12),
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          const Icon(Icons.inbox_outlined, size: 48, color: Color(0xFFA9E39A)),
          const SizedBox(height: 10),
          Text(
            'Tidak ada laporan moderasi',
            style: GoogleFonts.openSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF333333),
            ),
          ),
        ],
      ),
    );
  }
}

// 🎨 DIALOG BUTTON WIDGET
class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: textColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}