import 'package:flutter/material.dart';
import '../../core/services/user_appeal_service.dart';
import '../pages.dart';

const Color _historyBg = Color(0xFFF4F8EA);
const Color _historyCard = Colors.white;
const Color _historyGreen = Color(0xFF7BC25D);
const Color _historyGreenDark = Color(0xFF5E9E49);
const Color _historyGreenSoft = Color(0xFFDDEFCF);
const Color _historyMintSoft = Color(0xFFE9F7E8);
const Color _historyPinkSoft = Color(0xFFFFEEF2);
const Color _historyPeachSoft = Color(0xFFFFE9DD);
const Color _historyYellowSoft = Color(0xFFF9F0CC);
const Color _historyTextDark = Color(0xFF1F1F1F);
const Color _historyTextSoft = Color(0xFF6F746E);
const Color _historyBrand = Color(0xFFC65F59);

List<BoxShadow> get _historyShadow => const [
  BoxShadow(
    color: Color.fromRGBO(0, 0, 0, 0.08),
    offset: Offset(0, 8),
    blurRadius: 20,
    spreadRadius: 0,
  ),
];

TextStyle? _hh1(BuildContext context, {Color color = _historyTextDark}) {
  return Theme.of(context).textTheme.headlineLarge?.copyWith(color: color);
}

TextStyle? _hh2(BuildContext context, {Color color = _historyTextDark}) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(color: color);
}

TextStyle? _hbody(BuildContext context, {Color color = _historyTextSoft}) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(color: color);
}

TextStyle? _hbodyAlt(BuildContext context, {Color color = _historyTextDark}) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(color: color);
}

TextStyle? _hbutton(BuildContext context, {Color color = Colors.white}) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(color: color);
}

class ReportHistoryPage extends StatefulWidget {
  const ReportHistoryPage({super.key});

  @override
  State<ReportHistoryPage> createState() => _ReportHistoryPageState();
}

class _ReportHistoryPageState extends State<ReportHistoryPage> {
  bool _isLoading = true;
  String selectedTab = 'Semua';

  List<Map<String, dynamic>> _reportsAgainstMe = [];
  List<Map<String, dynamic>> _reportsByMe = [];
  List<Map<String, dynamic>> _appeals = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final reportsAgainstMe =
          await UserAppealService.instance.getReportsAgainstMe();
      final reportsByMe =
          await UserAppealService.instance.getReportsSubmittedByMe();
      final appeals =
          await UserAppealService.instance.getAppealsAgainstMe();

      if (!mounted) return;

      setState(() {
        _reportsAgainstMe = reportsAgainstMe;
        _reportsByMe = reportsByMe;
        _appeals = appeals;
      });
    } catch (e) {
      debugPrint('Gagal load report history: $e');

      if (!mounted) return;

      setState(() {
        _reportsAgainstMe = [];
        _reportsByMe = [];
        _appeals = [];
      });
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(dynamic value) {
    DateTime date;

    if (value == null) return '-';
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

  bool _matchReportTab(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().trim().toLowerCase();

    switch (selectedTab) {
      case 'Pending':
        return status == 'pending' || status == 'diproses';
      case 'Disetujui':
        return status == 'selesai';
      case 'Ditolak':
        return status == 'ditolak';
      default:
        return true;
    }
  }

  bool _matchAppealTab(Map<String, dynamic> item) {
    final status = (item['statusBanding'] ?? '')
        .toString()
        .trim()
        .toLowerCase();

    switch (selectedTab) {
      case 'Pending':
        return status == 'pending';
      case 'Disetujui':
        return status == 'disetujui';
      case 'Ditolak':
        return status == 'ditolak';
      default:
        return true;
    }
  }

  Color _reportStatusBg(String label) {
    switch (label) {
      case 'Pending':
        return _historyYellowSoft;
      case 'Diproses':
        return _historyYellowSoft;
      case 'Selesai':
        return _historyMintSoft;
      case 'Ditolak':
        return _historyPinkSoft;
      default:
        return _historyGreenSoft;
    }
  }

  Color _appealStatusBg(String label) {
    switch (label) {
      case 'Pending':
        return _historyYellowSoft;
      case 'Disetujui':
        return _historyMintSoft;
      case 'Ditolak':
        return _historyPinkSoft;
      default:
        return _historyGreenSoft;
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
              color: _historyPinkSoft.withOpacity(0.7),
            ),
          ),
        ),
        Positioned(
          top: 240,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _historyMintSoft.withOpacity(0.85),
            ),
          ),
        ),
        Positioned(
          bottom: 70,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _historyGreenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredReportsAgainstMe =
        _reportsAgainstMe.where(_matchReportTab).toList();

    final filteredReportsByMe =
        _reportsByMe.where(_matchReportTab).toList();

    final filteredAppeals = _appeals.where(_matchAppealTab).toList();

    return Scaffold(
      backgroundColor: _historyBg,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HistoryHeader(onBack: () => Navigator.pop(context)),
                  const SizedBox(height: 22),
                  Text(
                    'Lihat laporan terhadap akunmu dan status banding yang pernah kamu ajukan.',
                    style: _hh2(
                      context,
                    )?.copyWith(height: 1.45, color: _historyTextDark),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: _historyShadow,
                    ),
                    child: Row(
                      children: [
                        _HistoryTab(
                          label: 'Semua',
                          selected: selectedTab == 'Semua',
                          onTap: () => setState(() => selectedTab = 'Semua'),
                        ),
                        _HistoryTab(
                          label: 'Pending',
                          selected: selectedTab == 'Pending',
                          onTap: () => setState(() => selectedTab = 'Pending'),
                        ),
                        _HistoryTab(
                          label: 'Disetujui',
                          selected: selectedTab == 'Disetujui',
                          onTap: () =>
                              setState(() => selectedTab = 'Disetujui'),
                        ),
                        _HistoryTab(
                          label: 'Ditolak',
                          selected: selectedTab == 'Ditolak',
                          onTap: () => setState(() => selectedTab = 'Ditolak'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  Text(
                    'Laporan terhadap akunmu',
                    style: _hh1(context)?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (filteredReportsAgainstMe.isEmpty)
                    _EmptySectionCard(
                      text:
                          'Belum ada laporan terhadap akunmu pada filter ini.',
                    )
                  else
                    ...filteredReportsAgainstMe.map((item) {
                      final sourceLabel = UserAppealService.instance.buildReportSourceLabel(item);
                      final contentLabel = UserAppealService.instance.buildReportContentLabel(item);
                      final categoryLabel = UserAppealService.instance.buildReportCategoryLabel(item);
                      final reporter = UserAppealService.instance.buildReporterName(item);
                      final reportStatus = UserAppealService.instance.buildReportStatusLabel(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _historyCard,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _historyShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Kamu telah dilaporkan', style: _hh2(context)),
                            const SizedBox(height: 6),
                            Text(
                              'Terdapat seseorang yang melaporkanmu.',
                              style: _hbody(context),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              sourceLabel,
                              style: _hh2(context)?.copyWith(fontSize: 20),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Isi laporan: $contentLabel',
                              style: _hbodyAlt(context)?.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Kategori: $categoryLabel',
                              style: _hbody(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pelapor: $reporter',
                              style: _hbody(context),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: _reportStatusBg(reportStatus),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    reportStatus,
                                    style: _hbodyAlt(context)?.copyWith(fontWeight: FontWeight.w800),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(item['createdAt']),
                                  style: _hbody(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            if (UserAppealService.instance.canSubmitAppeal(item))
                              SizedBox(
                                width: double.infinity,
                                height: 48,
                                child: ElevatedButton(
                                  onPressed: () async {
                                    final changed = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AjukanBandingPage(report: item),
                                      ),
                                    );

                                    if (changed == true) {
                                      _loadData();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _historyGreen,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                  child: Text(
                                    'Ajukan Banding',
                                    style: _hbutton(context),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 8),

                  Text(
                    'Laporan yang kamu kirim',
                    style: _hh1(context)?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const SizedBox.shrink()
                  else if (filteredReportsByMe.isEmpty)
                    _EmptySectionCard(
                      text: 'Belum ada laporan yang kamu kirim pada filter ini.',
                    )
                  else
                    ...filteredReportsByMe.map((item) {
                      final sourceLabel = UserAppealService.instance.buildReportSourceLabel(item);
                      final contentLabel = UserAppealService.instance.buildReportContentLabel(item);
                      final categoryLabel = UserAppealService.instance.buildReportCategoryLabel(item);
                      final reportStatus =
                          UserAppealService.instance.buildReportStatusLabel(item);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: _historyCard,
                          borderRadius: BorderRadius.circular(26),
                          boxShadow: _historyShadow,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              sourceLabel,
                              style: _hh2(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              contentLabel,
                              style: _hbodyAlt(context)?.copyWith(height: 1.5),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Kategori: $categoryLabel',
                              style: _hbody(context),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _reportStatusBg(reportStatus),
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    reportStatus,
                                    style: _hbodyAlt(context)?.copyWith(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  _formatDate(item['createdAt']),
                                  style: _hbody(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }),
                  const SizedBox(height: 8),

                  Text(
                    'Banding yang kamu ajukan',
                    style: _hh1(context)?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 12),

                  if (_isLoading)
                    const SizedBox.shrink()
                  else if (filteredAppeals.isEmpty)
                    _EmptySectionCard(
                      text: 'Belum ada banding yang sesuai dengan filter ini.',
                    )
                  else
                  ...filteredReportsByMe.map((item) {
                    final sourceLabel =
                        UserAppealService.instance.buildReportSourceLabel(item);
                    final contentLabel =
                        UserAppealService.instance.buildReportContentLabel(item);
                    final categoryLabel =
                        UserAppealService.instance.buildReportCategoryLabel(item);
                    final reportStatus =
                        UserAppealService.instance.buildReportStatusLabel(item);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 14),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: _historyCard,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: _historyShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            sourceLabel,
                            style: _hh2(context),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            contentLabel,
                            style: _hbodyAlt(context)?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Kategori: $categoryLabel',
                            style: _hbody(context),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: _reportStatusBg(reportStatus),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  reportStatus,
                                  style: _hbodyAlt(context)?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                _formatDate(item['createdAt']),
                                style: _hbody(context),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _HistoryHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: _historyGreenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Laporan & Banding',
          style: _hh2(context, color: _historyGreenDark),
        ),
        const Spacer(),
        Text('Moodly', style: _hh1(context, color: _historyBrand)),
      ],
    );
  }
}

class _HistoryTab extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _HistoryTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: selected ? _historyGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: _hbodyAlt(
              context,
              color: selected ? Colors.white : _historyTextDark,
            )?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
    );
  }
}

class _EmptySectionCard extends StatelessWidget {
  final String text;

  const _EmptySectionCard({required this.text});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _historyCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _historyShadow,
      ),
      child: Text(text, style: _hbodyAlt(context)?.copyWith(height: 1.45)),
    );
  }
}
