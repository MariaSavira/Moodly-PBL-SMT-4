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

class MoodStatisticPremium extends StatefulWidget {
  const MoodStatisticPremium({super.key});

  @override
  State<MoodStatisticPremium> createState() => _MoodStatisticPremiumState();
}

class _MoodStatisticPremiumState extends State<MoodStatisticPremium> {
  int _selectedIndex = 0;
  DateTime _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int _selectedWeek = 1;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  final Map<String, String> _moodDatabase = {};

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Statistik Premium',
      'tabWeek': 'Pekan',
      'tabMonth': 'Bulan',
      'heroTitle': 'Analisis premium yang lebih niat',
      'heroSub':
          'Versi ini membaca pola dengan lebih detail dan memberi arah aktivitas yang lebih berguna.',
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
      'daySun': 'Min',
      'dayMon': 'Sen',
      'dayTue': 'Sel',
      'dayWed': 'Rab',
      'dayThu': 'Kam',
      'dayFri': 'Jum',
      'daySat': 'Sab',
      'moodSenang': 'Senang',
      'moodNetral': 'Netral',
      'moodSedih': 'Sedih',
      'moodMarah': 'Marah',
      'weekTitle': 'Tren 7 hari',
      'weekSub':
          'Grafik pekanan fokus ke perubahan harian yang lebih detail dan dimulai dari Minggu, seperti manusia waras.',
      'weekDominant': 'Mood dominan',
      'weekCoverage': 'Hari tercatat',
      'weekHard': 'Mood terberat',
      'weekInsight': 'Insight premium',
      'weekInsightText':
          'Kalau satu minggu terasa berat, user butuh arah konkret, bukan dekorasi statistik yang sok dalam.',
      'monthTitle': 'Sebaran bulan ini',
      'monthSub': 'Lihat distribusi mood dan heatmap sederhana per hari.',
      'consistency': 'Konsistensi',
      'bestMood': 'Mood paling sering',
      'monthInsight': 'Yang paling terlihat',
      'monthInsightText':
          'Bulan ini lebih banyak diisi mood ringan dan netral, tapi pola hari berat tetap penting dibaca.',
      'activityTitle': 'Saran aktivitas',
      'activitySub':
          'Ketika pola cenderung berat, user butuh kegiatan kecil yang masuk akal untuk dicoba.',
      'sleepTitle': 'Tidur lebih teratur',
      'sleepDesc': 'Coba rapikan jam tidur dan kurangi layar sebelum malam.',
      'journalTitle': 'Journaling ringan',
      'journalDesc':
          'Tulis singkat apa yang terjadi, apa yang kamu rasa, dan apa yang kamu butuhkan.',
      'walkTitle': 'Jalan singkat',
      'walkDesc': '5 sampai 10 menit jalan pelan bisa bantu menurunkan beban kepala.',
      'breatheTitle': 'Latihan napas',
      'breatheDesc':
          'Tarik 4 detik, tahan 4 detik, buang 6 detik selama beberapa putaran.',
      'reachOutTitle': 'Hubungi orang aman',
      'reachOutDesc': 'Kalau emosinya terlalu penuh, jangan terus dipikul sendirian.',
      'hydrateTitle': 'Makan dan minum cukup',
      'hydrateDesc':
          'Tubuh yang kelelahan sering ikut bikin emosi makin kusut.',
      'steadyTitle': 'Pertahankan ritme baik',
      'steadyDesc':
          'Kalau polanya cukup stabil, fokus ke menjaga kebiasaan yang sudah membantu.',
      'gratitudeTitle': 'Simpan momen hangat',
      'gratitudeDesc':
          'Catat momen kecil yang terasa baik supaya tidak cepat lewat begitu saja.',
      'detailCta': 'Lihat insight lebih detail',
      'premiumOn': 'Premium aktif',
      'premiumOnDesc': 'Insight tambahan siap dibuka.',
    },
    'en': {
      'title': 'Premium Statistics',
      'tabWeek': 'Week',
      'tabMonth': 'Month',
      'heroTitle': 'A more serious premium analysis',
      'heroSub':
          'This version reads patterns in more detail and gives activity directions that are actually useful.',
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
      'daySun': 'Sun',
      'dayMon': 'Mon',
      'dayTue': 'Tue',
      'dayWed': 'Wed',
      'dayThu': 'Thu',
      'dayFri': 'Fri',
      'daySat': 'Sat',
      'moodSenang': 'Happy',
      'moodNetral': 'Neutral',
      'moodSedih': 'Sad',
      'moodMarah': 'Angry',
      'weekTitle': '7-day trend',
      'weekSub':
          'Weekly analysis focuses on more detailed day-to-day changes and starts from Sunday, like a sensible person would.',
      'weekDominant': 'Dominant mood',
      'weekCoverage': 'Recorded days',
      'weekHard': 'Heaviest mood',
      'weekInsight': 'Premium insight',
      'weekInsightText':
          'If a week feels heavy, users need concrete direction, not decorative statistics pretending to be profound.',
      'monthTitle': 'This month’s distribution',
      'monthSub': 'See mood distribution and a simple daily heatmap.',
      'consistency': 'Consistency',
      'bestMood': 'Most frequent mood',
      'monthInsight': 'What stands out',
      'monthInsightText':
          'This month is filled more by lighter and neutral moods, but heavier days still deserve attention.',
      'activityTitle': 'Suggested activities',
      'activitySub':
          'When the pattern becomes heavier, users need realistic small actions to try.',
      'sleepTitle': 'Fix your sleep rhythm',
      'sleepDesc':
          'Try cleaning up your sleep schedule and reducing screen time at night.',
      'journalTitle': 'Light journaling',
      'journalDesc':
          'Write briefly what happened, what you felt, and what you needed.',
      'walkTitle': 'Short walk',
      'walkDesc':
          'A slow 5 to 10 minute walk can help lower mental pressure.',
      'breatheTitle': 'Breathing practice',
      'breatheDesc':
          'Inhale 4 seconds, hold 4 seconds, exhale 6 seconds for several rounds.',
      'reachOutTitle': 'Reach a safe person',
      'reachOutDesc':
          'If emotions feel too full, stop carrying everything alone.',
      'hydrateTitle': 'Eat and drink enough',
      'hydrateDesc':
          'A tired body often makes emotions feel even messier.',
      'steadyTitle': 'Protect a good rhythm',
      'steadyDesc':
          'If the pattern is fairly steady, protect the habits that already help.',
      'gratitudeTitle': 'Keep warm moments',
      'gratitudeDesc':
          'Write down small warm moments so they do not disappear too quickly.',
      'detailCta': 'See more detailed insight',
      'premiumOn': 'Premium active',
      'premiumOnDesc': 'Additional insight is ready to open.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _hydrateLanguage();
    _loadMoodData();
    _tryMarkMonthlyInsightMission();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _guardPremiumAccess();
    });
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

  int _monthlyRecordedCount() {
    return _monthStats().values.fold(0, (sum, count) => sum + count);
  }

  Future<void> _loadMoodData() async {
    final temp = <String, String>{};

    try {
      final uid = _uid;

      if (uid != null) {
        final prefs = await SharedPreferences.getInstance();
        final moodPrefix = _moodPrefix(uid);

        for (final key in prefs.getKeys().where((k) => k.startsWith(moodPrefix))) {
          final dateKey = key.replaceFirst(moodPrefix, '');
          final value = prefs.getString(key);
          if (value != null && value.trim().isNotEmpty) {
            temp[dateKey] = value.trim();
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
      }

      if (!mounted) return;

      setState(() {
        _moodDatabase
          ..clear()
          ..addAll(temp);

        if (temp.isNotEmpty) {
          final sortedKeys = temp.keys.toList()..sort();
          final latest = sortedKeys.last.split('-');
          _selectedMonth = DateTime(
            int.parse(latest[0]),
            int.parse(latest[1]),
            1,
          );
          _selectedWeek = 1;
        } else {
          final now = DateTime.now();
          _selectedMonth = DateTime(now.year, now.month, 1);
          _selectedWeek = 1;
        }
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _moodDatabase.clear();
        final now = DateTime.now();
        _selectedMonth = DateTime(now.year, now.month, 1);
        _selectedWeek = 1;
      });
    }
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
        height: 1.4,
      );

  TextStyle? get _bodyAlt => _theme.textTheme.bodySmall?.copyWith(
        color: const Color(0xFF1F1F1F),
      );
  
  Widget _buildPageHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 46,
              height: 46,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                _t('title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: const Color(0xFF1F1F1F),
                      height: 1.1,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              final access = await PremiumService.instance.getAccess();
              if (!mounted) return;

              showCuteTopPopup(
                context,
                title: _t('premiumOn'),
                message: access.hasPremiumAccess
                    ? _t('premiumOnDesc')
                    : _t('detailCta'),
                type: access.hasPremiumAccess
                    ? CutePopupType.success
                    : CutePopupType.info,
              );
            },
            child: Container(
              width: 46,
              height: 46,
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
                Icons.workspace_premium_rounded,
                color: Color(0xFFE29F22),
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

  List<String> get _sundayFirstLabels => [
        _t('daySun'),
        _t('dayMon'),
        _t('dayTue'),
        _t('dayWed'),
        _t('dayThu'),
        _t('dayFri'),
        _t('daySat'),
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

  Color _moodColor(String mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFBEE8BE);
      case 'Netral':
        return const Color(0xFFF3E6B6);
      case 'Sedih':
        return const Color(0xFFD8ECE3);
      case 'Marah':
        return const Color(0xFFF3C6CA);
      default:
        return const Color(0xFFE8ECE2);
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

  Map<String, int> _monthStats() {
    final stats = {'Senang': 0, 'Netral': 0, 'Sedih': 0, 'Marah': 0};

    _moodDatabase.forEach((key, mood) {
      if (key.startsWith(
        '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}',
      )) {
        stats[mood] = (stats[mood] ?? 0) + 1;
      }
    });

    return stats;
  }

  int _daysInMonth() {
    return DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0).day;
  }

  int _monthOffsetSundayFirst() {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    return firstDay.weekday % 7;
  }

  int _totalWeeksInMonth() {
    final total = _monthOffsetSundayFirst() + _daysInMonth();
    return (total / 7).ceil();
  }

  DateTime _weekStartForIndex(int weekIndex) {
    final firstDay = DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final sundayStart = firstDay.subtract(Duration(days: firstDay.weekday % 7));
    return sundayStart.add(Duration(days: (weekIndex - 1) * 7));
  }

  List<_PremiumPoint> _weekSeries() {
    final start = _weekStartForIndex(_selectedWeek);

    return List.generate(7, (index) {
      final date = start.add(Duration(days: index));
      final key =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

      final insideMonth = date.month == _selectedMonth.month &&
          date.year == _selectedMonth.year;
      final mood = insideMonth ? _moodDatabase[key] : null;

      return _PremiumPoint(
        label: _sundayFirstLabels[index],
        score: _moodScore(mood),
        mood: mood,
      );
    });
  }

  Map<String, int> _weekStats() {
    final stats = {'Senang': 0, 'Netral': 0, 'Sedih': 0, 'Marah': 0};
    for (final point in _weekSeries()) {
      if (point.mood != null) {
        stats[point.mood!] = (stats[point.mood!] ?? 0) + 1;
      }
    }
    return stats;
  }

  String _dominantWeekMood() {
    final stats = _weekStats().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (stats.isEmpty || stats.first.value == 0) return '-';
    return _displayMood(stats.first.key);
  }

  String _hardestWeekMood() {
    final list = _weekSeries().where((e) => e.mood != null).toList();
    if (list.isEmpty) return '-';
    list.sort((a, b) => a.score.compareTo(b.score));
    return _displayMood(list.first.mood!);
  }

  int _weekCoverage() {
    return _weekSeries().where((e) => e.mood != null).length;
  }

  String _dominantWeekMoodRaw() {
    final entries = _weekStats().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (entries.isEmpty || entries.first.value == 0) {
      return '-';
    }

    return entries.first.key;
  }

  double _consistencyRate() {
    final total = _monthStats().values.fold(0, (sum, e) => sum + e);
    return total / _daysInMonth();
  }

  String _bestMonthMood() {
    final stats = _monthStats().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return stats.first.value == 0 ? '-' : _displayMood(stats.first.key);
  }

  String _bestMonthMoodRaw() {
    final stats = _monthStats().entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return stats.first.value == 0 ? '-' : stats.first.key;
  }

  void _changeMonth(int offset) {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + offset, 1);
      _selectedWeek = 1;
    });
    _tryMarkMonthlyInsightMission();
  }

  void _changeWeek(int offset) {
    setState(() {
      _selectedWeek += offset;
      if (_selectedWeek < 1) {
        _changeMonth(-1);
        _selectedWeek = _totalWeeksInMonth();
      } else if (_selectedWeek > _totalWeeksInMonth()) {
        _changeMonth(1);
        _selectedWeek = 1;
      }
    });
  }

  Future<void> _guardPremiumAccess() async {
    try {
      await PremiumService.instance.refreshPremiumStatus();
      final access = await PremiumService.instance.getAccess();

      if (!mounted) return;

      if (!access.hasPremiumAccess) {
        showCuteTopPopup(
          context,
          title: _t('title'),
          message: _t('premiumOnDesc'),
          type: CutePopupType.info,
        );

        Future.delayed(const Duration(milliseconds: 350), () {
          if (!mounted) return;
          Navigator.pop(context);
          openMoodlyPremiumPage(
            context,
            source: PremiumEntrySource.moodAnalysisLocked,
          );
        });
      }
    } catch (_) {
      if (!mounted) return;

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        Navigator.pop(context);
        openMoodlyPremiumPage(
          context,
          source: PremiumEntrySource.moodAnalysisLocked,
        );
      });
    }
  }

  void _openInsightDetail() {
    if (_selectedIndex == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoodInsightDetail(
            periodLabel: '${_t('tabWeek')} $_selectedWeek, ${_monthLabel(_selectedMonth)}',
            moodStats: _weekStats(),
            recordedCount: _weekCoverage(),
            consistencyRate: _weekCoverage() / 7,
            dominantMoodRaw: _dominantWeekMoodRaw(),
            isPremiumContext: true,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoodInsightDetail(
            periodLabel: _monthLabel(_selectedMonth),
            moodStats: _monthStats(),
            recordedCount: _monthStats().values.fold(0, (sum, e) => sum + e),
            consistencyRate: _consistencyRate(),
            dominantMoodRaw: _bestMonthMoodRaw(),
            isPremiumContext: true,
          ),
        ),
      );
    }
  }

  Widget _segment({
    required String label,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFFFF0D9) : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(label, style: _bodyAlt),
          ),
        ),
      ),
    );
  }

  Widget _statCard({
    required String label,
    required String value,
    required Color bg,
    required Color fg,
  }) {
    return Expanded(
      child: Container(
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
            Text(value, style: _title?.copyWith(color: fg)),
          ],
        ),
      ),
    );
  }

  Widget _distributionRow(String mood, int count, int total) {
    final safeTotal = math.max(total, 1);

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
              value: count / safeTotal,
              minHeight: 10,
              backgroundColor: const Color(0xFFEAEDE3),
              color: _moodAccent(mood),
            ),
          ),
        ],
      ),
    );
  }

  Widget _heatmap() {
    final days = _daysInMonth();
    final offset = _monthOffsetSundayFirst();
    final totalSlots = (((offset + days) / 7).ceil()) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: totalSlots,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 6,
        mainAxisSpacing: 6,
        childAspectRatio: 1,
      ),
      itemBuilder: (context, index) {
        if (index < offset || index >= offset + days) {
          return const SizedBox.shrink();
        }

        final day = index - offset + 1;
        final key =
            '${_selectedMonth.year}-${_selectedMonth.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
        final mood = _moodDatabase[key];

        return Container(
          decoration: BoxDecoration(
            color: mood == null ? const Color(0xFFF1F3EC) : _moodColor(mood),
            borderRadius: BorderRadius.circular(10),
            border: mood == null
                ? null
                : Border.all(color: _moodAccent(mood), width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: _bodyAlt?.copyWith(fontSize: 10),
          ),
        );
      },
    );
  }

  List<_ActivitySuggestion> _activitySuggestions() {
    final currentStats = _selectedIndex == 0 ? _weekStats() : _monthStats();
    final positive = (currentStats['Senang'] ?? 0) + (currentStats['Netral'] ?? 0);
    final negative = (currentStats['Sedih'] ?? 0) + (currentStats['Marah'] ?? 0);

    if (negative > positive) {
      return [
        _ActivitySuggestion(
          icon: Icons.nightlight_round,
          title: _t('sleepTitle'),
          description: _t('sleepDesc'),
          bg: const Color(0xFFEFE6FF),
          fg: const Color(0xFF7A52B3),
        ),
        _ActivitySuggestion(
          icon: Icons.menu_book_rounded,
          title: _t('journalTitle'),
          description: _t('journalDesc'),
          bg: const Color(0xFFFFF2DD),
          fg: const Color(0xFF9A6C18),
        ),
        _ActivitySuggestion(
          icon: Icons.self_improvement_rounded,
          title: _t('breatheTitle'),
          description: _t('breatheDesc'),
          bg: const Color(0xFFE6F7F0),
          fg: const Color(0xFF37856A),
        ),
        _ActivitySuggestion(
          icon: Icons.favorite_rounded,
          title: _t('reachOutTitle'),
          description: _t('reachOutDesc'),
          bg: const Color(0xFFFFEEF2),
          fg: const Color(0xFFA05061),
        ),
      ];
    }

    return [
      _ActivitySuggestion(
        icon: Icons.directions_walk_rounded,
        title: _t('walkTitle'),
        description: _t('walkDesc'),
        bg: const Color(0xFFEAF6DE),
        fg: const Color(0xFF558E3E),
      ),
      _ActivitySuggestion(
        icon: Icons.local_drink_rounded,
        title: _t('hydrateTitle'),
        description: _t('hydrateDesc'),
        bg: const Color(0xFFE7F6FB),
        fg: const Color(0xFF3A7F90),
      ),
      _ActivitySuggestion(
        icon: Icons.auto_awesome_rounded,
        title: _t('gratitudeTitle'),
        description: _t('gratitudeDesc'),
        bg: const Color(0xFFFFF3F6),
        fg: const Color(0xFFB55A76),
      ),
      _ActivitySuggestion(
        icon: Icons.check_circle_rounded,
        title: _t('steadyTitle'),
        description: _t('steadyDesc'),
        bg: const Color(0xFFE9F7E8),
        fg: const Color(0xFF3E8A2D),
      ),
    ];
  }

  Widget _activityCard(_ActivitySuggestion item) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: item.bg,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: item.fg.withOpacity(0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(item.icon, color: item.fg),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: _title?.copyWith(color: item.fg),
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            style: _bodyDark?.copyWith(color: const Color(0xFF3F463C)),
          ),
        ],
      ),
    );
  }

  Widget _trendCard({
    required String title,
    required String subtitle,
    required List<_PremiumPoint> points,
  }) {
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
          Text(title, style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
          Text(subtitle, style: _body),
          const SizedBox(height: 16),
          if (!hasData)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFF7FAF1),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Text(
                _selectedIndex == 0 ? _t('weekInsightText') : _t('monthInsightText'),
                style: _bodyDark,
              ),
            )
          else
            Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 56,
                      height: 210,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_displayMood('Senang'),
                              style: _body?.copyWith(fontSize: 11)),
                          Text(_displayMood('Netral'),
                              style: _body?.copyWith(fontSize: 11)),
                          Text(_displayMood('Sedih'),
                              style: _body?.copyWith(fontSize: 11)),
                          Text(_displayMood('Marah'),
                              style: _body?.copyWith(fontSize: 11)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: SizedBox(
                        height: 210,
                        child: CustomPaint(
                          painter: _PremiumLineChartPainter(
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
                  children: points
                      .map(
                        (e) => Expanded(
                          child: Text(
                            e.label,
                            textAlign: TextAlign.center,
                            style: _body?.copyWith(fontSize: 10),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _activitySuggestionSection() {
    final items = _activitySuggestions();

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
          Text(_t('activityTitle'), style: _title?.copyWith(fontSize: 19)),
          const SizedBox(height: 6),
          Text(_t('activitySub'), style: _body),
          const SizedBox(height: 16),
          SizedBox(
            height: 190,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              itemBuilder: (_, index) => _activityCard(items[index]),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _openInsightDetail,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF75B85E),
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
    final stats = _monthStats();

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
            bottom: 80,
            left: -60,
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
                _buildPageHeader(),
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
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFF4DF),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.insights_rounded,
                          color: Color(0xFFB8831F),
                          size: 34,
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
                        active: _selectedIndex == 0,
                        onTap: () => setState(() => _selectedIndex = 0),
                      ),
                      _segment(
                        label: _t('tabMonth'),
                        active: _selectedIndex == 1,
                        onTap: () => setState(() => _selectedIndex = 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0D9),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left_rounded),
                        onPressed: () =>
                            _selectedIndex == 0 ? _changeWeek(-1) : _changeMonth(-1),
                      ),
                      Expanded(
                        child: Text(
                          _selectedIndex == 0
                              ? '${_t('tabWeek')} $_selectedWeek, $monthLabel'
                              : monthLabel,
                          textAlign: TextAlign.center,
                          style: _title,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right_rounded),
                        onPressed: () =>
                            _selectedIndex == 0 ? _changeWeek(1) : _changeMonth(1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_selectedIndex == 0) ...[
                  _trendCard(
                    title: _t('weekTitle'),
                    subtitle: _t('weekSub'),
                    points: _weekSeries(),
                  ),
                  const SizedBox(height: 16),
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('weekInsight'), style: _title?.copyWith(fontSize: 19)),
                        const SizedBox(height: 8),
                        Text(_t('weekInsightText'), style: _bodyDark),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statCard(
                              label: _t('weekDominant'),
                              value: _dominantWeekMood(),
                              bg: const Color(0xFFFFEEF2),
                              fg: const Color(0xFF7A3C52),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: _t('weekCoverage'),
                              value: '${_weekCoverage()}/7',
                              bg: const Color(0xFFE9F7E8),
                              fg: const Color(0xFF2D6B20),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: _t('weekHard'),
                              value: _hardestWeekMood(),
                              bg: const Color(0xFFFFF4DF),
                              fg: const Color(0xFF8A5A09),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ...[
                          _distributionRow('Senang', _weekStats()['Senang'] ?? 0, 7),
                          _distributionRow('Netral', _weekStats()['Netral'] ?? 0, 7),
                          _distributionRow('Sedih', _weekStats()['Sedih'] ?? 0, 7),
                          _distributionRow('Marah', _weekStats()['Marah'] ?? 0, 7),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _activitySuggestionSection(),
                ] else ...[
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_t('monthTitle'), style: _title?.copyWith(fontSize: 19)),
                        const SizedBox(height: 6),
                        Text(_t('monthSub'), style: _body),
                        const SizedBox(height: 16),
                        _distributionRow('Senang', stats['Senang'] ?? 0, _daysInMonth()),
                        _distributionRow('Netral', stats['Netral'] ?? 0, _daysInMonth()),
                        _distributionRow('Sedih', stats['Sedih'] ?? 0, _daysInMonth()),
                        _distributionRow('Marah', stats['Marah'] ?? 0, _daysInMonth()),
                        const SizedBox(height: 8),
                        _heatmap(),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _statCard(
                              label: _t('consistency'),
                              value: '${(_consistencyRate() * 100).round()}%',
                              bg: const Color(0xFFE9F7E8),
                              fg: const Color(0xFF2D6B20),
                            ),
                            const SizedBox(width: 10),
                            _statCard(
                              label: _t('bestMood'),
                              value: _bestMonthMood(),
                              bg: const Color(0xFFFFEEF2),
                              fg: const Color(0xFF7A3C52),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(_t('monthInsight'), style: _title),
                        const SizedBox(height: 8),
                        Text(_t('monthInsightText'), style: _bodyDark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _activitySuggestionSection(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumPoint {
  final String label;
  final double score;
  final String? mood;

  const _PremiumPoint({
    required this.label,
    required this.score,
    required this.mood,
  });
}

class _ActivitySuggestion {
  final IconData icon;
  final String title;
  final String description;
  final Color bg;
  final Color fg;

  const _ActivitySuggestion({
    required this.icon,
    required this.title,
    required this.description,
    required this.bg,
    required this.fg,
  });
}

class _PremiumLineChartPainter extends CustomPainter {
  final List<_PremiumPoint> points;
  final Color lineColor;
  final Color gridColor;

  _PremiumLineChartPainter({
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

    Offset pointAt(int index) {
      final x = points.length == 1
          ? size.width / 2
          : (size.width / (points.length - 1)) * index;
      final normalized = (4 - points[index].score) / 3;
      final y = topPad + (normalized * chartHeight);
      return Offset(x, y);
    }

    final path = Path();
    bool first = true;
    for (final i in validIndices) {
      final point = pointAt(i);
      if (first) {
        path.moveTo(point.dx, point.dy);
        first = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(path, linePaint);

    for (final i in validIndices) {
      final point = pointAt(i);
      canvas.drawCircle(point, 6, Paint()..color = lineColor);
      canvas.drawCircle(point, 2.5, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(covariant _PremiumLineChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}