import 'profil_admin_page.dart';
import '../../widgets/admin_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/admin/ajuan_banding_model.dart';
import '../../services/admin/ajuan_banding_service.dart';
import 'tinjau_ajuan_banding_user_admin_page.dart';
import '../afirmasi/widgets/cute_top_popup.dart';

class ListAjuanBandingAdminPage extends StatefulWidget {
  const ListAjuanBandingAdminPage({super.key});

  @override
  State<ListAjuanBandingAdminPage> createState() =>
      _ListAjuanBandingAdminPageState();
}

class _ListAjuanBandingAdminPageState extends State<ListAjuanBandingAdminPage> {
  final AjuanBandingService _ajuanBandingService = AjuanBandingService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  int _jumlahNotif = 0;

  List<AjuanBandingModel> _ajuanBandingList = [];

  String _selectedTab = 'Semua';
  String _selectedTanggal = 'Terbaru';
  String _selectedTindakan = 'Semua tindakan';

  final List<String> _tabs = ['Semua', 'Pending', 'Disetujui', 'Ditolak'];
  final List<String> _tanggalOptions = [
    'Terbaru',
    'Terlama',
    'Nama A-Z',
  ];
  final List<String> _tindakanOptions = [
    'Semua tindakan',
    'Batasi User',
    'Ban Sementara',
    'Ban Permanen',
    'Cabut Tindakan',
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
    _loadAjuanBanding();
    _searchController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadAjuanBanding() async {
    setState(() => _isLoading = true);

    try {
      final data = await _ajuanBandingService.getAjuanBanding();

      if (!mounted) return;

      setState(() {
        _ajuanBandingList = data;
        _jumlahNotif = data
            .where((ajuan) => ajuan.status == AjuanBandingStatus.pending)
            .length;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showCuteTopPopup(
        context,
        title: 'Gagal memuat',
        message: 'Ajuan banding belum berhasil diambil.',
        type: CutePopupType.error,
      );
    }
  }

  void _showNotifPopup() {
    showCuteTopPopup(
      context,
      title: 'Ajuan Banding',
      message: _jumlahNotif == 0
          ? 'Tidak ada banding baru yang menunggu keputusan.'
          : 'Ada $_jumlahNotif banding yang masih menunggu keputusan admin.',
      type: _jumlahNotif > 0 ? CutePopupType.warning : CutePopupType.info,
    );
  }

  List<AjuanBandingModel> get _filteredAjuan {
    final keyword = _searchController.text.trim().toLowerCase();

    final result = _ajuanBandingList.where((ajuan) {
      final matchSearch =
          ajuan.id.toLowerCase().contains(keyword) ||
              ajuan.username.toLowerCase().contains(keyword) ||
              ajuan.userId.toLowerCase().contains(keyword) ||
              ajuan.jenisBan.toLowerCase().contains(keyword) ||
              ajuan.alasanBanding.toLowerCase().contains(keyword) ||
              ajuan.alasanTindakan.toLowerCase().contains(keyword) ||
              ajuan.isiPesan.toLowerCase().contains(keyword);

      final matchTab = _selectedTab == 'Semua'
          ? true
          : ajuan.status.label.toLowerCase() == _selectedTab.toLowerCase();

      final matchTindakan = _selectedTindakan == 'Semua tindakan'
          ? true
          : ajuan.jenisBan.toLowerCase() == _selectedTindakan.toLowerCase();

      return matchSearch && matchTab && matchTindakan;
    }).toList();

    switch (_selectedTanggal) {
      case 'Terlama':
        result.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case 'Nama A-Z':
        result.sort((a, b) => a.username.toLowerCase().compareTo(
              b.username.toLowerCase(),
            ));
        break;
      case 'Terbaru':
      default:
        result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
    }

    return result;
  }

  int _countByStatus(AjuanBandingStatus status) {
    return _ajuanBandingList.where((ajuan) => ajuan.status == status).length;
  }

  String _formatTanggal(DateTime date) {
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

    return '${date.day} ${bulan[date.month]} ${date.year}';
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

  Map<String, dynamic> _statusStyle(AjuanBandingStatus status) {
    switch (status) {
      case AjuanBandingStatus.pending:
        return {
          'bg': _yellowSoft,
          'text': const Color(0xFFB07A10),
          'icon': Icons.schedule_rounded,
        };
      case AjuanBandingStatus.disetujui:
        return {
          'bg': _greenSoft,
          'text': _greenDark,
          'icon': Icons.check_circle_rounded,
        };
      case AjuanBandingStatus.ditolak:
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.close_rounded,
        };
    }
  }

  Map<String, dynamic> _actionStyle(String tindakan) {
    final value = tindakan.toLowerCase();

    if (value.contains('sementara')) {
      return {
        'bg': _peachSoft,
        'text': const Color(0xFFD6984E),
        'icon': Icons.timer_off_rounded,
      };
    }

    if (value.contains('permanen')) {
      return {
        'bg': _pinkSoft,
        'text': const Color(0xFFD95067),
        'icon': Icons.gpp_bad_rounded,
      };
    }

    if (value.contains('cabut')) {
      return {
        'bg': _blueSoft,
        'text': const Color(0xFF4E92C2),
        'icon': Icons.restart_alt_rounded,
      };
    }

    return {
      'bg': _greenMint,
      'text': _greenDark,
      'icon': Icons.shield_outlined,
    };
  }

  String _initialOf(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }

  Widget _buildAvatar(AjuanBandingModel ajuan) {
    if (ajuan.avatarUrl.trim().isNotEmpty &&
        ajuan.avatarUrl.startsWith('http')) {
      return ClipOval(
        child: Image.network(
          ajuan.avatarUrl,
          width: 54,
          height: 54,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackAvatar(ajuan.username),
        ),
      );
    }

    return _buildFallbackAvatar(ajuan.username);
  }

  Widget _buildFallbackAvatar(String username) {
    return Container(
      width: 54,
      height: 54,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFDDF4FF),
        shape: BoxShape.circle,
      ),
      child: Text(
        _initialOf(username),
        style: GoogleFonts.fredoka(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: Color(0xFF4E92C2),
        ),
      ),
    );
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
      await _loadAjuanBanding();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAjuan = _filteredAjuan;

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
              onRefresh: _loadAjuanBanding,
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
                          else if (filteredAjuan.isEmpty)
                            _buildEmptyState()
                          else
                            ...filteredAjuan.map(_buildAjuanCard),
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
                        'Ruang Banding',
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: _greenDark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'List Ajuan Banding',
                      style: GoogleFonts.fredoka(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        height: 1.05,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tinjau permohonan banding pengguna dengan lebih rapi, cepat, dan tetap terasa seperti Moodly, bukan panel sidang yang kehilangan jiwa.',
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
                          icon: Icons.schedule_rounded,
                          text: '${_countByStatus(AjuanBandingStatus.pending)} pending',
                          bg: _yellowSoft,
                          iconColor: const Color(0xFFB07A10),
                        ),
                        _buildHeroChip(
                          icon: Icons.check_circle_rounded,
                          text:
                              '${_countByStatus(AjuanBandingStatus.disetujui)} disetujui',
                          bg: _greenMint,
                          iconColor: _greenDark,
                        ),
                        _buildHeroChip(
                          icon: Icons.close_rounded,
                          text:
                              '${_countByStatus(AjuanBandingStatus.ditolak)} ditolak',
                          bg: _pinkSoft,
                          iconColor: const Color(0xFFD95067),
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
                  Icons.balance_rounded,
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
          hintText: 'Cari ID, username, alasan banding...',
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
            value: _selectedTindakan,
            items: _tindakanOptions,
            onChanged: (value) {
              setState(() => _selectedTindakan = value!);
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
    return Column(
      children: [
        Row(
          children: _tabs.map((tab) {
            final isSelected = _selectedTab == tab;

            final count = tab == 'Pending'
                ? _countByStatus(AjuanBandingStatus.pending)
                : tab == 'Disetujui'
                    ? _countByStatus(AjuanBandingStatus.disetujui)
                    : tab == 'Ditolak'
                        ? _countByStatus(AjuanBandingStatus.ditolak)
                        : _ajuanBandingList.length;

            Color chipColor;
            Color chipTextColor;

            if (tab == 'Pending') {
              chipColor = _yellowSoft;
              chipTextColor = const Color(0xFFB07A10);
            } else if (tab == 'Disetujui') {
              chipColor = _greenSoft;
              chipTextColor = _greenDark;
            } else if (tab == 'Ditolak') {
              chipColor = _pinkSoft;
              chipTextColor = const Color(0xFFD95067);
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
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
        ),
      ],
    );
  }

  Widget _buildAjuanCard(AjuanBandingModel ajuan) {
    final statusStyle = _statusStyle(ajuan.status);
    final actionStyle = _actionStyle(ajuan.jenisBan);

    return GestureDetector(
      onTap: () => _goToTinjauAjuan(ajuan),
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
                      '#${ajuan.id}',
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
                          ajuan.status.label,
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
                  _buildAvatar(ajuan),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ajuan.username,
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
                          'UID: ${ajuan.userId.isEmpty ? '-' : ajuan.userId}',
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
                  const SizedBox(width: 10),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Color(0xFFC5CBC0),
                    size: 30,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: actionStyle['bg'] as Color,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          actionStyle['icon'] as IconData,
                          size: 14,
                          color: actionStyle['text'] as Color,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          ajuan.jenisBan,
                          style: GoogleFonts.openSans(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: actionStyle['text'] as Color,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                          _formatTanggalJam(ajuan.tanggal),
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
                      'Alasan banding',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD95067),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '“${ajuan.alasanBanding.trim().isEmpty ? '-' : ajuan.alasanBanding}”',
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
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _greenMint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Konteks pelanggaran',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: _greenDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      ajuan.isiPesan.trim().isNotEmpty
                          ? '“${ajuan.isiPesan}”'
                          : ajuan.alasanTindakan,
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
              if (ajuan.tanggalGabung != null)
                Text(
                  'Bergabung sejak ${_formatTanggal(ajuan.tanggalGabung!)}',
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
            'Tidak ada ajuan banding',
            style: GoogleFonts.fredoka(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Untuk saat ini belum ada permohonan banding yang perlu diperiksa. Langka juga ya, manusia kadang malah senang banding.',
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