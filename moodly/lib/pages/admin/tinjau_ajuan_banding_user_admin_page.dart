import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin/ajuan_banding_model.dart';
import '../../services/admin/ajuan_banding_service.dart';

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

  @override
  void initState() {
    super.initState();

    _ajuan = widget.ajuan ??
        AjuanBandingModel(
          documentId: '',
          id: 'BD-0001',
          username: 'UserXyz',
          jenisBan: 'Ban Sementara',
          alasanBanding: 'Tidak sengaja, aku hanya berbagi cerita pribadi....',
          tanggal: DateTime(2026, 4, 10),
          status: AjuanBandingStatus.pending,
          catatanAdmin: '',
          alasanTindakan: 'User melanggar aturan komunitas.',
          tindakanSaatIni: TindakanUser.banSementara,
        );

    _catatanController.text = _ajuan.catatanAdmin;

    _catatanController.addListener(() {
      if (mounted) setState(() {});
    });
  }

Future<void> _ubahStatus(
  AjuanBandingStatus status, {
  TindakanUser? tindakanDipilih,
}) async {
  if (_ajuan.documentId.isEmpty) {
    _showMessage('Data ajuan belum terhubung ke Firebase');
    return;
  }

  await _ajuanService.updateStatusAjuanBanding(
    documentId: _ajuan.documentId,
    status: status,
    catatanAdmin: _catatanController.text.trim(),
    tindakanDipilih: tindakanDipilih,
  );

  if (!mounted) return;
  Navigator.pop(context, true);
}

void _showPilihTindakanSheet() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Pilih Tindakan Akhir',
              style: GoogleFonts.fredoka(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF486253),
              ),
            ),
            const SizedBox(height: 18),
            _tindakanOption(TindakanUser.batasiUser),
            _tindakanOption(TindakanUser.banSementara),
            _tindakanOption(TindakanUser.banPermanen),
            _tindakanOption(TindakanUser.cabutTindakan),
          ],
        ),
      );
    },
  );
}

Widget _tindakanOption(TindakanUser tindakan) {
  return GestureDetector(
    onTap: () {
      Navigator.pop(context);
      _ubahStatus(
        AjuanBandingStatus.disetujui,
        tindakanDipilih: tindakan,
      );
    },
    child: Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(vertical: 13),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: tindakan == TindakanUser.cabutTindakan
            ? const Color(0xFFD9FFD0)
            : const Color(0xFFFFF1F1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        tindakan.label,
        style: GoogleFonts.fredoka(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF0C0E0C),
        ),
      ),
    ),
  );
}

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
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
        return const Color(0xFFF7D783);
      case AjuanBandingStatus.disetujui:
        return const Color(0xFFAEDB9A);
      case AjuanBandingStatus.ditolak:
        return const Color(0xFFFFB9B9);
    }
  }

  Color _statusTextColor(AjuanBandingStatus status) {
    switch (status) {
      case AjuanBandingStatus.pending:
        return const Color(0xFF9A6F1A);
      case AjuanBandingStatus.disetujui:
        return const Color(0xFF20560A);
      case AjuanBandingStatus.ditolak:
        return const Color(0xFFFF0000);
    }
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1FBD8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(25, 18, 35, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildHeader(context),
              const SizedBox(height: 38),
              _buildUserInformationCard(),
              const SizedBox(height: 20),
              _buildPelanggaranCard(),
              const SizedBox(height: 20),
              _buildAjuanBandingCard(),
              const SizedBox(height: 20),
              _buildCatatanAdminCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(Icons.arrow_back_rounded, size: 26),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Tinjau Ajuan\nBanding User',
                  style: GoogleFonts.fredoka(
                    fontSize: 27,
                    fontWeight: FontWeight.w700,
                    height: 0.92,
                    color: const Color(0xFF486253),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: _buildStatusBadge(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '#${_ajuan.id}',
                    style: GoogleFonts.fredoka(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF252525),
                    ),
                  ),
                  TextSpan(
                    text: ' • Diajukan ${_formatTanggal(_ajuan.tanggal)}',
                    style: GoogleFonts.openSans(
                      fontSize: 14,
                      color: const Color(0xFF6B6B6B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      width: 88,
      height: 20,
      alignment: const Alignment(0, -0.08),
      decoration: BoxDecoration(
        color: _statusBackgroundColor(_ajuan.status),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _ajuan.status.label,
        style: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          height: 22 / 12,
          color: _statusTextColor(_ajuan.status),
        ),
      ),
    );
  }

  Widget _buildUserInformationCard() {
    return _buildWhiteCard(
      height: 135,
      padding: const EdgeInsets.fromLTRB(30, 22, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Informasi User'),
          const SizedBox(height: 24),
          Row(
            children: [
              _buildAvatar(),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _boldText(_ajuan.username),
                    const SizedBox(height: 2),
                    _normalText('ID User: 091283'),
                    const SizedBox(height: 6),
                    _normalText('Bergabung sejak 12 Januari 2026'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPelanggaranCard() {
    return _buildWhiteCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Pelanggaran Sebelumnya'),
          const SizedBox(height: 24),
          _buildInfoRow('Jenis', 'Chat Anonim'),
          const SizedBox(height: 18),
          _buildInfoRow('Tanggal', '06 April 2026'),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Konten',
            null,
            child: _pinkBox(
              text: '“Menggunakan kata - kata\nkasar”',
              width: 140,
              height: 50,
              light: true,
            ),
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            'Keputusan',
            null,
            child: _pinkBox(
              text: _ajuan.jenisBan,
              width: 140,
              height: 35,
              light: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAjuanBandingCard() {
    return _buildWhiteCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Ajuan Banding'),
          const SizedBox(height: 18),
          _normalText('Alasan User'),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFD9FFD0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFAEDB9A)),
            ),
            child: Text(
              '“${_ajuan.alasanBanding}”',
              style: GoogleFonts.openSans(
                fontSize: 10,
                height: 1.8,
                color: const Color(0xFF0C0E0C),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _normalText('Tanggal Pengajuan'),
          const SizedBox(height: 4),
          Text(
            'Diajukan ${_formatTanggal(_ajuan.tanggal)}  •  09.15',
            style: GoogleFonts.openSans(
              fontSize: 10,
              color: const Color(0xFF6B6B6B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanAdminCard() {
    return _buildWhiteCard(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Catatan Admin (Opsional)'),
          const SizedBox(height: 20),
          Container(
            height: 82,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(7),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: TextField(
              controller: _catatanController,
              maxLength: 500,
              maxLines: 3,
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Tulis catatan atau pertimbangan Keputusan....',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 10,
                  color: const Color(0xFF8A8A8A),
                ),
              ),
              style: GoogleFonts.openSans(fontSize: 10),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${_catatanController.text.length}/500',
            style: GoogleFonts.openSans(
              fontSize: 10,
              color: const Color(0xFF6B6B6B),
            ),
          ),
          const SizedBox(height: 18),
          _buildActionButton(
            label: 'Terima Banding',
            icon: Icons.check_circle_rounded,
            color: const Color(0xFF8ECD86),
            onTap: _showPilihTindakanSheet,
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: 'Tolak Banding',
            icon: Icons.cancel_rounded,
            color: const Color(0xFFFF7474),
            onTap: () => _ubahStatus(AjuanBandingStatus.ditolak),
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            label: 'Kembali',
            color: const Color(0xFFD9D9D9),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildWhiteCard({
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: padding ?? const EdgeInsets.fromLTRB(22, 22, 22, 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.fredoka(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF333333),
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 50,
      height: 50,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: Color(0xFFC8FFE3),
        shape: BoxShape.circle,
      ),
      child: const Text(
        '✧',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value, {Widget? child}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 75,
          child: _normalText(label),
        ),
        const SizedBox(width: 12),
        child ?? _normalText(value ?? ''),
      ],
    );
  }

  Widget _pinkBox({
    required String text,
    required double width,
    required double height,
    required bool light,
  }) {
    return Container(
      width: width,
      height: height,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: light ? const Color(0xFFFFDADA) : const Color(0xFFFFB4B4),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            offset: const Offset(0, 1),
            blurRadius: 5,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: GoogleFonts.openSans(
          fontSize: 10,
          fontWeight: FontWeight.w400,
          height: 22 / 10,
          color: light ? const Color(0xFF222222) : const Color(0xFFE00000),
        ),
      ),
    );
  }

  Widget _boldText(String text) {
    return Text(
      text,
      style: GoogleFonts.fredoka(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF0C0E0C),
      ),
    );
  }

  Widget _normalText(String text) {
    return Text(
      text,
      style: GoogleFonts.openSans(
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: const Color(0xFF0C0E0C),
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
    IconData? icon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 30,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18, color: Colors.white),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.fredoka(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}