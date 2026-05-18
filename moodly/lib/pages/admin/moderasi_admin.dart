import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final String namaTerlapor;
  final String avatarTerlapor;
  final String tipeKonten;
  final String isiKonten;
  final ModerasiStatus status;
  final DateTime tanggal;
  final double jam;

  ModerasiModel({
    required this.id,
    required this.namaTerlapor,
    required this.avatarTerlapor,
    required this.tipeKonten,
    required this.isiKonten,
    required this.status,
    required this.tanggal,
    required this.jam,
  });

  factory ModerasiModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ModerasiModel(
      id: doc.id,
      namaTerlapor: data['namaTerlapor'] ?? '',
      avatarTerlapor: data['avatarTerlapor'] ?? '',
      tipeKonten: data['tipeKonten'] ?? '',
      isiKonten: data['isiKonten'] ?? '',
      status: _parseStatus(data['status'] ?? 'pending'),
      tanggal: (data['tanggal'] as Timestamp?)?.toDate() ?? DateTime.now(),
      jam: (data['jam'] ?? 0).toDouble(),
    );
  }

  static ModerasiStatus _parseStatus(String s) {
    switch (s) {
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
}

class ModerasiService {
  final _col = FirebaseFirestore.instance.collection('moderasi');

  Future<List<ModerasiModel>> getModerasiList() async {
    final snap = await _col.orderBy('tanggal', descending: true).get();
    return snap.docs.map((d) => ModerasiModel.fromFirestore(d)).toList();
  }

  Future<int> getPendingCount() async {
    final snap = await _col.where('status', isEqualTo: 'pending').get();
    return snap.docs.length;
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

  // ✅ TABS DIPERTAHANKAN
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

  // 🔍 Filter: Search + Tab Status (tanpa tipe & tanggal)
  List<ModerasiModel> get _filtered {
    final kw = _searchController.text.toLowerCase();

    final result = _list.where((m) {
      final matchSearch = m.id.toLowerCase().contains(kw) ||
          m.namaTerlapor.toLowerCase().contains(kw) ||
          m.isiKonten.toLowerCase().contains(kw) ||
          m.tipeKonten.toLowerCase().contains(kw);

      final matchTab = _selectedTab == 'Semua' ||
          m.status.label.toLowerCase() == _selectedTab.toLowerCase();

      return matchSearch && matchTab;
    }).toList();

    // Default: urutkan dari terbaru
    result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return result;
  }

  int _countByStatus(ModerasiStatus s) =>
      _list.where((m) => m.status == s).length;

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
                      const SizedBox(height: 18),
                      // ✅ TABS DIPERTAHANKAN
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
        Container(
          width: 38,
          height: 38,
          decoration: const BoxDecoration(
            color: Color(0xFFFFC4D7),
            shape: BoxShape.circle,
          ),
          child: const Center(child: Text('👩🏻‍💻', style: TextStyle(fontSize: 20))),
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

  // ✅ TABS: Semua | Pending | Diproses | Selesai
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
    final isChat = m.tipeKonten == 'Chat Anonim';
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => tinjau_moderasi_admin(moderasi: m),
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
            const SizedBox(height: 8),
            _buildTypeBadge(
              label: m.tipeKonten,
              icon: isChat ? Icons.forum_rounded : Icons.menu_book_rounded,
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                _buildUserIcon(m),
                const SizedBox(width: 7),
                Text(
                  m.namaTerlapor,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 22 / 12,
                    color: const Color(0xFF0C0E0C),
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: 49,
                  height: 22,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _formatTanggal(m.tanggal),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        fontSize: 8,
                        fontWeight: FontWeight.w400,
                        height: 22 / 8,
                        color: const Color(0xFF6B6B6B),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Text(
              '"${m.isiKonten}"',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                height: 22 / 12,
                color: const Color(0xFF0C0E0C),
              ),
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
            color: _badgeColor(m.status),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            m.status.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1,
              color: _badgeTextColor(m.status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge({required String label, required IconData icon}) {
    return Container(
      width: 104,
      height: 28,
      padding: const EdgeInsets.only(left: 8, right: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD9DD),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 5,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 22, color: const Color(0xFFFF8E99)),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                height: 22 / 11,
                color: const Color(0xFF000000),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserIcon(ModerasiModel m) {
    if (m.avatarTerlapor.isNotEmpty) {
      return ClipOval(
        child: Image.asset(
          m.avatarTerlapor,
          width: 25,
          height: 25,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _defaultAvatar(),
        ),
      );
    }
    return _defaultAvatar();
  }

  Widget _defaultAvatar() {
    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFFFD18B),
        shape: BoxShape.circle,
      ),
      child: const Text('☁',
          style: TextStyle(
              fontSize: 15,
              color: Color(0xFF2B2B2B),
              fontWeight: FontWeight.w700)),
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