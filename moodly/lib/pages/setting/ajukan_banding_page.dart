import 'package:flutter/material.dart';
import '../../core/services/user_appeal_service.dart';

const Color _appealBg = Color(0xFFF4F8EA);
const Color _appealCard = Colors.white;
const Color _appealGreen = Color(0xFF7BC25D);
const Color _appealGreenDark = Color(0xFF5E9E49);
const Color _appealGreenSoft = Color(0xFFDDEFCF);
const Color _appealMintSoft = Color(0xFFE9F7E8);
const Color _appealPinkSoft = Color(0xFFFFEEF2);
const Color _appealTextDark = Color(0xFF1F1F1F);
const Color _appealTextSoft = Color(0xFF6F746E);
const Color _appealBrand = Color(0xFFC65F59);

List<BoxShadow> get _appealShadow => const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 8),
        blurRadius: 20,
        spreadRadius: 0,
      ),
    ];

TextStyle? _ah1(BuildContext context, {Color color = _appealTextDark}) {
  return Theme.of(context).textTheme.headlineLarge?.copyWith(color: color);
}

TextStyle? _ah2(BuildContext context, {Color color = _appealTextDark}) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(color: color);
}

TextStyle? _abody(BuildContext context, {Color color = _appealTextSoft}) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(color: color);
}

TextStyle? _abodyAlt(BuildContext context, {Color color = _appealTextDark}) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(color: color);
}

TextStyle? _abutton(BuildContext context, {Color color = Colors.white}) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(color: color);
}

class AjukanBandingPage extends StatefulWidget {
  final Map<String, dynamic> report;

  const AjukanBandingPage({
    super.key,
    required this.report,
  });

  @override
  State<AjukanBandingPage> createState() => _AjukanBandingPageState();
}

class _AjukanBandingPageState extends State<AjukanBandingPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDate(dynamic value) {
    if (value == null) return '-';

    DateTime date;
    if (value.runtimeType.toString() == 'Timestamp') {
      date = value.toDate();
    } else if (value is DateTime) {
      date = value;
    } else if (value is String) {
      date = DateTime.tryParse(value) ?? DateTime(2000);
    } else {
      return '-';
    }

    const months = [
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

    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _submit() async {
    final alasan = _controller.text.trim();

    if (alasan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Alasan banding belum diisi.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      await UserAppealService.instance.submitAppeal(
        documentId: widget.report['documentId'].toString(),
        alasanBanding: alasan,
        tindakanSaatIni: (widget.report['tindakanDipilih'] ??
                widget.report['tindakanSaatIni'] ??
                '')
            .toString(),
        reportSnapshot: widget.report,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Banding berhasil dikirim.')),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengirim banding: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _appealPinkSoft.withOpacity(0.7),
            ),
          ),
        ),
        Positioned(
          top: 250,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _appealMintSoft.withOpacity(0.85),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final sourceLabel = UserAppealService.instance.buildReportSourceLabel(widget.report);
    final categoryLabel = UserAppealService.instance.buildReportCategoryLabel(widget.report);
    final reportStatus =
        UserAppealService.instance.buildReportStatusLabel(widget.report);
    final reporterName =
        UserAppealService.instance.buildReporterName(widget.report);
    final currentAction =
        UserAppealService.instance.buildCurrentActionLabel(widget.report);
    final decisionLabel =
        UserAppealService.instance.buildAdminDecisionLabel(widget.report);
    final decisionDescription =
        UserAppealService.instance.buildAdminDecisionDescription(widget.report);
    final evidenceText =
        UserAppealService.instance.buildEvidencePreviewText(widget.report);
    final evidenceImageUrl =
        UserAppealService.instance.buildEvidenceImageUrl(widget.report);
    final isImageReport =
        UserAppealService.instance.isImageReport(widget.report);
    final adminNote = (widget.report['catatanAdmin'] ??
            widget.report['alasanTindakan'] ??
            '')
        .toString()
        .trim();

    return Scaffold(
      backgroundColor: _appealBg,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: _appealGreenDark,
                          size: 26,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Ajukan Banding',
                        style: _ah2(context, color: _appealGreenDark),
                      ),
                      const Spacer(),
                      Text(
                        'Moodly',
                        style: _ah1(context, color: _appealBrand),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _appealCard,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _appealShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kamu telah dilaporkan',
                          style: _ah2(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Terdapat seseorang yang melaporkanmu.',
                          style: _abody(context),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          sourceLabel,
                          style: _ah2(context)?.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _appealPinkSoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                currentAction,
                                style: _abodyAlt(context)?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: _appealGreenSoft,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                reportStatus,
                                style: _abodyAlt(context)?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Kategori: $categoryLabel',
                          style: _abody(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pelapor: $reporterName',
                          style: _abody(context),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tanggal laporan: ${_formatDate(widget.report['createdAt'])}',
                          style: _abody(context),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _appealCard,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _appealShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _appealCard,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: _appealShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isImageReport ? 'Gambar yang dilaporkan' : 'Cuplikan chat yang dilaporkan',
                                style: _ah2(context),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isImageReport
                                    ? 'Berikut gambar yang menjadi dasar laporan.'
                                    : 'Berikut cuplikan percakapan yang menjadi dasar laporan.',
                                style: _abody(context),
                              ),
                              const SizedBox(height: 12),

                              if (isImageReport && evidenceImageUrl.isNotEmpty)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: InteractiveViewer(
                                      minScale: 1,
                                      maxScale: 4,
                                      child: Image.network(
                                        evidenceImageUrl,
                                        fit: BoxFit.cover,
                                        loadingBuilder: (context, child, progress) {
                                          if (progress == null) return child;
                                          return Container(
                                            color: _appealGreenSoft.withOpacity(0.25),
                                            child: const Center(
                                              child: CircularProgressIndicator(),
                                            ),
                                          );
                                        },
                                        errorBuilder: (_, __, ___) {
                                          return Container(
                                            color: _appealGreenSoft.withOpacity(0.25),
                                            alignment: Alignment.center,
                                            padding: const EdgeInsets.all(16),
                                            child: Text(
                                              'Gambar tidak bisa dimuat.',
                                              textAlign: TextAlign.center,
                                              style: _abodyAlt(context),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                )
                              else
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _appealGreenSoft.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    evidenceText,
                                    style: _abodyAlt(context)?.copyWith(height: 1.5),
                                  ),
                                ),

                              if (evidenceText.isNotEmpty) ...[
                                if (isImageReport) const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: _appealGreenSoft.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    evidenceText,
                                    style: _abodyAlt(context)?.copyWith(height: 1.5),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: _appealCard,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: _appealShadow,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Keputusan admin',
                                style: _ah2(context),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _appealPinkSoft,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  decisionLabel,
                                  style: _abodyAlt(context)?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                decisionDescription,
                                style: _abodyAlt(context)?.copyWith(height: 1.5),
                              ),
                              if (adminNote.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _appealGreenSoft.withOpacity(0.45),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    'Catatan admin: $adminNote',
                                    style: _abodyAlt(context)?.copyWith(height: 1.45),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        Text(
                          'Kenapa kamu ingin mengajukan banding?',
                          style: _ah2(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Jelaskan versimu dengan singkat, jelas, dan tetap sopan.',
                          style: _abody(context),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _controller,
                          maxLines: 8,
                          style: _abodyAlt(context),
                          decoration: InputDecoration(
                            hintText:
                                'Contoh: konteks percakapan saya tidak seperti yang dipahami pelapor, dan saya ingin admin meninjau ulang bukti percakapan ini.',
                            hintStyle: _abody(context),
                            filled: true,
                            fillColor: _appealGreenSoft.withOpacity(0.45),
                            contentPadding: const EdgeInsets.all(16),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _appealGreen,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: Text(
                        _isSubmitting ? 'Mengirim...' : 'Kirim Banding',
                        style: _abutton(context),
                      ),
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
}