import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/admin/laporan_user_model.dart';
import '../../services/admin/laporan_user_service.dart';

class TinjauLaporanUserAdminPage extends StatefulWidget {
  final LaporanUserModel? laporan;

  const TinjauLaporanUserAdminPage({
    super.key,
    this.laporan,
  });

  @override
  State<TinjauLaporanUserAdminPage> createState() =>
      _TinjauLaporanUserAdminPageState();
}

class _TinjauLaporanUserAdminPageState
    extends State<TinjauLaporanUserAdminPage> {
  final TextEditingController _catatanController = TextEditingController();
  final LaporanUserService _laporanService = LaporanUserService();

  late final LaporanUserModel _laporan;

  @override
  void initState() {
    super.initState();

   _laporan = widget.laporan ??
    LaporanUserModel(
      documentId: '',
      id: 'LP-0005',
      tipeKonten: 'Chat Anonim',
      namaPelapor: 'Admin',
      namaTerlapor: 'UserXyz',
      avatarTerlapor: '',
      tanggal: DateTime(2026, 4, 9),
      status: LaporanStatus.pending,
      isiLaporan:
          'aku ngerasa hidup ini berat banget, semuanya jahat, enggak ada yang peduli sama aku...',
      catatanAdmin: '',
      imageUrls: const [],
    );
    _catatanController.text = _laporan.catatanAdmin;

    _catatanController.addListener(() {
      if (mounted) setState(() {});
    });
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

  Future<void> _ubahStatus(LaporanStatus status) async {
    if (_laporan.documentId.isEmpty) {
      _showMessage('Data laporan belum terhubung ke Firebase');
      return;
    }

    await _laporanService.updateStatusLaporan(
      documentId: _laporan.documentId,
      status: status,
      catatanAdmin: _catatanController.text.trim(),
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  String _statusLabel() {
    switch (_laporan.status) {
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

  Color _statusColor() {
    switch (_laporan.status) {
      case LaporanStatus.pending:
        return const Color(0xFFF7D783);
      case LaporanStatus.diproses:
        return const Color(0xFFDDF1D2);
      case LaporanStatus.selesai:
        return const Color(0xFFAEDB9A);
      case LaporanStatus.ditolak:
        return const Color(0xFFFFB9B9);
    }
  }

  Color _statusTextColor() {
    switch (_laporan.status) {
      case LaporanStatus.pending:
        return const Color(0xFF9A5606);
      case LaporanStatus.diproses:
        return const Color(0xFF49A828);
      case LaporanStatus.selesai:
        return const Color(0xFF20560A);
      case LaporanStatus.ditolak:
        return const Color(0xFFFF0000);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
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
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 18),
              _buildInformasiLaporanCard(),
              const SizedBox(height: 14),
              _buildKontenCard(),
              const SizedBox(height: 14),
              _buildAlasanCard(),
              const SizedBox(height: 14),
              _buildInformasiTambahanCard(),
              const SizedBox(height: 14),
              _buildCatatanAdminCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 14),
              _buildBackButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(
                Icons.arrow_back_rounded,
                size: 26,
                color: Color(0xFF0C0E0C),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Tinjau Laporan User',
                style: GoogleFonts.fredoka(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF486253),
                ),
              ),
            ),
            _buildStatusBadge(),
          ],
        ),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: Text(
            'Periksa laporan dan ambil tindakan yang sesuai',
            style: GoogleFonts.openSans(
              fontSize: 12,
              color: const Color(0xFF0C0E0C),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.only(left: 38),
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '#${_laporan.id}',
                  style: GoogleFonts.fredoka(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.black.withOpacity(0.85),
                  ),
                ),
                TextSpan(
                  text:
                      '  •  Dilaporkan ${_formatTanggal(_laporan.tanggal)}  •  14:32 WIB',
                  style: GoogleFonts.openSans(
                    fontSize: 12,
                    color: const Color(0xFF0C0E0C),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      width: 80,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _statusColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _statusLabel(),
        style: GoogleFonts.openSans(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _statusTextColor(),
        ),
      ),
    );
  }

  Widget _buildInformasiLaporanCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.person_search_outlined, 'Informasi Laporan'),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    _infoItem(
                      Icons.assignment_outlined,
                      'ID Laporan',
                      _laporan.id,
                    ),
                    const SizedBox(height: 18),
                    _infoItem(
                      Icons.chat_bubble_outline_rounded,
                      'Tipe Konten',
                      _laporan.tipeKonten,
                    ),
                    const SizedBox(height: 18),
                    _infoItem(
                      Icons.flag_outlined,
                      'Kategori Laporan',
                      'Kata-kata tidak pantas',
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 145,
                color: const Color(0xFFD9D9D9),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  children: [
                    _infoItem(
                      Icons.person_outline,
                      'Pelapor',
                      _laporan.namaPelapor,
                    ),
                    const SizedBox(height: 18),
                    _infoItem(
                      Icons.person_outline,
                      'Terlapor',
                      _laporan.namaTerlapor,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 22,
                          color: Color(0xFF2B8A4B),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Status',
                                style: GoogleFonts.openSans(fontSize: 11),
                              ),
                              const SizedBox(height: 5),
                              _buildStatusBadge(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKontenCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(
            Icons.chat_bubble_outline_rounded,
            'Konten yang Dilaporkan',
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB9B9)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_laporan.isiLaporan.trim().isNotEmpty)
                  Text(
                    '“${_laporan.isiLaporan}”',
                    style: GoogleFonts.openSans(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w700,
                      height: 1.6,
                      color: const Color(0xFF0C0E0C),
                    ),
                  ),
                if (_laporan.imageUrls.isNotEmpty) ...[
                  if (_laporan.isiLaporan.trim().isNotEmpty)
                    const SizedBox(height: 12),
                  ..._laporan.imageUrls.map(
                    (url) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          url,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;

                            return Container(
                              width: double.infinity,
                              height: 180,
                              alignment: Alignment.center,
                              color: const Color(0xFFFFEAEA),
                              child: Text(
                                'Memuat gambar...',
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  color: const Color(0xFF6B6B6B),
                                ),
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: double.infinity,
                              height: 120,
                              alignment: Alignment.center,
                              color: const Color(0xFFFFEAEA),
                              child: Text(
                                'Gambar gagal dimuat',
                                style: GoogleFonts.openSans(
                                  fontSize: 11,
                                  color: const Color(0xFFFF0000),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlasanCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.flag_outlined, 'Alasan Laporan'),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF1F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFFFB9B9)),
            ),
            child: Text(
              'Konten ini mengandung kata-kata kasar dan membuat tidak nyaman. Mohon untuk ditindaklanjuti.',
              style: GoogleFonts.openSans(fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInformasiTambahanCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.calendar_month_outlined, 'Informasi Tambahan'),
          const SizedBox(height: 12),
          _tableRow(
            'Dilaporkan Pada',
            '${_formatTanggal(_laporan.tanggal)} • 14:32 WIB',
          ),
          _tableRow('Dilaporkan Melalui', 'Aplikasi Moodly'),
          _tableRow('Catatan Pelapor', 'Tolong dicek, terima kasih.'),
          if (_laporan.catatanAdmin.isNotEmpty)
            _tableRow('Catatan Admin Lama', _laporan.catatanAdmin),
        ],
      ),
    );
  }

  Widget _buildCatatanAdminCard() {
    return _whiteCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.note_alt_outlined, 'Catatan Admin (Opsional)'),
          const SizedBox(height: 14),
          Container(
            height: 105,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFD9D9D9)),
            ),
            child: TextField(
              controller: _catatanController,
              maxLength: 500,
              maxLines: 4,
              decoration: InputDecoration(
                counterText: '',
                border: InputBorder.none,
                hintText: 'Tulis catatan atau pertimbangan laporan...',
                hintStyle: GoogleFonts.openSans(
                  fontSize: 11,
                  color: const Color(0xFF8A8A8A),
                ),
              ),
              style: GoogleFonts.openSans(fontSize: 11),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_catatanController.text.length}/500',
              style: GoogleFonts.openSans(
                fontSize: 10,
                color: const Color(0xFF6B6B6B),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.access_time_rounded,
                title: 'Tandai Diproses',
                subtitle: 'Laporan sedang diproses',
                color: const Color(0xFF1C8C4A),
                bg: const Color(0xFFEFFFF0),
                border: const Color(0xFF8ECD86),
                onTap: () => _ubahStatus(LaporanStatus.diproses),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _actionButton(
                icon: Icons.check_circle_outline_rounded,
                title: 'Selesaikan Laporan',
                subtitle: 'Tandai laporan selesai',
                color: const Color(0xFF1C8C4A),
                bg: const Color(0xFFEFFFF0),
                border: const Color(0xFF8ECD86),
                onTap: () => _ubahStatus(LaporanStatus.selesai),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _actionButton(
          icon: Icons.shield_outlined,
          title: 'Tolak Laporan',
          subtitle: 'Laporan tidak valid',
          color: const Color(0xFFFF3B3B),
          bg: const Color(0xFFFFF1F1),
          border: const Color(0xFFFF8A8A),
          onTap: () => _ubahStatus(LaporanStatus.ditolak),
        ),
      ],
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        width: double.infinity,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFEFEFEF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFD0D0D0)),
        ),
        child: Text(
          '←   Kembali ke Daftar Laporan',
          style: GoogleFonts.fredoka(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF6B6B6B),
          ),
        ),
      ),
    );
  }

  Widget _whiteCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _sectionTitle(IconData icon, String title) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF2B8A4B)),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.fredoka(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: const Color(0xFF2B8A4B)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: GoogleFonts.openSans(fontSize: 11)),
              Text(
                value,
                style: GoogleFonts.openSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tableRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 130,
            child: Text(label, style: GoogleFonts.openSans(fontSize: 11)),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.openSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required Color border,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 70,
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border),
        ),
        child: Row(
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.fredoka(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.openSans(
                      fontSize: 9,
                      color: const Color(0xFF333333),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}