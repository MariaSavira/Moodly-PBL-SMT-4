import 'package:flutter/material.dart';

import '../../core/services/user_appeal_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'moodly_settings_support.dart';

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
  bool _isLoadingPrefs = true;
  String _languageCode = 'id';

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Ajukan Banding',
      'reportedTitle': 'Kamu telah dilaporkan',
      'reportedBody': 'Seseorang melaporkan akun atau kontenmu. Kalau memang mau banding, jelaskan dengan masuk akal.',
      'source': 'Sumber',
      'category': 'Kategori',
      'status': 'Status laporan',
      'reporter': 'Pelapor',
      'date': 'Tanggal',
      'action': 'Tindakan saat ini',
      'decision': 'Keputusan admin',
      'evidence': 'Bukti / ringkasan',
      'note': 'Catatan admin',
      'reason': 'Alasan banding',
      'reasonHint': 'Jelaskan kenapa laporan ini perlu ditinjau ulang',
      'submit': 'Kirim Banding',
      'emptyReason': 'Alasan banding belum diisi.',
      'success': 'Banding berhasil dikirim.',
      'failed': 'Gagal mengirim banding',
      'imageAttached': 'Bukti gambar tersedia.',
      'noAdminNote': 'Tidak ada catatan admin.',
    },
    'en': {
      'header': 'Submit Appeal',
      'reportedTitle': 'You have been reported',
      'reportedBody': 'Someone reported your account or content. If you want to appeal, explain it properly instead of vaguely hoping for mercy.',
      'source': 'Source',
      'category': 'Category',
      'status': 'Report status',
      'reporter': 'Reporter',
      'date': 'Date',
      'action': 'Current action',
      'decision': 'Admin decision',
      'evidence': 'Evidence / summary',
      'note': 'Admin note',
      'reason': 'Appeal reason',
      'reasonHint': 'Explain why this report should be reviewed again',
      'submit': 'Send Appeal',
      'emptyReason': 'Appeal reason is still empty.',
      'success': 'Appeal submitted successfully.',
      'failed': 'Failed to submit appeal',
      'imageAttached': 'Image evidence is available.',
      'noAdminNote': 'There is no admin note.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _loadPrefs();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

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
    const monthsId = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const monthsEn = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = _languageCode == 'en' ? monthsEn : monthsId;
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  Future<void> _submit() async {
    final reason = _controller.text.trim();
    if (reason.isEmpty) {
      showCuteTopPopup(
        context,
        title: _t('header'),
        message: _t('emptyReason'),
        type: CutePopupType.warning,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      await UserAppealService.instance.submitAppeal(
        documentId: widget.report['documentId'].toString(),
        alasanBanding: reason,
        tindakanSaatIni: (widget.report['tindakanDipilih'] ?? widget.report['tindakanSaatIni'] ?? '').toString(),
        reportSnapshot: widget.report,
      );

      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('header'),
        message: _t('success'),
        type: CutePopupType.success,
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('header'),
        message: '${_t('failed')}: $e',
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final sourceLabel = UserAppealService.instance.buildReportSourceLabel(widget.report);
    final categoryLabel = UserAppealService.instance.buildReportCategoryLabel(widget.report);
    final reportStatus = UserAppealService.instance.buildReportStatusLabel(widget.report);
    final reporterName = UserAppealService.instance.buildReporterName(widget.report);
    final currentAction = UserAppealService.instance.buildCurrentActionLabel(widget.report);
    final decisionLabel = UserAppealService.instance.buildAdminDecisionLabel(widget.report);
    final decisionDescription = UserAppealService.instance.buildAdminDecisionDescription(widget.report);
    final evidenceText = UserAppealService.instance.buildEvidencePreviewText(widget.report);
    final evidenceImageUrl = UserAppealService.instance.buildEvidenceImageUrl(widget.report);
    final isImageReport = UserAppealService.instance.isImageReport(widget.report);
    final adminNote = (widget.report['catatanAdmin'] ?? widget.report['alasanTindakan'] ?? '').toString().trim();

    if (_isLoadingPrefs) {
      return Scaffold(backgroundColor: palette.bg, body: const Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 430 ? 430 : MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodlySettingsHeader(
                        palette: palette,
                        title: _t('header'),
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 22),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('reportedTitle'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('reportedBody'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          children: [
                            _InfoRow(label: _t('source'), value: sourceLabel, palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('category'), value: categoryLabel, palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('status'), value: reportStatus, palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('reporter'), value: reporterName, palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('action'), value: currentAction, palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('decision'), value: '$decisionLabel${decisionDescription.isNotEmpty ? ' • $decisionDescription' : ''}', palette: palette),
                            const SizedBox(height: 12),
                            _InfoRow(label: _t('date'), value: _formatDate(widget.report['createdAt']), palette: palette),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('evidence'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              evidenceText,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.45),
                            ),
                            if (isImageReport && evidenceImageUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: Image.network(
                                  evidenceImageUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: palette.mintSoft,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Text(
                                      _t('imageAttached'),
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('note'),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              adminNote.isEmpty ? _t('noAdminNote') : adminNote,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            MoodlySettingsInput(
                              palette: palette,
                              controller: _controller,
                              label: _t('reason'),
                              hint: _t('reasonHint'),
                              icon: Icons.edit_note_rounded,
                              maxLines: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      MoodlyPrimaryButton(
                        palette: palette,
                        label: _t('submit'),
                        isLoading: _isSubmitting,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final MoodlySettingsPalette palette;

  const _InfoRow({required this.label, required this.value, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textDark),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.4),
          ),
        ),
      ],
    );
  }
}
