import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/admin/ajuan_banding_model.dart';
import '../../services/admin/ajuan_banding_service.dart';
import 'tinjau_ajuan_banding_user_admin_page.dart';

class ListAjuanBandingAdminPage extends StatefulWidget {
  const ListAjuanBandingAdminPage({super.key});

  @override
  State<ListAjuanBandingAdminPage> createState() =>
      _ListAjuanBandingAdminPageState();
}

class _ListAjuanBandingAdminPageState extends State<ListAjuanBandingAdminPage> {
  final AjuanBandingService _ajuanBandingService = AjuanBandingService();
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  int _jumlahNotif = 0;

  List<AjuanBandingModel> _ajuanBandingList = [];
  String _selectedTab = 'Semua';
  String _selectedTanggal = 'Tanggal';

  final List<String> _tabs = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
  final List<String> _tanggalOptions = ['Tanggal', 'Terbaru', 'Terlama'];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadAjuanBanding();
    _loadJumlahNotif();
  }

  void _onScroll() {
    if (mounted) setState(() {});
  }

  Future<void> _loadAjuanBanding() async {
    final data = await _ajuanBandingService.getAjuanBanding();
    if (!mounted) return;

    setState(() {
      _ajuanBandingList = data;
    });
  }

  Future<void> _loadJumlahNotif() async {
    final bandingPending = await FirebaseFirestore.instance
        .collection('ajuan_banding')
        .where('status', isEqualTo: 'pending')
        .get();

    if (!mounted) return;

    setState(() {
      _jumlahNotif = bandingPending.docs.length;
    });
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
              icon: Icons.gavel_rounded,
              title: 'Ajuan Banding',
              subtitle: '$_jumlahNotif banding menunggu keputusan',
              color: const Color(0xFF8ECD86),
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
  List<AjuanBandingModel> get _filteredAjuan {
    final keyword = _searchController.text.toLowerCase();

    final result = _ajuanBandingList.where((ajuan) {
      final matchSearch = ajuan.id.toLowerCase().contains(keyword) ||
          ajuan.username.toLowerCase().contains(keyword) ||
          ajuan.jenisBan.toLowerCase().contains(keyword) ||
          ajuan.alasanBanding.toLowerCase().contains(keyword);

      final matchTab = _selectedTab == 'Semua' ||
          ajuan.status.label.toLowerCase() == _selectedTab.toLowerCase();

      return matchSearch && matchTab;
    }).toList();

    if (_selectedTanggal == 'Terbaru' || _selectedTanggal == 'Tanggal') {
      result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    } else {
      result.sort((a, b) => a.tanggal.compareTo(b.tanggal));
    }

    return result;
  }

  int _countByStatus(AjuanBandingStatus status) {
    return _ajuanBandingList.where((ajuan) => ajuan.status == status).length;
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

  Color _statusBackgroundColor(AjuanBandingStatus status) {
    switch (status) {
      case AjuanBandingStatus.pending:
        return const Color(0xFFF2F4D9);
      case AjuanBandingStatus.disetujui:
        return const Color(0xFFAEDB9A);
      case AjuanBandingStatus.ditolak:
        return const Color(0xFFFFB9B9);
    }
  }

  Color _statusTextColor(AjuanBandingStatus status) {
    switch (status) {
      case AjuanBandingStatus.pending:
        return const Color(0xFF9A5606);
      case AjuanBandingStatus.disetujui:
        return const Color(0xFF20560A);
      case AjuanBandingStatus.ditolak:
        return const Color(0xFFFF0000);
    }
  }

  Color _avatarColor(String id) {
    if (id == 'BD-0021') return const Color(0xFF86F2B6);
    if (id == 'BD-0020') return const Color(0xFFFF9EA2);
    return const Color(0xFFB7F1FF);
  }

  String _avatarEmoji(String id) {
    if (id == 'BD-0021') return '✧';
    if (id == 'BD-0020') return '⌯';
    return '☁';
  }

  double _customScrollbarTop(double viewportHeight) {
    const double startTop = 300;
    const double bottomSpace = 95;
    const double thumbHeight = 45;

    final double trackHeight = viewportHeight - startTop - bottomSpace;

    if (!_scrollController.hasClients ||
        _scrollController.position.maxScrollExtent <= 0 ||
        trackHeight <= thumbHeight) {
      return startTop;
    }

    final double scrollFraction =
    (_scrollController.offset / _scrollController.position.maxScrollExtent)
        .clamp(0.0, 1.0);

    return startTop + (trackHeight - thumbHeight) * scrollFraction;
  }

  Future<void> _goToTinjauAjuan(AjuanBandingModel ajuan) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TinjauAjuanBandingUserAdminPage(
          ajuan: ajuan,
        ),
      ),
    );

    if (result == true) {
      _loadAjuanBanding();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAjuan = _filteredAjuan;

    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(31, 28, 20, 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTopBar(),
                      const SizedBox(height: 24),
                      _buildTitleSection(),
                      const SizedBox(height: 14),
                      _buildSearchBar(),
                      const SizedBox(height: 12),
                      _buildFilterRow(),
                      const SizedBox(height: 18),
                      _buildTabs(),
                      const SizedBox(height: 18),
                      if (filteredAjuan.isEmpty)
                        _buildEmptyState()
                      else
                        ...filteredAjuan.map(_buildAjuanCard),
                    ],
                  ),
                ),
                Positioned(
                  right: 4,
                  top: _customScrollbarTop(constraints.maxHeight),
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
                    _jumlahNotif.toString(),
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
          'List Ajuan Banding',
          style: GoogleFonts.fredoka(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 22 / 24,
            color: const Color(0xFF486253),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'Tinjau permohonan banding dari pengguna',
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
          height: 22 / 14,
          color: const Color(0xFF0C0E0C),
        ),
        decoration: InputDecoration(
          hintText: 'Cari ID, atau username...',
          hintStyle: GoogleFonts.openSans(
            fontSize: 14,
            height: 22 / 14,
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
          items: const ['Status', 'Pending', 'Disetujui', 'Ditolak'],
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
        const SizedBox(width: 12),
        _buildSmallDropdown(
          value: _selectedTanggal,
          items: _tanggalOptions,
          width: 92,
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
                  ? _countByStatus(AjuanBandingStatus.pending)
                  : tab == 'Disetujui'
                  ? _countByStatus(AjuanBandingStatus.disetujui)
                  : tab == 'Ditolak'
                  ? _countByStatus(AjuanBandingStatus.ditolak)
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
                                    : tab == 'Disetujui'
                                    ? const Color(0xFF9FDFB0)
                                    : const Color(0xFFFF9AB2),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$count',
                                style: GoogleFonts.openSans(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: tab == 'Pending'
                                      ? const Color(0xFF9A5606)
                                      : tab == 'Disetujui'
                                      ? const Color(0xFF37A75B)
                                      : const Color(0xFFFF0000),
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

  Widget _buildAjuanCard(AjuanBandingModel ajuan) {
    return GestureDetector(
      onTap: () => _goToTinjauAjuan(ajuan),
      child: Container(
        width: 326,
        constraints: const BoxConstraints(
          minHeight: 156,
        ),
        margin: const EdgeInsets.only(left: 20, right: 16, bottom: 14),
        padding: const EdgeInsets.fromLTRB(17, 13, 16, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCardTop(ajuan),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(ajuan),
                const SizedBox(width: 14),
                Expanded(
                  child: _buildAjuanInfo(ajuan),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(top: 28),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    size: 36,
                    color: Color(0xFFCFCFCF),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardTop(AjuanBandingModel ajuan) {
    return Row(
      children: [
        SizedBox(
          width: 73,
          height: 24,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '#${ajuan.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.fredoka(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                height: 22 / 12,
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
            color: _statusBackgroundColor(ajuan.status),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            ajuan.status.label,
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 10,
              height: 1,
              color: _statusTextColor(ajuan.status),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar(AjuanBandingModel ajuan) {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _avatarColor(ajuan.id),
        shape: BoxShape.circle,
      ),
      child: Text(
        _avatarEmoji(ajuan.id),
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Color(0xFF0C0E0C),
        ),
      ),
    );
  }

  Widget _buildAjuanInfo(AjuanBandingModel ajuan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ajuan.username,
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 22 / 13,
            color: const Color(0xFF0C0E0C),
          ),
        ),
        const SizedBox(height: 4),
        _buildBanBadge(ajuan.jenisBan),
        const SizedBox(height: 6),
        Text(
          '“${ajuan.alasanBanding}”',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.openSans(
            fontSize: 11,
            height: 20 / 11,
            color: const Color(0xFF0C0E0C),
          ),
        ),
        const SizedBox(height: 3),
        SizedBox(
          width: 70,
          height: 18,
          child: Text(
            _formatTanggal(ajuan.tanggal),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.openSans(
              fontSize: 8,
              height: 18 / 8,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBanBadge(String jenisBan) {
    final bool isSementara = jenisBan.toLowerCase().contains('sementara');

    return Container(
      width: 89,
      height: 19,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color:
        isSementara ? const Color(0xFFAEDB9A) : const Color(0xFFFFB9B9),
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
      child: Text(
        jenisBan,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: GoogleFonts.openSans(
          fontSize: 10,
          height: 22 / 10,
          color: const Color(0xFF000000),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(left: 20, right: 16),
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
            'Tidak ada ajuan banding',
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