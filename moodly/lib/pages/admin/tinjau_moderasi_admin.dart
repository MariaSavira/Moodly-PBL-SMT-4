import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin/laporan_user_model.dart';
import '../../services/admin/laporan_user_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'moderasi_admin.dart';

class TinjauModerasiAdmin extends StatefulWidget {
  final ModerasiModel? moderasi;
  final LaporanUserModel? laporan;

  const TinjauModerasiAdmin({
    super.key,
    this.moderasi,
    this.laporan,
  }) : assert(moderasi != null || laporan != null);

  @override
  State<TinjauModerasiAdmin> createState() => _TinjauModerasiAdminState();
}

class _TinjauModerasiAdminState extends State<TinjauModerasiAdmin> {
  final TextEditingController _catatanController = TextEditingController();
  final LaporanUserService _laporanService = LaporanUserService();

  bool _isLoading = true;
  bool _isSaving = false;

  List<LaporanUserModel> _allUserReports = [];

  String _displayName = 'User';
  String _uid = '';
  String _avatar = '';
  String _email = '';
  DateTime? _joinedAt;

  bool _hasWarning = false;
  String _warningMessage = '';
  String? _chatNotice;
  DateTime? _banUntil;

  String _selectedType = 'Semua tipe';
  String _selectedStatus = 'Semua status';
  String _selectedSort = 'Terbaru';

  String? _selectedAction;
  Duration? _selectedDuration;
  String? _selectedDurationLabel;

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

  final List<String> _typeOptions = [
    'Semua tipe',
    'Chat Anonim',
    'Diary Online',
    'Comment',
  ];

  final List<String> _statusOptions = [
    'Semua status',
    'Pending',
    'Diproses',
    'Selesai',
    'Ditolak',
  ];

  final List<String> _sortOptions = [
    'Terbaru',
    'Terlama',
    'Kategori A-Z',
  ];

  final List<Map<String, dynamic>> _durationOptions = const [
    {'label': '1 Hari', 'duration': Duration(days: 1)},
    {'label': '3 Hari', 'duration': Duration(days: 3)},
    {'label': '7 Hari', 'duration': Duration(days: 7)},
    {'label': '30 Hari', 'duration': Duration(days: 30)},
  ];

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
    _catatanController.addListener(() {
      if (mounted) setState(() {});
    });
    _loadUserContext();
  }

  String get _sourceUid {
    if (widget.laporan != null) {
      return widget.laporan!.reportedUid.trim();
    }

    if (widget.moderasi != null) {
      final m = widget.moderasi!;
      if (m.reportedUid.trim().isNotEmpty) return m.reportedUid.trim();
    }

    return '';
  }

  String get _sourceName {
    if (widget.laporan != null) {
      final value = widget.laporan!.namaTerlapor.trim();
      return value.isEmpty ? 'User' : value;
    }

    if (widget.moderasi != null) {
      final value = widget.moderasi!.reportedUser.trim();
      return value.isEmpty ? 'User' : value;
    }

    return 'User';
  }

  String get _sourceAvatar {
    if (widget.laporan != null) {
      return widget.laporan!.avatarTerlapor.trim();
    }

    if (widget.moderasi != null) {
      return widget.moderasi!.reportedProfile.trim();
    }

    return '';
  }

  Future<void> _loadUserContext() async {
    setState(() => _isLoading = true);

    try {
      _displayName = _sourceName;
      _uid = _sourceUid;
      _avatar = _sourceAvatar;

      if (_uid.isNotEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          final data = userDoc.data()!;
          final fullName = (data['fullName'] ?? '').toString().trim();
          final nickname = (data['nickname'] ?? '').toString().trim();
          final email = (data['email'] ?? '').toString().trim();
          final photoUrl = (data['photoUrl'] ?? '').toString().trim();
          final avatarId = (data['avatarId'] ?? '').toString().trim();

          _displayName = fullName.isNotEmpty
              ? fullName
              : (nickname.isNotEmpty ? nickname : _displayName);
          _email = email;
          _avatar = photoUrl.isNotEmpty
              ? photoUrl
              : (avatarId.isNotEmpty ? avatarId : _avatar);

          _hasWarning = data['hasWarning'] as bool? ?? false;
          _warningMessage = (data['warningMessage'] ?? '').toString().trim();

          final chatNoticeRaw = data['chatNotice'];
          _chatNotice = chatNoticeRaw == null
              ? null
              : chatNoticeRaw.toString().trim().isEmpty
                  ? null
                  : chatNoticeRaw.toString().trim();

          final createdAt = data['createdAt'];
          if (createdAt is Timestamp) {
            _joinedAt = createdAt.toDate();
          } else if (createdAt is String) {
            _joinedAt = DateTime.tryParse(createdAt);
          }

          final banUntil = data['banUntil'];
          if (banUntil is Timestamp) {
            _banUntil = banUntil.toDate();
          } else if (banUntil is String) {
            _banUntil = DateTime.tryParse(banUntil);
          }
        }
      }

      final reports = await _laporanService.getLaporanUser();
      final filtered = reports.where((report) {
        if (_uid.isNotEmpty && report.reportedUid.trim().isNotEmpty) {
          return report.reportedUid.trim() == _uid;
        }

        return report.namaTerlapor.trim().toLowerCase() ==
            _displayName.trim().toLowerCase();
      }).toList();

      filtered.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      if (filtered.isEmpty) {
        final fallback = _buildFallbackReport();
        if (fallback != null) {
          filtered.add(fallback);
        }
      }

      if (!mounted) return;
      setState(() {
        _allUserReports = filtered;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      showCuteTopPopup(
        context,
        title: 'Gagal memuat',
        message: 'Data user dan riwayat pelanggaran belum berhasil diambil.',
        type: CutePopupType.error,
      );
    }
  }

  String _resolveFallbackType(String rawType) {
    final type = rawType.trim().toLowerCase();

    if (type.contains('chat') || type.contains('anonim')) {
      return 'Chat Anonim';
    }

    if (type.contains('comment') || type.contains('komentar')) {
      return 'Comment';
    }

    if (type.contains('reply')) {
      return 'Comment';
    }

    return 'Diary Online';
  }

  LaporanUserModel? _buildFallbackReport() {
    if (widget.laporan != null) {
      return widget.laporan!;
    }

    final m = widget.moderasi;
    if (m == null) return null;

    return LaporanUserModel(
      documentId: m.id,
      id: m.id,
      tipeKonten: _resolveFallbackType(m.type),
      namaPelapor: m.reportedByUsername,
      namaTerlapor: m.reportedUser,
      avatarTerlapor: m.reportedProfile,
      reportedUid: m.reportedUid,
      alasanLaporan: m.reportReason,
      kategoriLaporan: m.reportCategory,
      tanggal: m.createdAt,
      status: _mapModerasiStatus(m.status),
      isiLaporan: m.contentText,
      catatanAdmin: m.catatanAdmin,
      diaryId: '',
      imageUrls: const [],
    );
  }

  LaporanStatus _mapModerasiStatus(String raw) {
    switch (raw.toLowerCase()) {
      case 'diproses':
        return LaporanStatus.diproses;
      case 'selesai':
        return LaporanStatus.selesai;
      case 'ditolak':
        return LaporanStatus.ditolak;
      default:
        return LaporanStatus.pending;
    }
  }

  String get _userStatusLabel {
    final now = DateTime.now();

    if (_banUntil != null && _banUntil!.isAfter(now)) {
      return 'Ban Sementara';
    }

    final warning = _warningMessage.toLowerCase();
    final notice = (_chatNotice ?? '').toLowerCase();

    if (warning.contains('permanen') || notice.contains('permanen')) {
      return 'Ban Permanen';
    }

    if (_hasWarning ||
        warning.isNotEmpty ||
        notice.contains('dibatasi') ||
        notice.contains('peringatan')) {
      return 'Dibatasi';
    }

    return 'Normal';
  }

  Map<String, dynamic> _userStatusStyle(String label) {
    switch (label) {
      case 'Dibatasi':
        return {
          'bg': _greenMint,
          'text': _greenDark,
          'icon': Icons.shield_outlined,
        };
      case 'Ban Sementara':
        return {
          'bg': _peachSoft,
          'text': const Color(0xFFD6984E),
          'icon': Icons.timer_off_rounded,
        };
      case 'Ban Permanen':
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.gpp_bad_rounded,
        };
      case 'Normal':
      default:
        return {
          'bg': _blueSoft,
          'text': const Color(0xFF4E92C2),
          'icon': Icons.verified_user_outlined,
        };
    }
  }

  String _statusDescription() {
    if (_userStatusLabel == 'Ban Sementara' && _banUntil != null) {
      return 'Aktif sampai ${_formatTanggal(_banUntil)}';
    }

    if (_warningMessage.trim().isNotEmpty) {
      return _warningMessage.trim();
    }

    if ((_chatNotice ?? '').trim().isNotEmpty) {
      return _chatNotice!.trim();
    }

    switch (_userStatusLabel) {
      case 'Dibatasi':
        return 'Akses user sedang dibatasi.';
      case 'Ban Permanen':
        return 'User sedang diban permanen.';
      case 'Ban Sementara':
        return 'User sedang diban sementara.';
      default:
        return 'Belum ada tindakan aktif.';
    }
  }

  ImageProvider _resolveAvatar(String value) {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      return const AssetImage('assets/profile_pic/PP_default.jpg');
    }

    if (trimmed.startsWith('http')) {
      return NetworkImage(trimmed);
    }

    return AssetImage(trimmed);
  }

  String _initialOf(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) return 'U';
    return trimmed[0].toUpperCase();
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return '-';

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

  String _shortContent(String value) {
    final clean = value.trim();
    if (clean.isEmpty) return 'Konten tidak tersedia';
    if (clean.length <= 140) return clean;
    return '${clean.substring(0, 140)}...';
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

  Map<String, dynamic> _typeStyle(String type) {
    final lower = type.toLowerCase();

    if (lower.contains('chat')) {
      return {
        'bg': _pinkSoft,
        'text': const Color(0xFFE78BA0),
        'icon': Icons.forum_rounded,
      };
    }

    if (lower.contains('comment')) {
      return {
        'bg': _blueSoft,
        'text': const Color(0xFF4E92C2),
        'icon': Icons.mode_comment_rounded,
      };
    }

    return {
      'bg': _peachSoft,
      'text': const Color(0xFFD6984E),
      'icon': Icons.book_rounded,
    };
  }

  Map<String, dynamic> _actionStyle(String value) {
    switch (value) {
      case 'batasiUser':
        return {
          'bg': _greenMint,
          'text': _greenDark,
          'icon': Icons.shield_outlined,
          'label': 'Batasi User',
        };
      case 'banSementara':
        return {
          'bg': _peachSoft,
          'text': const Color(0xFFD6984E),
          'icon': Icons.timer_off_rounded,
          'label': 'Ban Sementara',
        };
      case 'banPermanen':
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.gpp_bad_rounded,
          'label': 'Ban Permanen',
        };
      case 'cabutTindakan':
      default:
        return {
          'bg': _blueSoft,
          'text': const Color(0xFF4E92C2),
          'icon': Icons.restart_alt_rounded,
          'label': 'Cabut Tindakan',
        };
    }
  }

  List<LaporanUserModel> get _filteredReports {
    final result = _allUserReports.where((report) {
      final matchType =
          _selectedType == 'Semua tipe' ? true : report.tipeKonten == _selectedType;

      final matchStatus = _selectedStatus == 'Semua status'
          ? true
          : report.status.label == _selectedStatus;

      return matchType && matchStatus;
    }).toList();

    switch (_selectedSort) {
      case 'Terlama':
        result.sort((a, b) => a.tanggal.compareTo(b.tanggal));
        break;
      case 'Kategori A-Z':
        result.sort((a, b) => a.kategoriLaporan.toLowerCase().compareTo(
              b.kategoriLaporan.toLowerCase(),
            ));
        break;
      case 'Terbaru':
      default:
        result.sort((a, b) => b.tanggal.compareTo(a.tanggal));
        break;
    }

    return result;
  }

  int _countByStatus(LaporanStatus status) {
    return _allUserReports.where((report) => report.status == status).length;
  }

  String _buildAutoNote() {
    switch (_selectedAction) {
      case 'batasiUser':
        return 'Admin membatasi akses user berdasarkan riwayat pelanggaran.';
      case 'banSementara':
        return 'Admin memberikan ban sementara berdasarkan riwayat pelanggaran.';
      case 'banPermanen':
        return 'Admin memberikan ban permanen berdasarkan riwayat pelanggaran.';
      case 'cabutTindakan':
        return 'Admin mencabut tindakan sebelumnya setelah meninjau ulang.';
      default:
        return 'Admin meninjau pelanggaran user.';
    }
  }

  DateTime? _resolveBanUntil() {
    if (_selectedAction != 'banSementara' || _selectedDuration == null) {
      return null;
    }

    return DateTime.now().add(_selectedDuration!);
  }

  Future<bool> _confirmAction() async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (_) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(26),
              boxShadow: _softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _pinkSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.admin_panel_settings_rounded,
                    color: Color(0xFFE78BA0),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Simpan tindakan admin?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tindakan akan diterapkan ke user dan laporan aktif yang relevan.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: _textSoft,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _dialogButton(
                        label: 'Batal',
                        bg: _greenMint,
                        textColor: _greenDark,
                        onTap: () => Navigator.pop(context, false),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _dialogButton(
                        label: 'Ya, simpan',
                        bg: _pinkSoft,
                        textColor: const Color(0xFFD95067),
                        onTap: () => Navigator.pop(context, true),
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

    return result ?? false;
  }

  Widget _dialogButton({
    required String label,
    required Color bg,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: textColor.withOpacity(0.16)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _saveAction() async {
    if (_selectedAction == null) {
      showCuteTopPopup(
        context,
        title: 'Pilih tindakan dulu',
        message: 'Admin perlu memilih tindakan sebelum menyimpan.',
        type: CutePopupType.warning,
      );
      return;
    }

    if (_selectedAction == 'banSementara' && _selectedDuration == null) {
      showCuteTopPopup(
        context,
        title: 'Durasi belum dipilih',
        message: 'Ban sementara butuh durasi yang jelas.',
        type: CutePopupType.warning,
      );
      return;
    }

    final confirmed = await _confirmAction();
    if (!confirmed) return;

    setState(() => _isSaving = true);

    try {
      final note = _catatanController.text.trim().isEmpty
          ? _buildAutoNote()
          : _catatanController.text.trim();
      final banUntil = _resolveBanUntil();

      final batch = FirebaseFirestore.instance.batch();

      final candidates = _allUserReports
          .where((r) =>
              r.status == LaporanStatus.pending ||
              r.status == LaporanStatus.diproses)
          .toList();

      final docsToUpdate = candidates.isNotEmpty
          ? candidates
          : (_allUserReports.isNotEmpty ? [_allUserReports.first] : []);

      for (final report in docsToUpdate) {
        final ref = FirebaseFirestore.instance
            .collection('reports')
            .doc(report.documentId);

        final payload = <String, dynamic>{
          'status': 'selesai',
          'catatanAdmin': note,
          'tindakanDipilih': _selectedAction,
          'tindakanSaatIni': _selectedAction,
          'alasanTindakan': note,
          'updatedAt': FieldValue.serverTimestamp(),
          'actionUpdatedAt': FieldValue.serverTimestamp(),
        };

        if (banUntil != null) {
          payload['banUntil'] = Timestamp.fromDate(banUntil);
        } else {
          payload['banUntil'] = FieldValue.delete();
        }

        batch.set(ref, payload, SetOptions(merge: true));
      }

      if (_uid.isNotEmpty) {
        final userRef = FirebaseFirestore.instance.collection('users').doc(_uid);

        final userPayload = <String, dynamic>{
          'warningUpdatedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        };

        switch (_selectedAction) {
          case 'batasiUser':
            userPayload['hasWarning'] = true;
            userPayload['warningMessage'] = note;
            userPayload['chatNotice'] = 'Akses Anda dibatasi';
            userPayload['banUntil'] = FieldValue.delete();
            break;

          case 'banSementara':
            userPayload['hasWarning'] = true;
            userPayload['warningMessage'] = note;
            userPayload['chatNotice'] = 'Akun Anda dibanned sementara';
            if (banUntil != null) {
              userPayload['banUntil'] = Timestamp.fromDate(banUntil);
            }
            break;

          case 'banPermanen':
            userPayload['hasWarning'] = true;
            userPayload['warningMessage'] = note;
            userPayload['chatNotice'] = 'Akun Anda dibanned permanen';
            userPayload['banUntil'] = FieldValue.delete();
            break;

          case 'cabutTindakan':
            userPayload['hasWarning'] = false;
            userPayload['warningMessage'] = '';
            userPayload['chatNotice'] = null;
            userPayload['banUntil'] = FieldValue.delete();
            break;
        }

        batch.set(userRef, userPayload, SetOptions(merge: true));
      }

      await batch.commit();

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Tindakan tersimpan',
        message: 'Keputusan moderasi berhasil diperbarui.',
        type: CutePopupType.success,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: 'Gagal menyimpan',
        message: 'Tindakan moderasi belum berhasil diterapkan.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredReports = _filteredReports;

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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTopBar(),
                        const SizedBox(height: 18),
                        _buildProfileHero(),
                        const SizedBox(height: 16),
                        _buildHistorySection(filteredReports),
                        const SizedBox(height: 16),
                        _buildActionSection(),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _card,
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(
              Icons.arrow_back_rounded,
              color: _greenDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Tinjau Moderasi User',
            style: GoogleFonts.fredoka(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: _greenDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileHero() {
    final total = _allUserReports.length;
    final pending = _countByStatus(LaporanStatus.pending);
    final processed = _countByStatus(LaporanStatus.diproses);
    final done = _countByStatus(LaporanStatus.selesai);
    final userStatusStyle = _userStatusStyle(_userStatusLabel);

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
            left: -18,
            bottom: -18,
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.90),
              ),
            ),
          ),
          Column(
            children: [
              Container(
                width: 108,
                height: 108,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _softShadow,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: ClipOval(
                  child: Image(
                    image: _resolveAvatar(_avatar),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: _greenMint,
                        alignment: Alignment.center,
                        child: Text(
                          _initialOf(_displayName),
                          style: GoogleFonts.fredoka(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: _greenDark,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _displayName,
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  if (_uid.isNotEmpty)
                    _heroChip(
                      icon: Icons.badge_outlined,
                      text: _uid,
                      bg: _greenMint,
                      iconColor: _greenDark,
                    ),
                  if (_joinedAt != null)
                    _heroChip(
                      icon: Icons.calendar_today_rounded,
                      text: 'Gabung ${_formatTanggal(_joinedAt)}',
                      bg: _greenMint,
                      iconColor: _greenDark,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: userStatusStyle['bg'] as Color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      userStatusStyle['icon'] as IconData,
                      size: 15,
                      color: userStatusStyle['text'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _userStatusLabel,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: userStatusStyle['text'] as Color,
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
                child: Text(
                  _statusDescription(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _heroChip(
                    icon: Icons.gpp_good_rounded,
                    text: '$total pelanggaran',
                    bg: _pinkSoft,
                    iconColor: const Color(0xFFE78BA0),
                  ),
                  _heroChip(
                    icon: Icons.schedule_rounded,
                    text: '$pending pending',
                    bg: _yellowSoft,
                    iconColor: const Color(0xFFB07A10),
                  ),
                  _heroChip(
                    icon: Icons.hourglass_top_rounded,
                    text: '$processed diproses',
                    bg: _greenSoft,
                    iconColor: _greenDark,
                  ),
                  _heroChip(
                    icon: Icons.check_circle_rounded,
                    text: '$done selesai',
                    bg: _greenMint,
                    iconColor: _greenDark,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _heroChip({
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
          Icon(icon, size: 14, color: iconColor),
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

  Widget _buildHistorySection(List<LaporanUserModel> reports) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Pelanggaran',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat pola pelanggarannya, bukan cuma satu kejadian.',
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  value: _selectedType,
                  items: _typeOptions,
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdown(
                  value: _selectedStatus,
                  items: _statusOptions,
                  onChanged: (value) {
                    setState(() => _selectedStatus = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildDropdown(
            value: _selectedSort,
            items: _sortOptions,
            onChanged: (value) {
              setState(() => _selectedSort = value!);
            },
          ),
          const SizedBox(height: 16),
          if (reports.isEmpty) _emptyHistory() else ...reports.map(_buildReportCard),
        ],
      ),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE7E9E2)),
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

  Widget _buildReportCard(LaporanUserModel report) {
    final statusStyle = _statusStyle(report.status);
    final typeStyle = _typeStyle(report.tipeKonten);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFEDEFE8)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                        color: typeStyle['text'] as Color,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        report.tipeKonten,
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: typeStyle['text'] as Color,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
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
                        report.status.label,
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
            const SizedBox(height: 12),
            Text(
              report.kategoriLaporan.trim().isEmpty
                  ? 'Kategori tidak tersedia'
                  : report.kategoriLaporan,
              style: GoogleFonts.fredoka(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Dilaporkan oleh ${report.namaPelapor} • ${_formatTanggalJam(report.tanggal)}',
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _textSoft,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: typeStyle['bg'] as Color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '“${_shortContent(report.isiLaporan)}”',
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  height: 1.45,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              report.alasanLaporan.trim().isEmpty
                  ? 'Tidak ada alasan tambahan.'
                  : 'Alasan laporan: ${report.alasanLaporan}',
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
    );
  }

  Widget _emptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: _greenMint,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.inbox_rounded,
            color: _greenDark,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            'Belum ada riwayat yang cocok dengan filter ini.',
            textAlign: TextAlign.center,
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w700,
              color: _textSoft,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tindakan untuk User',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Terapkan keputusan langsung dari profil moderasi user.',
            style: GoogleFonts.openSans(
              fontSize: 12,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Catatan Admin',
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE7E9E2)),
            ),
            child: TextField(
              controller: _catatanController,
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                border: InputBorder.none,
                counterText: '',
                hintText: 'Tulis catatan atau alasan tindakan...',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9AA097),
                ),
                contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              ),
              style: GoogleFonts.openSans(
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_catatanController.text.length}/500',
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _textSoft,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Pilih Tindakan',
            style: GoogleFonts.openSans(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: _textSoft,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _actionChip('batasiUser'),
              _actionChip('banSementara'),
              _actionChip('banPermanen'),
              _actionChip('cabutTindakan'),
            ],
          ),
          if (_selectedAction == 'banSementara') ...[
            const SizedBox(height: 14),
            Text(
              'Durasi Ban Sementara',
              style: GoogleFonts.openSans(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: _textSoft,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _durationOptions.map((item) {
                final label = item['label'] as String;
                final duration = item['duration'] as Duration;
                final isSelected = _selectedDuration == duration;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDuration = duration;
                      _selectedDurationLabel = label;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? _peachSoft : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFFD6984E).withOpacity(0.35)
                            : const Color(0xFFE7E9E2),
                      ),
                    ),
                    child: Text(
                      label,
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isSelected
                            ? const Color(0xFFD6984E)
                            : _textDark,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 20),
          if (_isSaving)
            const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE78BA0),
              ),
            )
          else ...[
            _primaryButton(
              label: 'Simpan Tindakan',
              icon: Icons.check_circle_rounded,
              color: _green,
              onTap: _saveAction,
            ),
            const SizedBox(height: 12),
            _secondaryButton(
              label: 'Kembali',
              onTap: () => Navigator.pop(context),
            ),
          ],
        ],
      ),
    );
  }

  Widget _actionChip(String value) {
    final isSelected = _selectedAction == value;
    final style = _actionStyle(value);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAction = value;
          if (value != 'banSementara') {
            _selectedDuration = null;
            _selectedDurationLabel = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? (style['bg'] as Color) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? (style['text'] as Color).withOpacity(0.35)
                : const Color(0xFFE7E9E2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              style['icon'] as IconData,
              size: 15,
              color: style['text'] as Color,
            ),
            const SizedBox(width: 6),
            Text(
              style['label'] as String,
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: isSelected ? style['text'] as Color : _textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _secondaryButton({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE4E7DE)),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.openSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: _textSoft,
            ),
          ),
        ),
      ),
    );
  }
}