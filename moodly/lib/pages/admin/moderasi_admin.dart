import 'package:flutter/material.dart';
import 'dart:async';
import 'package:google_fonts/google_fonts.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'tinjau_moderasi_admin.dart';
import 'profil_admin_page.dart';

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
  });

  factory ModerasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return ModerasiModel(
      id: doc.id,
      contentText: data['content_text'] ?? '',
      reportCategory: data['report_category'] ?? '',
      reportReason: data['report_reason'] ?? '',
      reportedByUid: data['reported_by_uid'] ?? '',
      reportedByUsername: data['reported_by_username'] ?? '',
      reportedProfile: data['reported_profile'] ?? '',
      reportedUid: data['reported_uid'] ?? '',
      reportedUser: data['reported_user'] ?? '',
      targetId: data['target_id'] ?? '',
      status: data['status'] ?? 'pending',
      catatanAdmin: data['catatanAdmin'] ?? '',
      createdAt: _parseTimestamp(data['created_at']) ?? DateTime.now(),
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

  String get displayName => reportedByUsername.isNotEmpty ? reportedByUsername : 'User';
}

class ModerasiService {
  final _col = FirebaseFirestore.instance.collection('reports');

  Stream<QuerySnapshot> getReportsStream() {
    return _col.orderBy('created_at', descending: true).snapshots();
  }

  Stream<int> getPendingCountStream() {
    return _col
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<List<ModerasiModel>> getModerasiList() async {
    try {
      final snap = await _col.orderBy('created_at', descending: true).get();
      return snap.docs.map((d) => ModerasiModel.fromFirestore(d)).toList();
    } catch (e) {
      debugPrint('❌ Error fetching reports: $e');
      return [];
    }
  }

  Future<int> getPendingCount() async {
    try {
      final snap = await _col
          .where('status', isEqualTo: 'pending')
          .get();
      return snap.docs.length;
    } catch (e) {
      debugPrint('❌ Error counting pending: $e');
      return 0;
    }
  }

  Future<bool> updateStatus({
    required String docId,
    required String status,
    String? catatanAdmin,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'status': status,
      };

      if (catatanAdmin != null) {
        updateData['catatanAdmin'] = catatanAdmin;
      }

      await _col.doc(docId).update(updateData);
      return true;
    } catch (e) {
      debugPrint('❌ Error updating status: $e');
      return false;
    }
  }

  Future<bool> giveWarning({
    required String uid,
    required String message,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .doc(uid)
          .update({
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
      await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .doc(uid)
          .update({
        'userData.hasWarning': false,
        'userData.warningMessage': '',
        'userData.chatNotice': null,
      });
      return true;
    } catch (e) {
      debugPrint(' Error clearing warning: $e');
      return false;
    }
  }

  Future<bool> banUser({
    required String uid,
    required String durasi,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('reportedUserInfo')
          .doc(uid)
          .update({
        'userData.status': 'banned',
        'userData.hasWarning': true,
        'userData.warningMessage': 'Akun Anda dibanned selama $durasi',
      });
      return true;
    } catch (e) {
      debugPrint(' Error banning user: $e');
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

  StreamSubscription<QuerySnapshot>? _reportsSubscription;
  StreamSubscription<int>? _pendingCountSubscription;

  String _selectedTab = 'Semua';
  String _selectedTipe = 'Semua tipe';
  String _selectedTanggal = 'Terbaru';

  final List<String> _tabs = ['Semua', 'Pending', 'Diproses', 'Selesai'];
  final List<String> _tipeOptions = [
    'Semua tipe',
    'Spam',
    'Konten Tidak Pantas',
  ];
  final List<String> _tanggalOptions = ['Terbaru', 'Terlama'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _setupRealtimeListeners();
  }

  void _setupRealtimeListeners() {
    _reportsSubscription = _service.getReportsStream().listen((snapshot) {
      if (!mounted) return;
      final data = snapshot.docs.map((d) => ModerasiModel.fromFirestore(d)).toList();
      setState(() {
        _list = data;
      });
    });

    _pendingCountSubscription = _service.getPendingCountStream().listen((count) {
      if (!mounted) return;
      setState(() {
        _jumlahNotif = count;
      });
    });
  }

  void _onScroll() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _reportsSubscription?.cancel();
    _pendingCountSubscription?.cancel();
    super.dispose();
  }

  List<ModerasiModel> get _filtered {
    final kw = _searchController.text.toLowerCase().trim();

    var filtered = _list.where((m) {
      if (kw.isEmpty) return true;
      return m.id.toLowerCase().contains(kw) ||
          m.reportedByUsername.toLowerCase().contains(kw) ||
          m.reportedByUid.toLowerCase().contains(kw) ||
          m.contentText.toLowerCase().contains(kw) ||
          m.reportReason.toLowerCase().contains(kw);
    });

    if (_selectedTab != 'Semua') {
      final targetStatus = _selectedTab.toLowerCase();
      filtered = filtered.where((m) => m.statusEnum.label.toLowerCase() == targetStatus);
    }

    if (_selectedTipe != 'Semua tipe') {
      final targetTipe = _selectedTipe.toLowerCase().trim();
      filtered = filtered.where((m) {
        final dbTipe = m.reportCategory.toLowerCase().trim();
        return dbTipe == targetTipe || dbTipe.contains(targetTipe);
      });
    }

    final sortedList = filtered.toList();

    if (_selectedTanggal == 'Terlama') {
      sortedList.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    } else {
      sortedList.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    if (_selectedTipe != 'Semua tipe') {
      return sortedList.take(5).toList();
    }

    return sortedList;
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
                      const SizedBox(height: 10),
                      _buildFilterRow(),
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
                '‍💻',
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

  Widget _buildFilterRow() {
    return Row(
      children: [
        _buildSmallDropdown(
          value: _selectedTipe,
          items: _tipeOptions,
          width: 140,
          onChanged: (value) {
            setState(() {
              _selectedTipe = value!;
            });
          },
        ),
        const SizedBox(width: 10),
        _buildSmallDropdown(
          value: _selectedTanggal,
          items: _tanggalOptions,
          width: 95,
          onChanged: (value) {
            setState(() {
              _selectedTanggal = value!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSmallDropdown({
    required String value,
    required List<String> items,
    required double width,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      width: width,
      height: 23,
      padding: const EdgeInsets.only(left: 13, right: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: Colors.black,
          ),
          dropdownColor: Colors.white,
          style: GoogleFonts.openSans(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            height: 22 / 12,
            color: const Color(0xFF0C0E0C),
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
                onTap: () {
                  setState(() {
                    _selectedTab = tab;
                  });
                },
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
        if (result == true) {
        }
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
                        m.reportedByUsername,
                        style: GoogleFonts.openSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF0C0E0C),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m.reportCategory,
                        style: GoogleFonts.openSans(
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B8B8B),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                m.contentText.length > 100
                    ? '${m.contentText.substring(0, 100)}...'
                    : m.contentText,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF333333),
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
                  _formatTanggal(m.createdAt),
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
              '#${m.id.substring(0, 8).toUpperCase()}',
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
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD18B),
        shape: BoxShape.circle,
      ),
      child: Text(
        m.reportedByUsername.isNotEmpty
            ? m.reportedByUsername[0].toUpperCase()
            : 'U',
        style: const TextStyle(
          fontSize: 12,
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