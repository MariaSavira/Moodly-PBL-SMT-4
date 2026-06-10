import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/streak_service.dart';
import '../../core/services/premium_service.dart';
import '../premium/premium_catalog.dart';
import '../premium/premium_page.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../setting/moodly_settings_support.dart';
import 'mood_insight_detail.dart';
import 'mood_statistic_premium.dart';

class MoodAnalysis extends StatefulWidget {
  const MoodAnalysis({super.key});

  @override
  State<MoodAnalysis> createState() => _MoodAnalysisState();
}

class _MoodAnalysisState extends State<MoodAnalysis> {
  bool _isPremium = false;
  bool _isLoading = true;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);

  final Map<String, String> _moodDatabase = {};

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Analisis Mood',
      'tabWeek': 'Pekan',
      'tabMonth': 'Bulan',
      'month1': 'Januari',
      'month2': 'Februari',
      'month3': 'Maret',
      'month4': 'April',
      'month5': 'Mei',
      'month6': 'Juni',
      'month7': 'Juli',
      'month8': 'Agustus',
      'month9': 'September',
      'month10': 'Oktober',
      'month11': 'November',
      'month12': 'Desember',
      'moodSenang': 'Senang',
      'moodNetral': 'Netral',
      'moodSedih': 'Sedih',
      'moodMarah': 'Marah',
      'heroTitle': 'Lihat pola mood-mu dengan lebih lembut',
      'heroSub':
          'Versi reguler ini fokus ke ringkasan bulanan yang gampang dipahami. Yang penting kebaca, bukan sok kompleks.',
      'overviewTitle': 'Ringkasan bulan ini',
      'recordedDays': 'Hari tercatat',
      'dominantMood': 'Mood dominan',
      'consistency': 'Konsistensi',
      'chartTitle': 'Grafik tren mood',
      'chartSub':
          'Grafik ini membaca perubahan mood yang tercatat sepanjang bulan. Semakin tinggi titiknya, semakin ringan mood-nya.',
      'distributionTitle': 'Sebaran mood',
      'quickInsightTitle': 'Insight singkat',
      'detailCta': 'Lihat insight lebih detail',
      'weekLockedTitle': 'Analisis pekanan premium',
      'weekLockedDesc':
          'Tab pekan dibuka lewat statistik premium. Biar premium-nya ada isi, bukan cuma mahkota formalitas.',
      'refresh': 'Muat ulang',
      'emptyTitle': 'Belum ada mood tercatat',
      'emptyDesc':
          'Tidak apa-apa. Mulai dari satu check-in dulu, baru nanti polanya pelan-pelan kelihatan.',
      'summaryWarm':
          'Bulan ini terasa cukup hangat. Ada tanda kalau ritmemu sedang lebih aman dan ringan.',
      'summaryNeutral':
          'Bulan ini cenderung netral. Tidak terlalu naik, tidak terlalu jatuh. Kadang stabil itu sudah baik.',
      'summaryHeavy':
          'Bulan ini terasa lebih berat. Fokus ke langkah kecil lebih masuk akal daripada memaksa semuanya beres sekaligus.',
      'summaryMixed':
          'Bulan ini campur. Ada hari yang ringan, ada yang berat, jadi pola jeda dan pemicu mulai penting dibaca.',
      'periodLabel': 'Periode',
      'noMood': 'Belum ada mood',
    },
    'en': {
      'title': 'Mood Analysis',
      'tabWeek': 'Week',
      'tabMonth': 'Month',
      'month1': 'January',
      'month2': 'February',
      'month3': 'March',
      'month4': 'April',
      'month5': 'May',
      'month6': 'June',
      'month7': 'July',
      'month8': 'August',
      'month9': 'September',
      'month10': 'October',
      'month11': 'November',
      'month12': 'December',
      'moodSenang': 'Happy',
      'moodNetral': 'Neutral',
      'moodSedih': 'Sad',
      'moodMarah': 'Angry',
      'heroTitle': 'Read your mood pattern more gently',
      'heroSub':
          'This regular version focuses on a monthly summary that is easy to understand. Readable first, dramatic later.',
      'overviewTitle': 'This month at a glance',
      'recordedDays': 'Recorded days',
      'dominantMood': 'Dominant mood',
      'consistency': 'Consistency',
      'chartTitle': 'Mood trend chart',
      'chartSub':
          'This chart reads the recorded mood changes throughout the month. Higher points mean lighter moods.',
      'distributionTitle': 'Mood distribution',
      'quickInsightTitle': 'Quick insight',
      'detailCta': 'See more detailed insight',
      'weekLockedTitle': 'Weekly analysis is premium',
      'weekLockedDesc':
          'The week tab opens through premium statistics. Premium should have actual value, not just ceremonial crown energy.',
      'refresh': 'Refresh',
      'emptyTitle': 'No mood recorded yet',
      'emptyDesc':
          'That is okay. Start with one check-in first, then the pattern can reveal itself slowly.',
      'summaryWarm':
          'This month feels fairly warm. There are signs that your rhythm has been safer and lighter.',
      'summaryNeutral':
          'This month leans more neutral. Not too high, not too low. Sometimes steady is already good.',
      'summaryHeavy':
          'This month feels heavier. Focusing on small steps makes more sense than forcing everything to be fixed at once.',
      'summaryMixed':
          'This month feels mixed. Some days were light, some were heavy, so patterns and pauses matter more now.',
      'periodLabel': 'Period',
      'noMood': 'No mood yet',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
    _loadEverything();
  }

  Future<void> _loadEverything() async {
    setState(() => _isLoading = true);
    await Future.wait([
      _loadMoods(),
      _loadPremiumStatus(),
    ]);
    await _tryMarkMonthlyInsightMission();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _hydrateLanguage() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language == 'en' ? 'en' : 'id';
    });
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  Future<void> _tryMarkMonthlyInsightMission() async {
    final now = DateTime.now();
    final isViewingCurrentMonth =
        _selectedMonth.year == now.year && _selectedMonth.month == now.month;

    if (!isViewingCurrentMonth) return;
    if (_monthlyRecordedCount() <= 0) return;

    await StreakService.instance.markMonthlyMoodInsightViewed();
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  ThemeData get _theme => Theme.of(context);

  TextStyle? get _headline => _theme.textTheme.headlineLarge?.copyWith(
        color: const Color(0xFF1F1F1F),
        fontSize: 22,
      );

  TextStyle? get _title => _theme.textTheme.titleMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
        fontSize: 17,
      );

  TextStyle? get _body => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF6E746B),
        height: 1.45,
      );

  TextStyle? get _bodyDark => _theme.textTheme.bodyMedium?.copyWith(
        color: const Color(0xFF1F1F1F),
        height: 1.45,
      );

  TextStyle? get _bodyAlt => _theme.textTheme.bodySmall?.copyWith(
        color: const Color(0xFF1F1F1F),
      );

  Widget _buildPageHeader({VoidCallback? onRefresh}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.88),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.10),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF1F1F1F),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _t('title'),
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: const Color(0xFF1F1F1F),
                  ),
            ),
          ),
          if (onRefresh != null)
            GestureDetector(
              onTap: onRefresh,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.10),
                      offset: Offset(0, 6),
                      blurRadius: 18,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Color(0xFFA04CA2),
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  List<String> get _monthNames => [
        _t('month1'),
        _t('month2'),
        _t('month3'),
        _t('month4'),
        _t('month5'),
        _t('month6'),
        _t('month7'),
        _t('month8'),
        _t('month9'),
        _t('month10'),
        _t('month11'),
        _t('month12'),
      ];

  String _monthLabel(DateTime date) {
    return '${_monthNames[date.month - 1]} ${date.year}';
  }

  String _displayMood(String mood) {
    switch (mood) {
      case 'Senang':
        return _t('moodSenang');
      case 'Netral':
        return _t('moodNetral');
      case 'Sedih':
        return _t('moodSedih');
      case 'Marah':
        return _t('moodMarah');
      default:
        return mood;
    }
  }

  Color _moodAccent(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFF75B85E);
      case 'Netral':
        return const Color(0xFFC6A74E);
      case 'Sedih':
        return const Color(0xFF86AE9E);
      case 'Marah':
        return const Color(0xFFD98087);
      default:
        return const Color(0xFF98A095);
    }
  }

  Color _moodSoft(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFE9F7E8);
      case 'Netral':
        return const Color(0xFFFFF4DF);
      case 'Sedih':
        return const Color(0xFFE8F4F0);
      case 'Marah':
        return const Color(0xFFFFEEF2);
      default:
        return const Color(0xFFF7FAF1);
    }
  }

  double _moodScore(String? mood) {
    switch (mood) {
      case 'Senang':
        return 4;
      case 'Netral':
        return 3;
      case 'Sedih':
        return 2;
      case 'Marah':
        return 1;
      default:
        return 0;
    }
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _moodPrefix(String uid) => 'mood_${uid}_';

  DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
    return FirebaseFirestore.instance.collection('moods').doc(uid);
  }

  Future<void> _loadMoods() async {
    final temp = <String, String>{};

    try {
      final uid = _uid;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          _moodDatabase.clear();
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final moodPrefix = _moodPrefix(uid);

      final localKeys = prefs.getKeys().where((k) => k.startsWith(moodPrefix));
      for (final key in localKeys) {
        final dateKey = key.replaceFirst(moodPrefix, '');
        final mood = prefs.getString(key);
        if (mood != null && mood.trim().isNotEmpty) {
          temp[dateKey] = mood.trim();
        }
      }

      final doc = await _moodDoc(uid).get();

      if (doc.exists) {
        final data = doc.data();
        final entries = data?['entries'] as Map<String, dynamic>? ?? {};
        entries.forEach((key, value) {
          final mood = value.toString().trim();
          if (mood.isNotEmpty) {
            temp[key] = mood;
          }
        });
      }
    } catch (_) {}

    if (!mounted) return;
    _moodDatabase
      ..clear()
      ..addAll(temp);
  }

  Future<void> _loadPremiumStatus() async {
    try {
      await PremiumService.instance.refreshPremiumStatus();
      final access = await PremiumService.instance.getAccess();
      _isPremium = access.hasPremiumAccess;
    } catch (_) {
      _isPremium = false;
    }
  }

  int _daysInSelectedMonth() {
    return DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Map<String, int> _monthlyStats() {
    final stats = {
      'Senang': 0,
      'Netral': 0,
      'Sedih': 0,
      'Marah': 0,
    };

    _moodDatabase.forEach((key, mood) {
      if (key.startsWith(
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
      )) {
        stats[mood] = (stats[mood] ?? 0) + 1;
      }
    });

    return stats;
  }

  int _monthlyRecordedCount() {
    return _monthlyStats().values.fold(0, (sum, item) => sum + item);
  }

  String _dominantMoodRaw() {
    final stats = _monthlyStats().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (stats.isEmpty || stats.first.value == 0) return '-';
    return stats.first.key;
  }

  String _dominantMoodDisplay() {
    final raw = _dominantMoodRaw();
    return raw == '-' ? '-' : _displayMood(raw);
  }

  double _consistencyRate() {
    final recorded = _monthlyRecordedCount();
    final now = DateTime.now();

    final maxTrackableDays = (_selectedMonth.year == now.year &&
            _selectedMonth.month == now.month)
        ? now.day
        : _daysInSelectedMonth();

    if (maxTrackableDays <= 0) return 0;
    return recorded / maxTrackableDays;
  }

  List<_MoodChartPoint> _monthlySeries() {
    final totalDays = _daysInSelectedMonth();

    return List.generate(totalDays, (index) {
      final day = index + 1;
      final date = DateTime(_selectedMonth.year, _selectedMonth.month, day);
      final mood = _moodDatabase[_dateKey(date)];

      return _MoodChartPoint(
        label: '$day',
        score: _moodScore(mood),
        mood: mood,
      );
    });
  }

  List<String> _axisLabels() {
    final days = _daysInSelectedMonth();

    final anchors = <int>{
      1,
      math.max(2, (days * 0.25).round()),
      math.max(3, (days * 0.5).round()),
      math.max(4, (days * 0.75).round()),
      days,
    }.toList()
      ..sort();

    return anchors.map((e) => '$e').toList();
  }

  String _summaryText() {
    final recorded = _monthlyRecordedCount();
    if (recorded == 0) return _t('emptyDesc');

    final stats = _monthlyStats();
    final heavy = (stats['Sedih'] ?? 0) + (stats['Marah'] ?? 0);
    final warm = (stats['Senang'] ?? 0) + (stats['Netral'] ?? 0);
    final dominant = _dominantMoodRaw();

    if (heavy > warm) return _t('summaryHeavy');
    if (dominant == 'Senang') return _t('summaryWarm');
    if (dominant == 'Netral') return _t('summaryNeutral');
    return _t('summaryMixed');
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth =
          DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
    });
    _tryMarkMonthlyInsightMission();
  }

  Future<void> _openWeeklyPremium() async {
    if (!_isPremium) {
      showCuteTopPopup(
        context,
        title: _t('weekLockedTitle'),
        message: _t('weekLockedDesc'),
        type: CutePopupType.info,
      );

      Future.delayed(const Duration(milliseconds: 350), () async {
        if (!mounted) return;

        await openMoodlyPremiumPage(
          context,
          source: PremiumEntrySource.moodAnalysisLocked,
        );

        if (!mounted) return;
        await _loadPremiumStatus();
      });

      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodStatisticPremium()),
    );
  }

  void _openInsightDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodInsightDetail(
          periodLabel: _monthLabel(_selectedMonth),
          moodStats: _monthlyStats(),
          recordedCount: _monthlyRecordedCount(),
          consistencyRate: _consistencyRate(),
          dominantMoodRaw: _dominantMoodRaw(),
          isPremiumContext: false,
        ),
      ),
    );
  }

  Widget _segment({
    required String label,
    required bool active,
    required VoidCallback onTap,
    bool premium = false,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active
                ? (premium ? const Color(0xFFFFF0D9) : const Color(0xFFDDEFCF))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (premium) ...[
                const Icon(
                  Icons.workspace_premium_rounded,
                  color: Color(0xFFE29F22),
                  size: 16,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: _bodyAlt?.copyWith(
                  color: const Color(0xFF1F1F1F),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _overviewCard() {
    final recorded = _monthlyRecordedCount();
    final consistency = (_consistencyRate() * 100).round();
    final dominantRaw = _dominantMoodRaw();
    final dominantBg = dominantRaw == '-' ? const Color(0xFFF7FAF1) : _moodSoft(dominantRaw);
    final dominantFg = dominantRaw == '-' ? const Color(0xFF6E746B) : _moodAccent(dominantRaw);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('overviewTitle'), style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _statChip(
                  label: _t('recordedDays'),
                  value: '$recorded',
                  bg: const Color(0xFFE9F7E8),
                  fg: const Color(0xFF2D6B20),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statChip(
                  label: _t('dominantMood'),
                  value: _dominantMoodDisplay(),
                  bg: dominantBg,
                  fg: dominantFg,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _statChip(
                  label: _t('consistency'),
                  value: '$consistency%',
                  bg: const Color(0xFFFFF4DF),
                  fg: const Color(0xFF8A5A09),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statChip({
    required String label,
    required String value,
    required Color bg,
    required Color fg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: _body?.copyWith(color: fg)),
          const SizedBox(height: 6),
          Text(
            value,
            style: _title?.copyWith(
              color: fg,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendCard() {
    final points = _monthlySeries();
    final hasData = points.any((e) => e.score > 0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('chartTitle'), style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
          Text(_t('chartSub'), style: _body),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_t('emptyTitle'), style: _title),
                  const SizedBox(height: 6),
                  Text(_t('emptyDesc'), style: _bodyDark),
                ],
              ),
            )
          else ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 58,
                  height: 220,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_displayMood('Senang'), style: _body?.copyWith(fontSize: 11)),
                      Text(_displayMood('Netral'), style: _body?.copyWith(fontSize: 11)),
                      Text(_displayMood('Sedih'), style: _body?.copyWith(fontSize: 11)),
                      Text(_displayMood('Marah'), style: _body?.copyWith(fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 220,
                    child: CustomPaint(
                      painter: _MoodTrendPainter(
                        points: points,
                        lineColor: const Color(0xFF75B85E),
                        gridColor: const Color(0xFFEAEDE3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: _axisLabels()
                  .map(
                    (label) => Expanded(
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        style: _body?.copyWith(fontSize: 10),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _distributionCard() {
    final stats = _monthlyStats();
    final total = math.max(_monthlyRecordedCount(), 1);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('distributionTitle'), style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 14),
          _distributionRow('Senang', stats['Senang'] ?? 0, total),
          _distributionRow('Netral', stats['Netral'] ?? 0, total),
          _distributionRow('Sedih', stats['Sedih'] ?? 0, total),
          _distributionRow('Marah', stats['Marah'] ?? 0, total),
        ],
      ),
    );
  }

  Widget _distributionRow(String mood, int count, int total) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: Text(_displayMood(mood), style: _bodyDark)),
              Text('$count', style: _bodyAlt),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: count / total,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAEDE3),
              color: _moodAccent(mood),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryCard() {
    final dominantRaw = _dominantMoodRaw();
    final accent = dominantRaw == '-' ? const Color(0xFF84C96C) : _moodAccent(dominantRaw);
    final bg = dominantRaw == '-' ? const Color(0xFFF7FAF1) : _moodSoft(dominantRaw);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 8),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_t('quickInsightTitle'), style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              _summaryText(),
              style: _bodyDark?.copyWith(color: const Color(0xFF364134)),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _openInsightDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              child: Text(_t('detailCta')),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = _monthLabel(_selectedMonth);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F8EA),
        body: SafeArea(
          child: Column(
            children: [
              _buildPageHeader(),
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Color(0xFF75B85E)),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F8EA),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFFEEF2).withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            top: 280,
            left: -70,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE9F7E8).withOpacity(0.80),
              ),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 26),
            child: Column(
              children: [
                _buildPageHeader(onRefresh: _loadEverything),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.08),
                        offset: Offset(0, 8),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(_t('heroTitle'), style: _headline),
                            const SizedBox(height: 8),
                            Text(_t('heroSub'), style: _body),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: _monthlyRecordedCount() == 0
                              ? const Color(0xFFF7FAF1)
                              : const Color(0xFFFFF6F8),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${_monthlyRecordedCount()}',
                              style: _headline?.copyWith(fontSize: 26),
                            ),
                            Text(
                              _monthlyRecordedCount() == 0
                                  ? _t('noMood')
                                  : _t('recordedDays'),
                              textAlign: TextAlign.center,
                              style: _body?.copyWith(fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: const [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.06),
                        offset: Offset(0, 6),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _segment(
                        label: _t('tabWeek'),
                        active: false,
                        premium: true,
                        onTap: _openWeeklyPremium,
                      ),
                      _segment(
                        label: _t('tabMonth'),
                        active: true,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDEFCF),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () => _changeMonth(-1),
                      ),
                      Expanded(
                        child: Text(
                          monthLabel,
                          textAlign: TextAlign.center,
                          style: _title,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () => _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _overviewCard(),
                const SizedBox(height: 16),
                _trendCard(),
                const SizedBox(height: 16),
                _distributionCard(),
                const SizedBox(height: 16),
                _summaryCard(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodChartPoint {
  final String label;
  final double score;
  final String? mood;

  const _MoodChartPoint({
    required this.label,
    required this.score,
    required this.mood,
  });
}

class _MoodTrendPainter extends CustomPainter {
  final List<_MoodChartPoint> points;
  final Color lineColor;
  final Color gridColor;

  _MoodTrendPainter({
    required this.points,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const topPad = 14.0;
    const bottomPad = 18.0;
    final chartHeight = size.height - topPad - bottomPad;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (int i = 0; i < 4; i++) {
      final y = topPad + (chartHeight / 3) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final validIndices = <int>[];
    for (int i = 0; i < points.length; i++) {
      if (points[i].score > 0) validIndices.add(i);
    }

    if (validIndices.isEmpty) return;

    Offset positionFor(int index) {
      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * index;
      final score = points[index].score;
      final normalized = (4 - score) / 3;
      final y = topPad + (normalized * chartHeight);
      return Offset(x, y);
    }

    final path = Path();
    bool first = true;
    for (final i in validIndices) {
      final p = positionFor(i);
      if (first) {
        path.moveTo(p.dx, p.dy);
        first = false;
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (final i in validIndices) {
      final p = positionFor(i);
      canvas.drawCircle(p, 5.5, Paint()..color = lineColor);
      canvas.drawCircle(p, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _MoodTrendPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}