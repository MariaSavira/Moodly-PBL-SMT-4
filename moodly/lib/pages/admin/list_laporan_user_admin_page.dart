import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin/laporan_user_model.dart';
import '../../services/admin/laporan_user_service.dart';

class ListLaporanUserAdminPage extends StatefulWidget {
  const ListLaporanUserAdminPage({super.key});

  @override
  State<ListLaporanUserAdminPage> createState() =>
      _ListLaporanUserAdminPageState();
}

class _ListLaporanUserAdminPageState extends State<ListLaporanUserAdminPage> {
  final LaporanUserService _laporanService = LaporanUserService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<LaporanUserModel> _laporanList = [];
  String _selectedTab = 'Semua';
  String _selectedTipe = 'Semua tipe';
  String _selectedTanggal = 'Tanggal';

  final List<String> _tabs = ['Semua', 'Pending', 'Diproses', 'Selesai'];
  final List<String> _tipeOptions = [
    'Semua tipe',
    'Chat Anonim',
    'Diary Online',
  ];
  final List<String> _tanggalOptions = ['Tanggal', 'Terbaru', 'Terlama'];

  @override
  void initState() {
    super.initState();
    _loadLaporan();
  }

  Future<void> _loadLaporan() async {
    final data = await _laporanService.getLaporanUser();

    if (!mounted) return;

    setState(() {
      _laporanList = data;
    });
  }

  List<LaporanUserModel> get _filteredLaporan {
    final keyword = _searchController.text.toLowerCase();

    final result = _laporanList.where((laporan) {
      final matchSearch = laporan.id.toLowerCase().contains(keyword) ||
          laporan.tipeKonten.toLowerCase().contains(keyword) ||
          laporan.namaTerlapor.toLowerCase().contains(keyword) ||
          laporan.isiLaporan.toLowerCase().contains(keyword);

      final matchTab = _selectedTab == 'Semua' ||
          laporan.status.label.toLowerCase() == _selectedTab.toLowerCase();

      final matchTipe =
          _selectedTipe == 'Semua tipe' || laporan.tipeKonten == _selectedTipe;

      return matchSearch && matchTab && matchTipe;
    }).toList();

    if (_selectedTanggal == 'Terbaru' || _selectedTanggal == 'Tanggal') {
      result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      result.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    }

    return result;
  }

  int _countByStatus(LaporanStatus status) {
    return _laporanList.where((laporan) => laporan.status == status).length;
  }

  String _formatTanggal(DateTime date) {
    final bulan = [
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

    return '${date.day.toString().padLeft(2, '0')} ${bulan[date.month]} ${date.year}';
  }

  String _badgeLabel(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return 'Pending';
      case LaporanStatus.diproses:
        return 'Diproses';
      case LaporanStatus.selesai:
        return 'Selesai';
    }
  }

  Color _badgeColor(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return const Color(0xFFF2F4D9);
      case LaporanStatus.diproses:
        return const Color(0xFFDDF1D2);
      case LaporanStatus.selesai:
        return const Color(0xFFAEDB9A);
    }
  }

  Color _badgeTextColor(LaporanStatus status) {
    switch (status) {
      case LaporanStatus.pending:
        return const Color(0xFFD2AB49);
      case LaporanStatus.diproses:
        return const Color(0xFF49A828);
      case LaporanStatus.selesai:
        return const Color(0xFF49A828);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredLaporan = _filteredLaporan;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: RawScrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8,
          radius: const Radius.circular(16),
          thumbColor: const Color(0xFFD9D9D9),
          minThumbLength: 105,
          child: SingleChildScrollView(
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
                if (filteredLaporan.isEmpty)
                  _buildEmptyState()
                else
                  ...filteredLaporan.map(_buildReportCard),
              ],
            ),
          ),
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
            letterSpacing: 0,
            color: const Color(0xFFFFB6CC),
          ),
        ),
        const Spacer(),
        Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(
              Icons.notifications_rounded,
              size: 24,
              color: Color(0xFF8B8B8B),
            ),
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
                  '1',
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
        const SizedBox(width: 14),
        Container(
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
        const SizedBox(width: 7),
        Text(
          'Admin',
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            letterSpacing: 0,
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
          'List Laporan User',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            letterSpacing: 0,
            color: const Color(0xFF486253),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Kelola laporan konten dari pengguna',
          style: GoogleFonts.openSans(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 22 / 14,
            letterSpacing: 0,
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
            letterSpacing: 0,
            color: const Color(0xFF8F8F8F),
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: Color(0xFF0C0E0C),
            size: 22,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 0,
            vertical: 7,
          ),
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
          value: 'Status',
          items: const ['Status', 'Pending', 'Diproses', 'Selesai'],
          width: 92,
          onChanged: (value) {
            setState(() {
              if (value == 'Status') {
                _selectedTab = 'Semua';
              } else {
                _selectedTab = value!;
              }
            });
          },
        ),
        const SizedBox(width: 10),
        _buildSmallDropdown(
          value: _selectedTipe,
          items: _tipeOptions,
          width: 112,
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
            letterSpacing: 0,
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
                  ? _countByStatus(LaporanStatus.pending)
                  : tab == 'Diproses'
                      ? _countByStatus(LaporanStatus.diproses)
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
                              fontWeight:
                                  isSelected ? FontWeight.w600 : FontWeight.w400,
                              height: 22 / 12,
                              letterSpacing: 0,
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
        Container(
          height: 1,
          width: double.infinity,
          color: const Color(0xFFD9E3C8),
        ),
      ],
    );
  }

  Widget _buildReportCard(LaporanUserModel laporan) {
    final isChat = laporan.tipeKonten == 'Chat Anonim';

    return Container(
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
          _buildCardTop(laporan),
          const SizedBox(height: 8),
          _buildTypeBadge(
            label: laporan.tipeKonten,
            icon: isChat ? Icons.forum_rounded : Icons.menu_book_rounded,
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              _buildUserIcon(laporan.id),
              const SizedBox(width: 7),
              Text(
                laporan.namaTerlapor,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 22 / 12,
                  letterSpacing: 0,
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
                    _formatTanggal(laporan.tanggal),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 8,
                      fontWeight: FontWeight.w400,
                      height: 22 / 8,
                      letterSpacing: 0,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          Text(
            '“${laporan.isiLaporan}”',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              height: 22 / 12,
              letterSpacing: 0,
              color: const Color(0xFF0C0E0C),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTop(LaporanUserModel laporan) {
    return Row(
      children: [
        SizedBox(
          width: 73,
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '#${laporan.id}',
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 22 / 12,
                letterSpacing: 0,
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
            color: _badgeColor(laporan.status),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            _badgeLabel(laporan.status),
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 10,
              fontWeight: FontWeight.w400,
              height: 1,
              letterSpacing: 0,
              color: _badgeTextColor(laporan.status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeBadge({
  required String label,
  required IconData icon,
}) {
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
          spreadRadius: 0,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 22,
          color: const Color(0xFFFF8E99),
        ),
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
              letterSpacing: 0,
              color: const Color(0xFF000000),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildUserIcon(String id) {
    Color bgColor;
    String emoji;

    if (id == 'LP-0005') {
      bgColor = const Color(0xFF8BF4BC);
      emoji = '⌣';
    } else if (id == 'LP-0004') {
      bgColor = const Color(0xFFFF9EA2);
      emoji = '⌾';
    } else {
      bgColor = const Color(0xFFFFD18B);
      emoji = '☁';
    }

    return Container(
      width: 25,
      height: 25,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Text(
        emoji,
        style: const TextStyle(
          fontSize: 15,
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
          const Icon(
            Icons.inbox_outlined,
            size: 48,
            color: Color(0xFFA9E39A),
          ),
          const SizedBox(height: 10),
          Text(
            'Tidak ada laporan',
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