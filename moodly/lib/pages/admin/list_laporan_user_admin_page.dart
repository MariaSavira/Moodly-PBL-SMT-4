import 'package:flutter/material.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'profil_admin_page.dart';
import 'package:google_fonts/google_fonts.dart';
import 'tinjau_laporan_user_admin_page.dart';
import '../../models/admin/laporan_user_model.dart';
import '../../services/admin/laporan_user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../afirmasi/widgets/cute_top_popup.dart';

class ListLaporanUserAdminPage extends StatefulWidget {
  const ListLaporanUserAdminPage({super.key});

  @override
  State<ListLaporanUserAdminPage> createState() =>
      _ListLaporanUserAdminPageState();
}

class _ListLaporanUserAdminPageState extends State<ListLaporanUserAdminPage> {
  final LaporanUserService _laporanService = LaporanUserService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  int _jumlahNotif = 0;

  List<LaporanUserModel> _laporanList = [];

  String _selectedTab = 'Semua';
  String _selectedTipe = 'Semua tipe';
  String _selectedTanggal = 'Terbaru';

  final List<String> _tabs = ['Semua', 'Pending', 'Diproses', 'Selesai'];
  final List<String> _tipeOptions = [
    'Semua tipe',
    'Chat Anonim',
    'Diary Online',
    'Comment',
  ];
  final List<String> _tanggalOptions = [
    'Terbaru',
    'Terlama',
    'Pelanggaran terbanyak',
    'Nama A-Z',
  ];

  static const Color _bg = Color(0xFFF6F9EE);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF4E7D45);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEEF7E6);
  static const Color _pink = Color(0xFFF4BBC8);
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
    _loadLaporan();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadLaporan() async {
    setState(() => _isLoading = true);

    try {
      final data = await _laporanService.getLaporanUser();

      if (!mounted) return;

      setState(() {
        _laporanList = data;
        _jumlahNotif = data.where((e) => e.status == LaporanStatus.pending).length;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showCuteTopPopup(
        context,
        title: 'Gagal memuat',
        message: 'Laporan user belum berhasil diambil.',
        type: CutePopupType.error,
      );
    }
  }

  void _showNotifPopup() {
    showCuteTopPopup(
      context,
      title: 'Laporan User',
      message: _jumlahNotif == 0
          ? 'Tidak ada laporan baru yang menunggu tinjauan.'
          : 'Ada $_jumlahNotif laporan baru yang masih menunggu admin.',
      type: _jumlahNotif > 0 ? CutePopupType.warning : CutePopupType.info,
    );
  }

  List<_UserViolationSummary> get _userSummaries {
    final Map<String, List<LaporanUserModel>> grouped = {};

    for (final laporan in _laporanList) {
      final uid = laporan.reportedUid.trim();
      final name = laporan.namaTerlapor.trim().toLowerCase();
      final key = uid.isNotEmpty ? uid : (name.isNotEmpty ? name : laporan.id);
      grouped.putIfAbsent(key, () => []).add(laporan);
    }

    return grouped.entries.map((entry) {
      final reports = [...entry.value]
        ..sort((a, b) => b.tanggal.compareTo(a.tanggal));
      final latest = reports.first;

      return _UserViolationSummary(
        groupKey: entry.key,
        displayName:
            latest.namaTerlapor.trim().isEmpty ? 'User tidak diketahui' : latest.namaTerlapor,
        avatarUrl: latest.avatarTerlapor,
        latestReport: latest,
        latestType: latest.tipeKonten,
        latestCategory: latest.kategoriLaporan,
        latestDate: latest.tanggal,
        totalViolations: reports.length,
        reports: reports,
      );
    }).toList();
  }

  List<_UserViolationSummary> get _filteredSummaries {
    final keyword = _searchController.text.trim().toLowerCase();

    final result = _userSummaries.where((summary) {
      final latest = summary.latestReport;

      final matchSearch =
          summary.displayName.toLowerCase().contains(keyword) ||
              summary.groupKey.toLowerCase().contains(keyword) ||
              summary.latestType.toLowerCase().contains(keyword) ||
              summary.latestCategory.toLowerCase().contains(keyword) ||
              latest.isiLaporan.toLowerCase().contains(keyword) ||
              latest.namaPelapor.toLowerCase().contains(keyword);

      final matchTab = _selectedTab == 'Semua'
          ? true
          : _statusLabel(latest.status).toLowerCase() == _selectedTab.toLowerCase();

      final matchTipe = _selectedTipe == 'Semua tipe'
          ? true
          : summary.latestType == _selectedTipe;

      return matchSearch && matchTab && matchTipe;
    }).toList();

    switch (_selectedTanggal) {
      case 'Terlama':
        result.sort((a, b) => a.latestDate.compareTo(b.latestDate));
        break;
      case 'Pelanggaran terbanyak':
        result.sort((a, b) {
          final byCount = b.totalViolations.compareTo(a.totalViolations);
          if (byCount != 0) return byCount;
          return b.latestDate.compareTo(a.latestDate);
        });
        break;
      case 'Nama A-Z':
        result.sort((a, b) =>
            a.displayName.toLowerCase().compareTo(b.displayName.toLowerCase()));
        break;
      case 'Terbaru':
      default:
        result.sort((a, b) => b.latestDate.compareTo(a.latestDate));
        break;
    }

    return result;
  }

  int _countByStatus(LaporanStatus status) {
    return _userSummaries.where((summary) => summary.latestReport.status == status).length;
  }

  String _statusLabel(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return 'Pending';
      case LaporanStatus.diproses:
        return 'Diproses';
      case LaporanStatus.selesai:
        return 'Selesai';
      case LaporanStatus.ditolak:
        return 'Ditolak';
    }
  }

  Map<String, dynamic> _statusStyle(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return {
          'bg': _yellowSoft,
          'text': const Color(0xFFB07A10),
          'icon': Icons.schedule_rounded,
        };
      case LaporanStatus.diproses:
        return {
          'bg': _greenSoft,
          'text': _greenDark,
          'icon': Icons.hourglass_top_rounded,
        };
      case LaporanStatus.selesai:
        return {
          'bg': const Color(0xFFDDF4E1),
          'text': const Color(0xFF43804D),
          'icon': Icons.check_circle_rounded,
        };
      case LaporanStatus.ditolak:
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.close_rounded,
        };
    }
  }

  Map<String, dynamic> _typeStyle(String tipeKonten) {
    final lower = tipeKonten.toLowerCase();

    if (lower.contains('chat')) {
      return {
        'bg': _pinkSoft,
        'accent': const Color(0xFFE78BA0),
        'icon': Icons.forum_rounded,
        'label': 'Chat Anonim',
      };
    }

    if (lower.contains('comment')) {
      return {
        'bg': _blueSoft,
        'accent': const Color(0xFF68A8C8),
        'icon': Icons.mode_comment_rounded,
        'label': 'Comment',
      };
    }

    return {
      'bg': _peachSoft,
      'accent': const Color(0xFFD6984E),
      'icon': Icons.book_rounded,
      'label': 'Diary Online',
    };
  }

  String _formatTanggalJam(DateTime date) {
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

    final hh = date.hour.toString().padLeft(2, '0');
    final mm = date.minute.toString().padLeft(2, '0');
    return '$hh:$mm • ${date.day} ${bulan[date.month]} ${date.year}';
  }

  String _initialOf(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }

  Widget _buildAvatar(String avatarUrl, String name, Color accent) {
    if (avatarUrl.trim().isNotEmpty && avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          avatarUrl,
          width: 56,
          height: 56,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(name, accent),
        ),
      );
    }

    return _buildFallbackAvatar(name, accent);
  }

  Widget _buildFallbackAvatar(String name, Color accent) {
    return Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: accent.withOpacity(0.16),
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

  Future<void> _openLatestReport(_UserViolationSummary summary) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TinjauLaporanUserAdminPage(
          laporan: summary.latestReport,
        ),
      ),
    );

    if (result == true) {
      await _loadLaporan();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredSummaries = _filteredSummaries;

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
            top: 180,
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
            child: RefreshIndicator(
              color: _green,
              onRefresh: _loadLaporan,
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
                          _buildFilterRow(),
                          const SizedBox(height: 16),
                          _buildTabs(),
                          const SizedBox(height: 16),
                          if (_isLoading)
                            const Center(
                              child: Padding(
                                padding: EdgeInsets.only(top: 56),
                                child: CircularProgressIndicator(),
                              ),
                            )
                          else if (filteredSummaries.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredSummaries.map(_buildSummaryCard),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: AdminBottomNavbar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/admin-dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/admin-moderasi');
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
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
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
                        'Ringkasan Pelanggaran User',
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'List Laporan User',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sekarang list ini diringkas per user supaya admin lebih cepat membaca pola pelanggaran. Manusia memang suka mengulang kesalahan, jadi kita bantu tampilkan rangkumannya.',
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                        color: _textSoft,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _buildHeroChip(
                          icon: Icons.groups_rounded,
                          text: '${_userSummaries.length} user terlapor',
                          bg: _greenMint,
                          iconColor: _greenDark,
                        ),
                        _buildHeroChip(
                          icon: Icons.schedule_rounded,
                          text: '${_countByStatus(LaporanStatus.pending)} pending',
                          bg: _yellowSoft,
                          iconColor: const Color(0xFFB07A10),
                        ),
                        _buildHeroChip(
                          icon: Icons.gpp_good_rounded,
                          text: '${_laporanList.length} total laporan',
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
          hintText: 'Cari user, kategori, pelapor, atau kata kunci...',
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    return Row(
      children: [
        Expanded(
          child: _buildDropdown(
            value: _selectedTipe,
            items: _tipeOptions,
            onChanged: (value) {
              setState(() => _selectedTipe = value!);
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
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
            ? _countByStatus(LaporanStatus.pending)
            : tab == 'Diproses'
                ? _countByStatus(LaporanStatus.diproses)
                : tab == 'Selesai'
                    ? _countByStatus(LaporanStatus.selesai)
                    : _userSummaries.length;

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
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

  Widget _buildSummaryCard(_UserViolationSummary summary) {
    final latest = summary.latestReport;
    final statusStyle = _statusStyle(latest.status);
    final typeStyle = _typeStyle(summary.latestType);

    return GestureDetector(
      onTap: () => _openLatestReport(summary),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: _greenMint,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      summary.groupKey.length > 16
                          ? '#USR-${summary.groupKey.substring(0, 8).toUpperCase()}'
                          : '#USR-${summary.groupKey.toUpperCase()}',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _greenDark,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                          _statusLabel(latest.status),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAvatar(
                    summary.avatarUrl,
                    summary.displayName,
                    typeStyle['accent'] as Color,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          summary.displayName,
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
                          'Total pelanggaran: ${summary.totalViolations}',
                          style: GoogleFonts.openSans(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: _textSoft,
                          ),
                        ),
                        const SizedBox(height: 8),
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
                                    _formatTanggalJam(summary.latestDate),
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
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _pinkSoft,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Kategori pelanggaran terbaru',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD95067),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      summary.latestCategory.trim().isEmpty
                          ? '-'
                          : summary.latestCategory,
                      style: GoogleFonts.openSans(
                        fontSize: 13,
                        height: 1.45,
                        fontWeight: FontWeight.w800,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: typeStyle['bg'] as Color,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cuplikan laporan terbaru',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: typeStyle['accent'] as Color,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      latest.isiLaporan.trim().isEmpty
                          ? '-'
                          : '“${latest.isiLaporan}”',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.openSans(
                        fontSize: 12,
                        height: 1.45,
                        fontWeight: FontWeight.w700,
                        color: _textDark,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Pelapor terbaru: ${latest.namaPelapor}',
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
                ),
              ),
            ],
          ),
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
            'Tidak ada laporan',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Belum ada ringkasan user yang perlu ditinjau. Admin boleh tarik napas sebentar, keajaiban langka.',
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

class _UserViolationSummary {
  final String groupKey;
  final String displayName;
  final String avatarUrl;
  final LaporanUserModel latestReport;
  final String latestType;
  final String latestCategory;
  final DateTime latestDate;
  final int totalViolations;
  final List<LaporanUserModel> reports;

  const _UserViolationSummary({
    required this.groupKey,
    required this.displayName,
    required this.avatarUrl,
    required this.latestReport,
    required this.latestType,
    required this.latestCategory,
    required this.latestDate,
    required this.totalViolations,
    required this.reports,
  });
}