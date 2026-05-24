import 'package:flutter/material.dart';

import '../../core/services/user_appeal_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import 'moodly_settings_support.dart';

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  bool _isLoading = true;
  String _selectedTab = 'all';
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  List<Map<String, dynamic>> _reportsAgainstMe = [];
  List<Map<String, dynamic>> _reportsByMe = [];
  List<Map<String, dynamic>> _appeals = [];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Laporan & Banding',
      'description': 'Lihat laporan terhadap akunmu, laporan yang kamu kirim, dan status banding yang pernah diajukan.',
      'all': 'Semua',
      'pending': 'Pending',
      'approved': 'Disetujui',
      'rejected': 'Ditolak',
      'againstMe': 'Laporan terhadap akunmu',
      'byMe': 'Laporan yang kamu kirim',
      'appeals': 'Banding yang kamu ajukan',
      'emptyAgainst': 'Belum ada laporan terhadap akunmu pada filter ini.',
      'emptyByMe': 'Belum ada laporan yang kamu kirim pada filter ini.',
      'emptyAppeals': 'Belum ada banding yang sesuai dengan filter ini.',
      'applyAppeal': 'Ajukan Banding',
      'status': 'Status',
      'category': 'Kategori',
      'reporter': 'Pelapor',
      'content': 'Isi laporan',
      'date': 'Tanggal',
      'appealReason': 'Alasan banding',
      'loadPartial': 'Sebagian riwayat gagal dimuat. Data yang berhasil masih tetap ditampilkan.',
    },
    'en': {
      'header': 'Reports & Appeals',
      'description': 'Review reports against your account, reports you submitted, and appeal statuses that exist in your account history.',
      'all': 'All',
      'pending': 'Pending',
      'approved': 'Approved',
      'rejected': 'Rejected',
      'againstMe': 'Reports against your account',
      'byMe': 'Reports you submitted',
      'appeals': 'Appeals you submitted',
      'emptyAgainst': 'No reports against your account for this filter.',
      'emptyByMe': 'No reports you submitted for this filter.',
      'emptyAppeals': 'No appeals match this filter.',
      'applyAppeal': 'Submit Appeal',
      'status': 'Status',
      'category': 'Category',
      'reporter': 'Reporter',
      'content': 'Report content',
      'date': 'Date',
      'appealReason': 'Appeal reason',
      'loadPartial': 'Part of the history failed to load. Whatever succeeded is still shown.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  Future<List<Map<String, dynamic>>> _safeLoad(
    Future<List<Map<String, dynamic>>> Function() loader,
  ) async {
    try {
      return await loader();
    } catch (e) {
      debugPrint('ReportHistory load error: $e');
      return <Map<String, dynamic>>[];
    }
  }

  Future<void> _loadAll() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();

    final reportsAgainstMe = await _safeLoad(
      () => UserAppealService.instance.getReportsAgainstMe(),
    );
    final reportsByMe = await _safeLoad(
      () => UserAppealService.instance.getReportsSubmittedByMe(),
    );
    final appeals = await _safeLoad(
      () => UserAppealService.instance.getAppealsAgainstMe(),
    );

    if (!mounted) return;

    final hadError = reportsAgainstMe.isEmpty && reportsByMe.isEmpty && appeals.isEmpty;
    setState(() {
      _languageCode = language;
      _reportsAgainstMe = reportsAgainstMe;
      _reportsByMe = reportsByMe;
      _appeals = appeals;
      _isLoading = false;
    });

    if (hadError) {
      showCuteTopPopup(
        context,
        title: 'Oops',
        message: _t('loadPartial'),
        type: CutePopupType.error,
      );
    }
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

    const monthsId = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
    const monthsEn = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final months = _languageCode == 'en' ? monthsEn : monthsId;
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _normalizeStatus(String raw) {
    final value = raw.trim().toLowerCase();
    if (value.contains('selesai') || value.contains('disetujui') || value.contains('approved')) return 'approved';
    if (value.contains('ditolak') || value.contains('rejected')) return 'rejected';
    if (value.contains('pending') || value.contains('diproses') || value.contains('process')) return 'pending';
    return 'all';
  }

  String _localizeStatus(String raw) {
    switch (_normalizeStatus(raw)) {
      case 'approved':
        return _t('approved');
      case 'rejected':
        return _t('rejected');
      case 'pending':
        return _t('pending');
      default:
        return raw.isEmpty ? '-' : raw;
    }
  }

  bool _matchTab(String raw) {
    if (_selectedTab == 'all') return true;
    return _normalizeStatus(raw) == _selectedTab;
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final filteredAgainst = _reportsAgainstMe.where((item) => _matchTab((item['status'] ?? '').toString())).toList();
    final filteredByMe = _reportsByMe.where((item) => _matchTab((item['status'] ?? '').toString())).toList();
    final filteredAppeals = _appeals.where((item) => _matchTab((item['statusBanding'] ?? '').toString())).toList();

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
                        child: Text(
                          _t('description'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: palette.textSoft,
                                height: 1.45,
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        padding: const EdgeInsets.all(7),
                        child: Row(
                          children: [
                            _TabChip(palette: palette, label: _t('all'), selected: _selectedTab == 'all', onTap: () => setState(() => _selectedTab = 'all')),
                            _TabChip(palette: palette, label: _t('pending'), selected: _selectedTab == 'pending', onTap: () => setState(() => _selectedTab = 'pending')),
                            _TabChip(palette: palette, label: _t('approved'), selected: _selectedTab == 'approved', onTap: () => setState(() => _selectedTab = 'approved')),
                            _TabChip(palette: palette, label: _t('rejected'), selected: _selectedTab == 'rejected', onTap: () => setState(() => _selectedTab = 'rejected')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        palette: palette,
                        title: _t('againstMe'),
                        isLoading: _isLoading,
                        emptyText: _t('emptyAgainst'),
                        children: filteredAgainst.map((item) {
                          final source = UserAppealService.instance.buildReportSourceLabel(item);
                          final content = UserAppealService.instance.buildReportContentLabel(item);
                          final category = UserAppealService.instance.buildReportCategoryLabel(item);
                          final reporter = UserAppealService.instance.buildReporterName(item);
                          final status = UserAppealService.instance.buildReportStatusLabel(item);

                          return _HistoryCard(
                            palette: palette,
                            title: source,
                            lines: [
                              '${_t('content')}: $content',
                              '${_t('category')}: $category',
                              '${_t('reporter')}: $reporter',
                              '${_t('status')}: ${_localizeStatus(status)}',
                              '${_t('date')}: ${_formatDate(item['createdAt'])}',
                            ],
                            actionLabel: UserAppealService.instance.canSubmitAppeal(item) ? _t('applyAppeal') : null,
                            onActionTap: UserAppealService.instance.canSubmitAppeal(item)
                                ? () async {
                                    final changed = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AjukanBandingPage(report: item),
                                      ),
                                    );
                                    if (changed == true) {
                                      _loadAll();
                                    }
                                  }
                                : null,
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        palette: palette,
                        title: _t('byMe'),
                        isLoading: _isLoading,
                        emptyText: _t('emptyByMe'),
                        children: filteredByMe.map((item) {
                          final source = UserAppealService.instance.buildReportSourceLabel(item);
                          final content = UserAppealService.instance.buildReportContentLabel(item);
                          final category = UserAppealService.instance.buildReportCategoryLabel(item);
                          final status = UserAppealService.instance.buildReportStatusLabel(item);
                          return _HistoryCard(
                            palette: palette,
                            title: source,
                            lines: [
                              '${_t('content')}: $content',
                              '${_t('category')}: $category',
                              '${_t('status')}: ${_localizeStatus(status)}',
                              '${_t('date')}: ${_formatDate(item['createdAt'])}',
                            ],
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      _Section(
                        palette: palette,
                        title: _t('appeals'),
                        isLoading: _isLoading,
                        emptyText: _t('emptyAppeals'),
                        children: filteredAppeals.map((item) {
                          final source = UserAppealService.instance.buildReportSourceLabel(item);
                          final content = UserAppealService.instance.buildReportContentLabel(item);
                          final category = UserAppealService.instance.buildReportCategoryLabel(item);
                          final status = (item['statusBanding'] ?? '').toString();
                          final appealReason = (item['alasanBanding'] ?? '').toString().trim();
                          return _HistoryCard(
                            palette: palette,
                            title: source,
                            lines: [
                              '${_t('content')}: $content',
                              '${_t('category')}: $category',
                              if (appealReason.isNotEmpty) '${_t('appealReason')}: $appealReason',
                              '${_t('status')}: ${_localizeStatus(status)}',
                              '${_t('date')}: ${_formatDate(item['createdAt'] ?? item['appealCreatedAt'])}',
                            ],
                          );
                        }).toList(),
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

class _TabChip extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabChip({
    required this.palette,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? palette.greenSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: selected ? palette.greenDark : palette.textSoft,
                ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String title;
  final bool isLoading;
  final String emptyText;
  final List<Widget> children;

  const _Section({
    required this.palette,
    required this.title,
    required this.isLoading,
    required this.emptyText,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoodlySectionTitle(palette: palette, title: title),
        const SizedBox(height: 12),
        if (isLoading)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator(color: palette.greenDark)),
          )
        else if (children.isEmpty)
          MoodlySettingsCard(
            palette: palette,
            child: Text(
              emptyText,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft),
            ),
          )
        else
          Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i < children.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
      ],
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String title;
  final List<String> lines;
  final String? actionLabel;
  final VoidCallback? onActionTap;

  const _HistoryCard({
    required this.palette,
    required this.title,
    required this.lines,
    this.actionLabel,
    this.onActionTap,
  });

  @override
  Widget build(BuildContext context) {
    return MoodlySettingsCard(
      palette: palette,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.textDark),
          ),
          const SizedBox(height: 10),
          for (final line in lines) ...[
            Text(
              line,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: palette.textSoft,
                    height: 1.45,
                  ),
            ),
            const SizedBox(height: 6),
          ],
          if (actionLabel != null && onActionTap != null) ...[
            const SizedBox(height: 8),
            MoodlyPrimaryButton(
              palette: palette,
              label: actionLabel!,
              onPressed: onActionTap,
            ),
          ],
        ],
      ),
    );
  }
}
