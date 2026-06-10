import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin/ajuan_banding_model.dart';
import '../../services/admin/ajuan_banding_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';

class TinjauAjuanBandingUserAdminPage extends StatefulWidget {
  final AjuanBandingModel? ajuan;

  const TinjauAjuanBandingUserAdminPage({
    super.key,
    this.ajuan,
  });

  @override
  State<TinjauAjuanBandingUserAdminPage> createState() =>
      _TinjauAjuanBandingUserAdminPageState();
}

class _TinjauAjuanBandingUserAdminPageState
    extends State<TinjauAjuanBandingUserAdminPage> {
  final TextEditingController _catatanController = TextEditingController();
  final AjuanBandingService _ajuanService = AjuanBandingService();

  late final AjuanBandingModel _ajuan;

  bool _isSaving = false;
  TindakanUser? _selectedAction;
  Duration? _selectedDuration;
  String? _selectedDurationLabel;

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

  final List<Map<String, dynamic>> _durationOptions = const [
    {'label': '1 Jam', 'duration': Duration(hours: 1)},
    {'label': '6 Jam', 'duration': Duration(hours: 6)},
    {'label': '12 Jam', 'duration': Duration(hours: 12)},
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

    _ajuan = widget.ajuan ??
        AjuanBandingModel(
          documentId: '',
          id: 'BD-0001',
          username: 'UserXyz',
          userId: 'USER-001',
          avatarUrl: '',
          jenisBan: 'Ban Sementara',
          alasanBanding: 'Tidak sengaja, aku hanya berbagi cerita pribadi.',
          tanggal: DateTime(2026, 4, 10),
          status: AjuanBandingStatus.pending,
          catatanAdmin: '',
          alasanTindakan: 'User melanggar aturan komunitas.',
          tindakanSaatIni: TindakanUser.banSementara,
          isiPesan: 'Menggunakan kata-kata kasar',
          tanggalGabung: DateTime(2026, 1, 12),
        );

    _catatanController.text = _ajuan.catatanAdmin;
    _catatanController.addListener(() {
      if (mounted) setState(() {});
    });
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

    return '${date.day.toString().padLeft(2, '0')} ${bulan[date.month]} ${date.year}';
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

  String _placeholder(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value;
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

  Map<String, dynamic> _actionStyle(TindakanUser action) {
    switch (action) {
      case TindakanUser.batasiUser:
        return {
          'bg': _greenMint,
          'text': _greenDark,
          'icon': Icons.shield_outlined,
        };
      case TindakanUser.banSementara:
        return {
          'bg': _peachSoft,
          'text': const Color(0xFFD6984E),
          'icon': Icons.timer_off_rounded,
        };
      case TindakanUser.banPermanen:
        return {
          'bg': _pinkSoft,
          'text': const Color(0xFFD95067),
          'icon': Icons.gpp_bad_rounded,
        };
      case TindakanUser.cabutTindakan:
        return {
          'bg': _blueSoft,
          'text': const Color(0xFF4E92C2),
          'icon': Icons.restart_alt_rounded,
        };
    }
  }

  Future<bool> _showConfirmDialog(String title, String desc) async {
    final result = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.32),
      builder: (context) {
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
                    Icons.rule_folder_rounded,
                    color: Color(0xFFE78BA0),
                    size: 28,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.fredoka(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  desc,
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
                        label: 'Ya, lanjutkan',
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

  DateTime _getBanUntil(Duration duration) {
    return DateTime.now().add(duration);
  }

  Future<void> _applyUserActionToUsersCollection(
    TindakanUser action, {
    DateTime? banUntil,
  }) async {
    final uid = _ajuan.userId.trim();
    if (uid.isEmpty) return;

    final note = _catatanController.text.trim().isEmpty
        ? _placeholder(_ajuan.alasanTindakan, 'Tindakan moderasi admin')
        : _catatanController.text.trim();

    final payload = <String, dynamic>{
      'warningUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    switch (action) {
      case TindakanUser.batasiUser:
        payload['hasWarning'] = true;
        payload['warningMessage'] = note;
        payload['chatNotice'] = 'Akses Anda dibatasi';
        payload['banUntil'] = FieldValue.delete();
        break;

      case TindakanUser.banSementara:
        payload['hasWarning'] = true;
        payload['warningMessage'] = note;
        payload['chatNotice'] = 'Akun Anda dibanned sementara';
        if (banUntil != null) {
          payload['banUntil'] = Timestamp.fromDate(banUntil);
        }
        break;

      case TindakanUser.banPermanen:
        payload['hasWarning'] = true;
        payload['warningMessage'] = note;
        payload['chatNotice'] = 'Akun Anda dibanned permanen';
        payload['banUntil'] = FieldValue.delete();
        break;

      case TindakanUser.cabutTindakan:
        payload['hasWarning'] = false;
        payload['warningMessage'] = '';
        payload['chatNotice'] = null;
        payload['banUntil'] = FieldValue.delete();
        break;
    }

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .set(payload, SetOptions(merge: true));
  }

  Future<void> _ubahStatus(
    AjuanBandingStatus status, {
    TindakanUser? tindakanDipilih,
    DateTime? banUntil,
  }) async {
    if (_ajuan.documentId.isEmpty) {
      showCuteTopPopup(
        context,
        title: 'Data belum siap',
        message: 'Ajuan banding ini belum terhubung ke Firebase.',
        type: CutePopupType.error,
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _ajuanService.updateStatusAjuanBanding(
        documentId: _ajuan.documentId,
        status: status,
        catatanAdmin: _catatanController.text.trim(),
        tindakanDipilih: tindakanDipilih,
        banUntil: banUntil,
      );

      final resolvedAction = status == AjuanBandingStatus.disetujui
          ? (tindakanDipilih ?? _ajuan.tindakanSaatIni)
          : _ajuan.tindakanSaatIni;

      await _applyUserActionToUsersCollection(
        resolvedAction,
        banUntil: banUntil,
      );

      // fallback kecil karena service lamamu punya pengecekan sementara yang agak nyeleneh
      if (status == AjuanBandingStatus.disetujui &&
          tindakanDipilih == TindakanUser.banSementara &&
          banUntil != null) {
        await FirebaseFirestore.instance
            .collection('reports')
            .doc(_ajuan.documentId)
            .update({
          'banUntil': Timestamp.fromDate(banUntil),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: status == AjuanBandingStatus.disetujui
            ? 'Banding disetujui'
            : 'Banding ditolak',
        message: status == AjuanBandingStatus.disetujui
            ? 'Keputusan admin berhasil disimpan.'
            : 'Penolakan banding berhasil disimpan.',
        type: status == AjuanBandingStatus.disetujui
            ? CutePopupType.success
            : CutePopupType.warning,
      );

      await Future.delayed(const Duration(milliseconds: 700));

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Gagal menyimpan',
        message: 'Keputusan banding belum berhasil disimpan.',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleTerimaBanding() async {
    if (_selectedAction == null) {
      showCuteTopPopup(
        context,
        title: 'Pilih tindakan dulu',
        message: 'Admin perlu memilih tindakan akhir untuk user ini.',
        type: CutePopupType.warning,
      );
      return;
    }

    if (_selectedAction == TindakanUser.banSementara &&
        _selectedDuration == null) {
      showCuteTopPopup(
        context,
        title: 'Durasi belum dipilih',
        message: 'Ban sementara butuh durasi. Manusia suka aturan yang jelas, katanya.',
        type: CutePopupType.warning,
      );
      return;
    }

    final confirm = await _showConfirmDialog(
      'Terima banding ini?',
      _selectedAction == TindakanUser.banSementara
          ? 'Banding akan diterima dengan tindakan ${_selectedAction!.label} selama $_selectedDurationLabel.'
          : 'Banding akan diterima dengan tindakan ${_selectedAction!.label}.',
    );

    if (!confirm) return;

    await _ubahStatus(
      AjuanBandingStatus.disetujui,
      tindakanDipilih: _selectedAction,
      banUntil: _selectedDuration == null ? null : _getBanUntil(_selectedDuration!),
    );
  }

  Future<void> _handleTolakBanding() async {
    final confirm = await _showConfirmDialog(
      'Tolak banding ini?',
      'Keputusan ini akan menyimpan status banding sebagai ditolak.',
    );

    if (!confirm) return;
    await _ubahStatus(AjuanBandingStatus.ditolak);
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statusStyle = _statusStyle(_ajuan.status);
    final currentActionStyle = _actionStyle(_ajuan.tindakanSaatIni);

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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopBar(statusStyle),
                  const SizedBox(height: 18),
                  _buildHeroCard(statusStyle, currentActionStyle),
                  const SizedBox(height: 16),
                  _buildViolationContextCard(),
                  const SizedBox(height: 16),
                  _buildAppealCard(),
                  const SizedBox(height: 16),
                  _buildAdminDecisionCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(Map<String, dynamic> statusStyle) {
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
            'Tinjau Ajuan Banding',
            style: GoogleFonts.fredoka(
              fontSize: 27,
              fontWeight: FontWeight.w700,
              color: _greenDark,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                _ajuan.status.label,
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
    );
  }

  Widget _buildHeroCard(
    Map<String, dynamic> statusStyle,
    Map<String, dynamic> currentActionStyle,
  ) {
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
                width: 104,
                height: 104,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _softShadow,
                  border: Border.all(color: Colors.white, width: 4),
                  image: DecorationImage(
                    image: _resolveAvatar(_ajuan.avatarUrl),
                    fit: BoxFit.cover,
                  ),
                ),
                child: ClipOval(
                  child: Image(
                    image: _resolveAvatar(_ajuan.avatarUrl),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) {
                      return Container(
                        color: _greenMint,
                        alignment: Alignment.center,
                        child: Text(
                          _initialOf(_ajuan.username),
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
                _placeholder(_ajuan.username, 'User tidak diketahui'),
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
                  _heroChip(
                    icon: Icons.badge_outlined,
                    text: _ajuan.userId.isEmpty ? 'UID tidak tersedia' : _ajuan.userId,
                    bg: _greenMint,
                    iconColor: _greenDark,
                  ),
                  if (_ajuan.tanggalGabung != null)
                    _heroChip(
                      icon: Icons.calendar_today_rounded,
                      text: 'Gabung ${_formatTanggal(_ajuan.tanggalGabung!)}',
                      bg: _greenMint,
                      iconColor: _greenDark,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: currentActionStyle['bg'] as Color,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      currentActionStyle['icon'] as IconData,
                      size: 15,
                      color: currentActionStyle['text'] as Color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Tindakan saat ini: ${_ajuan.tindakanSaatIni.label}',
                      style: GoogleFonts.openSans(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: currentActionStyle['text'] as Color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '#${_ajuan.id} • ${_formatTanggalJam(_ajuan.tanggal)}',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
                ),
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

  Widget _buildViolationContextCard() {
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
            'Konteks Pelanggaran',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            icon: Icons.rule_rounded,
            label: 'Alasan tindakan',
            value: _placeholder(_ajuan.alasanTindakan, 'Belum ada alasan tindakan'),
            iconBg: _pinkSoft,
            iconColor: const Color(0xFFE78BA0),
          ),
          const SizedBox(height: 12),
          _infoRow(
            icon: Icons.schedule_rounded,
            label: 'Tanggal laporan',
            value: _formatTanggalJam(_ajuan.tanggal),
            iconBg: _greenMint,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 12),
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
                  'Pesan / konten yang dilaporkan',
                  style: GoogleFonts.openSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFD95067),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '“${_placeholder(_ajuan.isiPesan, 'Isi pesan tidak tersedia')}”',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppealCard() {
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
            'Isi Ajuan Banding',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _greenMint,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _greenSoft),
            ),
            child: Text(
              '“${_placeholder(_ajuan.alasanBanding, 'Alasan banding belum tersedia')}”',
              style: GoogleFonts.openSans(
                fontSize: 12,
                height: 1.55,
                fontWeight: FontWeight.w700,
                color: _textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminDecisionCard() {
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
            'Keputusan Admin',
            style: GoogleFonts.fredoka(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
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
              maxLength: 500,
              maxLines: 4,
              decoration: InputDecoration(
                counterText: '',
                hintText: 'Tulis catatan atau pertimbangan keputusan...',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9AA097),
                ),
                border: InputBorder.none,
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
            'Tindakan Akhir',
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
            children: TindakanUser.values.map((action) {
              final isSelected = _selectedAction == action;
              final style = _actionStyle(action);

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAction = action;
                    if (action != TindakanUser.banSementara) {
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
                        action.label,
                        style: GoogleFonts.openSans(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isSelected
                              ? style['text'] as Color
                              : _textDark,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          if (_selectedAction == TindakanUser.banSementara) ...[
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              label: 'Terima Banding',
              icon: Icons.check_circle_rounded,
              color: _green,
              textColor: Colors.white,
              onTap: _handleTerimaBanding,
            ),
            const SizedBox(height: 12),
            _primaryButton(
              label: 'Tolak Banding',
              icon: Icons.cancel_rounded,
              color: const Color(0xFFFF8C9B),
              textColor: Colors.white,
              onTap: _handleTolakBanding,
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

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.openSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: _textSoft,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
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
      ],
    );
  }

  Widget _primaryButton({
    required String label,
    required IconData icon,
    required Color color,
    required Color textColor,
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
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: textColor,
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