import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setting/moodly_settings_support.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/styles/app_text.dart';
import '../core/services/moodly_notification_service.dart';
import '../core/services/premium_service.dart';
import '../widgets/shared/moodly_user_avatar.dart';
import '../widgets/shared/moodly_reward_frame_avatar.dart';
import '../core/services/streak_service.dart';
import '../core/services/user_appeal_service.dart';
import '../widgets/moodly_bottom_navbar.dart';
import '../services/afirmasi/afirmasi_service.dart';
import 'afirmasi/widgets/cute_top_popup.dart';
import 'premium/premium_page.dart';
import 'premium/premium_catalog.dart';
import 'pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  int _currentNavIndex = 0;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const SystemUiOverlayStyle _homeSystemUi = SystemUiOverlayStyle(
    statusBarColor: Color(0xFFF3FADC),
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFFF3FADC),
    systemNavigationBarIconBrightness: Brightness.dark,
    systemNavigationBarDividerColor: Color(0xFFF3FADC),
  );

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'reportedTitle': 'Kamu telah dilaporkan',
      'later': 'Nanti',
      'viewDetail': 'Lihat Detail',
      'freezeTemporaryTitle': 'Akunmu sedang dibekukan sementara',
      'freezePermanentTitle': 'Akunmu dibekukan permanen',
      'freezeTemporaryDesc':
          'Homepage dikunci sementara sampai masa tindakan selesai. Kamu hanya bisa membuka riwayat laporan dan halaman banding.',
      'freezePermanentDesc':
          'Homepage dikunci karena ada tindakan permanen. Kamu hanya bisa membuka riwayat laporan dan halaman banding.',
      'remainingTime': 'Sisa waktu',
      'openReportHistory': 'Buka Riwayat Laporan',
      'openAppealPage': 'Ajukan Banding',
      'freezeReason': 'Alasan laporan',
      'freezeAction': 'Tindakan',
      'freezeAppeal': 'Status banding',
      'goodMorning': 'Selamat pagi,',
      'goodAfternoon': 'Selamat siang,',
      'goodEvening': 'Selamat sore,',
      'goodNight': 'Selamat malam,',
      'todayAffirmation': 'Untuk hari ini',
      'points': 'Gunakan poin',
      'explorePremium': 'Jelajahi paket premium',
      'premiumSubscribed': 'Anda berlangganan Premium',
      'pickDate': 'Pilih Tanggal',
      'myDiary': 'Lihat diarymu',
      'publicDiary': 'Kunjungi diary publik',
      'dailyRoom': 'Ruang Harian',
      'moodAnalysis': 'Lihat Analisa Mood Anda',
      'moodAnalysisDesc': 'Buka ringkasan mingguan dan bulanan mood-mu.',
      'todayDiary': 'Diary Hari Ini',
      'todayDiaryDesc': 'Buka diary untuk menulis catatanmu hari ini.',
      'selectedDiaryDesc':
          'Buka diary untuk melihat atau menulis catatan di tanggal ini.',
      'defaultTip': 'Pelan-pelan ya, semuanya bisa dibicarakan nanti.',
      'tipHappy': 'Senang itu valid. Nikmati tanpa merasa bersalah.',
      'tipNeutral': 'Hari yang biasa tetap layak dihargai.',
      'tipSad': 'Pelan-pelan. Hari berat tidak membuatmu gagal.',
      'tipAngry': 'Tarik napas. Jeda sebentar juga bentuk merawat diri.',
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'Mei',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Agu',
      'sep': 'Sep',
      'oct': 'Okt',
      'nov': 'Nov',
      'dec': 'Des',
      'moodlyUser': 'Pengguna Moodly',
      'streakLabel': 'Streak',
      'pointLabel': '{points} poin',
      'premiumCta': 'Jelajahi paket premium',
      'affirmationFallback':
          'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.',
      'dayMin': 'Min',
      'daySen': 'Sen',
      'daySel': 'Sel',
      'dayRab': 'Rab',
      'dayKam': 'Kam',
      'dayJum': 'Jum',
      'daySab': 'Sab',
      'monthFull1': 'Januari',
      'monthFull2': 'Februari',
      'monthFull3': 'Maret',
      'monthFull4': 'April',
      'monthFull5': 'Mei',
      'monthFull6': 'Juni',
      'monthFull7': 'Juli',
      'monthFull8': 'Agustus',
      'monthFull9': 'September',
      'monthFull10': 'Oktober',
      'monthFull11': 'November',
      'monthFull12': 'Desember',
      'howToday': 'Bagaimana harimu berjalan?',
      'howOnDate': 'Bagaimana harimu di {date}?',
      'tellSlowly': 'Ceritakan pada kami, pelan-pelan saja.',
      'editMoodDate': 'Edit mood {date}',
      'fillMoodDate': 'Isi mood {date}',
      'premiumLockedTitle': 'Belum tersedia',
      'premiumLockedDesc':
          'Analisa mood untuk akun reguler dibuka setiap tanggal 1. Premium bisa akses kapan saja.',
      'diaryOnDate': 'Diary {date}',
      'reportedPopupTitle': 'Kamu telah dilaporkan',
      'categoryGratitude': 'Rasa Syukur',
      'categoryAnxiety': 'Meredakan Kecemasan',
      'categoryMotivation': 'Motivasi',
      'categoryMentalHealth': 'Kesehatan Mental',
      'categorySelfLove': 'Cinta Diri',
    },
    'en': {
      'reportedTitle': 'You have been reported',
      'later': 'Later',
      'viewDetail': 'View Detail',
      'freezeTemporaryTitle': 'Your account is temporarily frozen',
      'freezePermanentTitle': 'Your account is permanently frozen',
      'freezeTemporaryDesc':
          'The homepage is locked until the action period ends. You can only open report history and the appeal page.',
      'freezePermanentDesc':
          'The homepage is locked because of a permanent action. You can only open report history and the appeal page.',
      'remainingTime': 'Remaining time',
      'openReportHistory': 'Open Report History',
      'openAppealPage': 'Submit Appeal',
      'freezeReason': 'Report reason',
      'freezeAction': 'Action',
      'freezeAppeal': 'Appeal status',
      'goodMorning': 'Good morning,',
      'goodAfternoon': 'Good afternoon,',
      'goodEvening': 'Good evening,',
      'goodNight': 'Good night,',
      'todayAffirmation': 'For today',
      'points': 'Use points',
      'explorePremium': 'Explore premium plans',
      'premiumSubscribed': 'You are subscribed to Premium',
      'pickDate': 'Pick Date',
      'myDiary': 'View your diary',
      'publicDiary': 'Visit public diary',
      'dailyRoom': 'Daily Space',
      'moodAnalysis': 'View Your Mood Analysis',
      'moodAnalysisDesc': 'Open your weekly and monthly mood summary.',
      'todayDiary': 'Today\'s Diary',
      'todayDiaryDesc': 'Open the diary to write your note for today.',
      'selectedDiaryDesc':
          'Open the diary to view or write notes for this date.',
      'defaultTip': 'Take it slowly. Everything can be talked through later.',
      'tipHappy': 'Joy is valid. Enjoy it without guilt.',
      'tipNeutral': 'An ordinary day is still worth appreciating.',
      'tipSad': 'Slowly. A hard day does not mean you failed.',
      'tipAngry': 'Take a breath. Pausing is also a form of self-care.',
      'jan': 'Jan',
      'feb': 'Feb',
      'mar': 'Mar',
      'apr': 'Apr',
      'may': 'May',
      'jun': 'Jun',
      'jul': 'Jul',
      'aug': 'Aug',
      'sep': 'Sep',
      'oct': 'Oct',
      'nov': 'Nov',
      'dec': 'Dec',
      'moodlyUser': 'Moodly User',
      'streakLabel': 'Streak',
      'pointLabel': '{points} points',
      'premiumCta': 'Explore premium plans',
      'affirmationFallback':
          'You do not have to rush. Take a breath, then write what you need to let out.',
      'dayMin': 'Sun',
      'daySen': 'Mon',
      'daySel': 'Tue',
      'dayRab': 'Wed',
      'dayKam': 'Thu',
      'dayJum': 'Fri',
      'daySab': 'Sat',
      'monthFull1': 'January',
      'monthFull2': 'February',
      'monthFull3': 'March',
      'monthFull4': 'April',
      'monthFull5': 'May',
      'monthFull6': 'June',
      'monthFull7': 'July',
      'monthFull8': 'August',
      'monthFull9': 'September',
      'monthFull10': 'October',
      'monthFull11': 'November',
      'monthFull12': 'December',
      'howToday': 'How is your day going?',
      'howOnDate': 'How is your day on {date}?',
      'tellSlowly': 'Tell us gently, one step at a time.',
      'editMoodDate': 'Edit mood {date}',
      'fillMoodDate': 'Fill mood {date}',
      'premiumLockedTitle': 'Not available yet',
      'premiumLockedDesc':
          'Mood analysis for regular accounts opens every 1st day of the month. Premium can access it anytime.',
      'diaryOnDate': 'Diary {date}',
      'reportedPopupTitle': 'You have been reported',
      'categoryGratitude': 'Gratitude',
      'categoryAnxiety': 'Ease Anxiety',
      'categoryMotivation': 'Motivation',
      'categoryMentalHealth': 'Mental Health',
      'categorySelfLove': 'Self Love',
    },
  };

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  String _replace(String template, Map<String, String> values) {
    var result = template;
    values.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    return result;
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  bool _isPremiumUser = false;

  String? moodHariIni;
  String tipMood = '';
  String _affirmationPreview = '';
  String _affirmationCategory = '';

  DateTime selectedDate = DateTime.now();

  bool _hasUnreadNotifications = false;

  bool _isRefreshingModerationState = false;
  bool _isModerationDialogOpen = false;

  Map<String, dynamic>? _latestModerationItem;
  Map<String, dynamic>? _activeRestrictionItem;

  Timer? _restrictionTimer;
  Duration _restrictionRemaining = Duration.zero;

  static const String _lastShownReportCacheKeyPrefix =
      'moodly_last_shown_report_popup';

  bool get _isRestrictionActive =>
      _activeRestrictionItem != null &&
      UserAppealService.instance.isRestrictionActive(_activeRestrictionItem!);

  bool get _isTemporaryRestriction =>
      _activeRestrictionItem != null &&
      UserAppealService.instance.isTemporaryBan(_activeRestrictionItem!);

  bool get _isPermanentRestriction =>
      _activeRestrictionItem != null &&
      UserAppealService.instance.isPermanentBan(_activeRestrictionItem!);

  static const List<String> _homepageAfirmasiCategories = [
    'Rasa Syukur',
    'Meredakan Kecemasan',
    'Motivasi',
    'Kesehatan Mental',
    'Cinta Diri',
  ];

  bool get _hasSelectedMood =>
      moodHariIni != null && moodHariIni!.trim().isNotEmpty;

  bool get _canOpenMoodAnalysis {
    if (_isPremiumUser) return true;
    return DateTime.now().day == 1;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _syncHomepageState();
    _bootstrapSignals();
    _loadPremiumStatus();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _restrictionTimer?.cancel();
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _bootstrapSignals();
    }
  }

  Future<void> _bootstrapSignals() async {
    await MoodlyNotificationService.instance.syncForCurrentUser();
    await _refreshModerationState(showPopupIfNeeded: true);
  }

  Future<void> _loadPremiumStatus() async {
    try {
      await PremiumService.instance.refreshPremiumStatus();
      final access = await PremiumService.instance.getAccess();

      if (!mounted) return;
      setState(() {
        _isPremiumUser = access.hasPremiumAccess;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isPremiumUser = false;
      });
    }
  }

  String _shownPopupCacheKey() =>
      '${_lastShownReportCacheKeyPrefix}_${_uid ?? 'guest'}';

  Future<void> _refreshModerationState({
    bool showPopupIfNeeded = false,
  }) async {
    if (_isRefreshingModerationState) return;
    _isRefreshingModerationState = true;

    try {
      final latestItem = await UserAppealService.instance.getLatestActiveAction();
      final restrictionItem =
          await UserAppealService.instance.getLatestRestrictionAction();

      if (!mounted) return;

      setState(() {
        _latestModerationItem = latestItem;
        _activeRestrictionItem = restrictionItem;
        _restrictionRemaining = restrictionItem != null
            ? UserAppealService.instance
                .getRemainingRestrictionDuration(restrictionItem)
            : Duration.zero;
      });

      _syncRestrictionTimer();

      if (showPopupIfNeeded && latestItem != null) {
        await _showModerationDialogIfNeeded(latestItem);
      }
    } finally {
      _isRefreshingModerationState = false;
    }
  }

  void _syncRestrictionTimer() {
    _restrictionTimer?.cancel();

    if (!_isTemporaryRestriction || _activeRestrictionItem == null) {
      return;
    }

    _restrictionRemaining = UserAppealService.instance
        .getRemainingRestrictionDuration(_activeRestrictionItem!);

    _restrictionTimer = Timer.periodic(const Duration(seconds: 1), (_) async {
      if (!mounted || _activeRestrictionItem == null) return;

      final remaining = UserAppealService.instance
          .getRemainingRestrictionDuration(_activeRestrictionItem!);

      if (remaining <= Duration.zero) {
        _restrictionTimer?.cancel();

        if (!mounted) return;
        setState(() {
          _restrictionRemaining = Duration.zero;
        });

        await _refreshModerationState(showPopupIfNeeded: false);
        return;
      }

      if (!mounted) return;
      setState(() {
        _restrictionRemaining = remaining;
      });
    });
  }

  String _twoDigits(int value) => value.toString().padLeft(2, '0');

  String _formatRestrictionRemaining() {
    final duration = _restrictionRemaining;

    final days = duration.inDays;
    final hours = duration.inHours.remainder(24);
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (days > 0) {
      return _languageCode == 'en'
          ? '$days day ${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}'
          : '$days hari ${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
    }

    return '${_twoDigits(hours)}:${_twoDigits(minutes)}:${_twoDigits(seconds)}';
  }

  Future<void> _showModerationDialogIfNeeded(
    Map<String, dynamic> item,
  ) async {
    if (!mounted || _isModerationDialogOpen) return;

    final prefs = await SharedPreferences.getInstance();
    final fingerprint = UserAppealService.instance.buildPopupFingerprint(item);
    final lastShown = prefs.getString(_shownPopupCacheKey());

    if (lastShown == fingerprint) return;

    await prefs.setString(_shownPopupCacheKey(), fingerprint);

    final actionLabel = UserAppealService.instance.buildCurrentActionLabel(item);
    final appealLabel = UserAppealService.instance.buildAppealStatusLabel(item);
    final reportTitle = UserAppealService.instance.buildReportTitle(item);
    final reportSummary = UserAppealService.instance.buildReportSummary(item);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || _isModerationDialogOpen) return;

      _isModerationDialogOpen = true;

      try {
        await showDialog(
          context: context,
          barrierColor: Colors.black.withOpacity(0.38),
          builder: (_) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 76,
                      height: 76,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pinkSoft,
                      ),
                      child: const Icon(
                        Icons.shield_rounded,
                        size: 36,
                        color: _greenDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _t('reportedPopupTitle'),
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 22,
                            color: _textDark,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      reportTitle,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _textDark,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      reportSummary,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _textSoft,
                            height: 1.45,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _pinkSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            actionLabel,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _greenSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            appealLabel,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            style: TextButton.styleFrom(
                              backgroundColor: _pinkSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _t('later'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              Navigator.pop(context);
                              await _openReportHistoryFromFreeze();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _t('viewDetail'),
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
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
      } finally {
        _isModerationDialogOpen = false;
      }
    });
  }

  Future<void> _openReportHistoryFromFreeze() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReportHistoryPage(),
      ),
    );

    if (!mounted) return;
    await _refreshModerationState(showPopupIfNeeded: false);
  }

  Future<void> _openAppealFromFreeze() async {
    final target = _latestModerationItem ?? _activeRestrictionItem;
    if (target == null) return;

    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AjukanBandingPage(report: target),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await _refreshModerationState(showPopupIfNeeded: false);
    }
  }

  String _restrictionTitle() {
    if (_isPermanentRestriction) return _t('freezePermanentTitle');
    return _t('freezeTemporaryTitle');
  }

  String _restrictionDescription() {
    if (_isPermanentRestriction) return _t('freezePermanentDesc');
    return _t('freezeTemporaryDesc');
  }

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return _t('goodMorning');
    if (hour >= 11 && hour < 15) return _t('goodAfternoon');
    if (hour >= 15 && hour < 18) return _t('goodEvening');
    return _t('goodNight');
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String? get _uid => FirebaseAuth.instance.currentUser?.uid;

  String _moodPrefKey(String uid, String dateKey) => 'mood_${uid}_$dateKey';
  String _notePrefKey(String uid, String dateKey) => 'note_${uid}_$dateKey';

  DocumentReference<Map<String, dynamic>> _moodDoc(String uid) {
    return FirebaseFirestore.instance.collection('moods').doc(uid);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _selectedDateLabel() {
    final months = [
      _t('jan'),
      _t('feb'),
      _t('mar'),
      _t('apr'),
      _t('may'),
      _t('jun'),
      _t('jul'),
      _t('aug'),
      _t('sep'),
      _t('oct'),
      _t('nov'),
      _t('dec'),
    ];
    return '${selectedDate.day} ${months[selectedDate.month - 1]}';
  }

  String _localizedAffirmationCategory(String raw) {
    switch (raw.trim()) {
      case 'Rasa Syukur':
        return _t('categoryGratitude');
      case 'Meredakan Kecemasan':
        return _t('categoryAnxiety');
      case 'Motivasi':
        return _t('categoryMotivation');
      case 'Kesehatan Mental':
        return _t('categoryMentalHealth');
      case 'Cinta Diri':
        return _t('categorySelfLove');
      default:
        return raw.trim().isEmpty ? _t('todayAffirmation') : raw.trim();
    }
  }

  String _defaultTipForMood(String? mood) {
    switch (mood) {
      case 'Senang':
        return _t('tipHappy');
      case 'Netral':
        return _t('tipNeutral');
      case 'Sedih':
        return _t('tipSad');
      case 'Marah':
        return _t('tipAngry');
      default:
        return _t('defaultTip');
    }
  }

  String? _moodBadgeAsset(String? mood) {
    switch (mood) {
      case 'Senang':
        return 'assets/emoji/emoji_senang.png';
      case 'Netral':
        return 'assets/emoji/emoji_netral.png';
      case 'Sedih':
        return 'assets/emoji/emoji_sedih.png';
      case 'Marah':
        return 'assets/emoji/emoji_marah.png';
      default:
        return null;
    }
  }

  Color _moodBadgeBg(String? mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFF8CF52);
      case 'Netral':
        return const Color(0xFFE4EF84);
      case 'Sedih':
        return const Color(0xFF9DEFF1);
      case 'Marah':
        return const Color(0xFFF06E7F);
      default:
        return Colors.transparent;
    }
  }

  Color _moodRingColor(String? mood) {
    switch (mood) {
      case 'Senang':
        return const Color(0xFFF8B658);
      case 'Netral':
        return const Color(0xFF9DCB7B);
      case 'Sedih':
        return const Color(0xFF8DD9E8);
      case 'Marah':
        return const Color(0xFFE8A3AE);
      default:
        return const Color(0xFFE8CFC7);
    }
  }

  LinearGradient _profileGradientForMood(String? mood) {
    switch (mood) {
      case 'Marah':
        return const LinearGradient(
          colors: [Color(0xFFEFCACC), Color(0xFFFFE6C3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Sedih':
        return const LinearGradient(
          colors: [Color(0xFFCEF2FF), Color(0xFFCCFFE6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Senang':
        return const LinearGradient(
          colors: [Color(0xFFF8B658), Color(0xFFEFCACC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'Netral':
        return const LinearGradient(
          colors: [Color(0xFFB5E0A6), Color(0xFFF3FADC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return const LinearGradient(
          colors: [Color(0xFFF3CDD3), Color(0xFFEBDCC4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Future<void> _syncHomepageState() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();

    if (!mounted) return;

    setState(() {
      _languageCode = language == 'en' ? 'en' : 'id';
      _affirmationPreview = _t('affirmationFallback');
      _affirmationCategory = _t('todayAffirmation');
    });

    await _loadSelectedDateMood();
    await _loadHomepageAffirmationPreview();
  }

  Future<void> _loadSelectedDateMood() async {
    final key = _dateKey(selectedDate);

    String? mood;
    String? note;

    try {
      final uid = _uid;
      if (uid == null) {
        if (!mounted) return;
        setState(() {
          moodHariIni = null;
          tipMood = _defaultTipForMood(null);
        });
        return;
      }

      final prefs = await SharedPreferences.getInstance();

      mood = prefs.getString(_moodPrefKey(uid, key));
      note = prefs.getString(_notePrefKey(uid, key));

      if ((mood == null || mood.trim().isEmpty) || note == null) {
        final doc = await _moodDoc(uid).get();

        if (doc.exists) {
          final data = doc.data();
          final entries = data?['entries'] as Map<String, dynamic>? ?? {};
          final notes = data?['notes'] as Map<String, dynamic>? ?? {};

          mood ??= entries[key]?.toString();
          note ??= notes[key]?.toString();
        }
      }
    } catch (_) {
      // sengaja diam, biar UI tetap hidup
    }

    if (!mounted) return;

    setState(() {
      moodHariIni =
          (mood != null && mood.trim().isNotEmpty) ? mood.trim() : null;
      tipMood = _defaultTipForMood(moodHariIni);
    });
  }

  Future<void> _loadHomepageAffirmationPreview() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _dateKey(DateTime.now());

      final cachedDate = prefs.getString('homepage_afirmasi_date');
      final cachedText = prefs.getString('homepage_afirmasi_text');
      final cachedCategory = prefs.getString('homepage_afirmasi_category');

      if (cachedDate == todayKey &&
          cachedText != null &&
          cachedText.trim().isNotEmpty) {
        if (!mounted) return;
        setState(() {
          _affirmationPreview = cachedText;
          _affirmationCategory = _localizedAffirmationCategory(
            cachedCategory ?? _t('todayAffirmation'),
          );
        });
        return;
      }

      final items = await AfirmasiService.getAfirmasiByCategories(
        _homepageAfirmasiCategories,
      );

      if (items.isEmpty) {
        if (!mounted) return;
        setState(() {
          _affirmationPreview = _t('affirmationFallback');
          _affirmationCategory = _t('todayAffirmation');
        });
        return;
      }

      items.shuffle();
      final picked = items.first;

      final text = (picked['teks'] ?? '').trim();
      final category = (picked['kategori'] ?? _t('todayAffirmation')).trim();

      await prefs.setString('homepage_afirmasi_date', todayKey);
      await prefs.setString('homepage_afirmasi_text', text);
      await prefs.setString('homepage_afirmasi_category', category);

      if (!mounted) return;
      setState(() {
        _affirmationPreview =
            text.isNotEmpty ? text : _t('affirmationFallback');
        _affirmationCategory = _localizedAffirmationCategory(category);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _affirmationPreview = _t('affirmationFallback');
        _affirmationCategory = _t('todayAffirmation');
      });
    }
  }

  static const Color _bg = Color(0xFFF5F8EC);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF84C96C);
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _greenMint = Color(0xFFEEF7E6);
  static const Color _pink = Color(0xFFF3C9D1);
  static const Color _pinkSoft = Color(0xFFFFF0F3);
  static const Color _blueSoft = Color(0xFFDDF5FB);
  static const Color _peach = Color(0xFFFFE9DE);
  static const Color _premiumA = Color(0xFFFFC77A);
  static const Color _premiumB = Color(0xFFFF9A62);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF677164);

  List<BoxShadow> get _softShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];

  void _goToPage(
    Widget page, {
    bool allowDuringRestriction = false,
  }) {
    if (_isRestrictionActive && !allowDuringRestriction) return;

    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openAfirmasiFlow() async {
    final targetPage = await AfirmasiPage.resolveEntryPage();

    if (!mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetPage),
    );

    if (!mounted) return;

    setState(() => _currentNavIndex = 0);
    await _loadHomepageAffirmationPreview();
  }

  Future<void> _openMoodInput() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodInput(
          selectedDate: selectedDate,
          initialMood: moodHariIni,
        ),
      ),
    );

    if (!mounted) return;

    await _loadSelectedDateMood();
    await MoodlyNotificationService.instance.syncForCurrentUser();
  }

  Future<void> _openMoodCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MoodCalendar(
          initialYear: selectedDate.year,
          initialMonth: selectedDate.month,
        ),
      ),
    );

    if (!mounted) return;

    if (result is DateTime) {
      setState(() => selectedDate = result);
    }

    await _loadSelectedDateMood();
    await MoodlyNotificationService.instance.syncForCurrentUser();
  }

  Future<void> _pickDate() async {
    await _openMoodCalendar();
  }

  Future<void> _onNavbarTap(int index) async {
    if (_isRestrictionActive) return;

    if (index == 0) {
      if (_currentNavIndex != 0) {
        setState(() => _currentNavIndex = 0);
      }
      return;
    }

    Widget? targetPage;

    switch (index) {
      case 1:
        targetPage = const SelectedDiaryPage();
        break;
      case 3:
        targetPage = const HomeChatAnonim();
        break;
      case 4:
        await _openAfirmasiFlow();
        return;
    }

    if (targetPage == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => targetPage!),
    );

    if (!mounted) return;
    setState(() => _currentNavIndex = 0);
  }

  void _onEmergencyTap() {
    if (_isRestrictionActive) return;
    _goToPage(const EmergencySupportPage());
  }

  String _monthLabel(DateTime date) {
    final months = [
      _t('monthFull1'),
      _t('monthFull2'),
      _t('monthFull3'),
      _t('monthFull4'),
      _t('monthFull5'),
      _t('monthFull6'),
      _t('monthFull7'),
      _t('monthFull8'),
      _t('monthFull9'),
      _t('monthFull10'),
      _t('monthFull11'),
      _t('monthFull12'),
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  String _weekdayLabel(DateTime date) {
    const labels = [
      'dayMin',
      'daySen',
      'daySel',
      'dayRab',
      'dayKam',
      'dayJum',
      'daySab',
    ];
    return _t(labels[date.weekday % 7]);
  }

  List<DateTime> _weekDates(DateTime anchor) {
    final start = anchor.subtract(Duration(days: anchor.weekday % 7));
    return List.generate(7, (index) => start.add(Duration(days: index)));
  }

  Widget _glassIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.86),
          shape: BoxShape.circle,
          boxShadow: _softShadow,
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, size: 22, color: _greenDark)),
            if (showDot)
              Positioned(
                right: 10,
                top: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE85E73),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _profileAvatar() {
    final badgeAsset = _moodBadgeAsset(moodHariIni);
    final ringColor = _moodRingColor(moodHariIni);

    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: MoodlyInventoryFrameAvatar(
              uid: FirebaseAuth.instance.currentUser?.uid,
              size: 80,
              innerPadding: 4,
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: MoodlyUserAvatar(
                    uid: FirebaseAuth.instance.currentUser?.uid,
                    radius: 36,
                    backgroundColor: Colors.transparent,
                    borderWidth: 0,
                    borderColor: Colors.transparent,
                    placeholderAsset: 'assets/profile_pic/PP_default.jpg',
                  ),
                ),
              ),
            ),
          ),
          if (badgeAsset != null)
            Positioned(
              left: -2,
              bottom: 8,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _moodBadgeBg(moodHariIni),
                  shape: BoxShape.circle,
                  border: Border.all(color: ringColor, width: 3),
                  boxShadow: _softShadow,
                ),
                child: ClipOval(
                  child: Image.asset(
                    badgeAsset,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerUserName() {
    final authUser = FirebaseAuth.instance.currentUser;
    final uid = authUser?.uid;

    final textStyle = AppText.title(context).copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: Colors.black,
    );

    if (uid == null) {
      return Text(_t('moodlyUser'), style: textStyle);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        final fullName = (data?['fullName'] as String?)?.trim();
        final nickname = (data?['nickname'] as String?)?.trim();
        final displayName = authUser?.displayName?.trim();
        final email = authUser?.email?.trim();

        final resolvedName =
            (fullName != null && fullName.isNotEmpty)
                ? fullName
                : (nickname != null && nickname.isNotEmpty)
                    ? nickname
                    : (displayName != null && displayName.isNotEmpty)
                        ? displayName
                        : (email != null && email.isNotEmpty)
                            ? email.split('@').first
                            : _t('moodlyUser');

        return Text(
          resolvedName,
          style: textStyle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
    );
  }

  Widget _headerSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _glassIconButton(
                    icon: Icons.settings_rounded,
                    onTap: () => _goToPage(const SettingsPage()),
                  ),
                  const SizedBox(width: 10),
                  StreamBuilder<int>(
                    stream: MoodlyNotificationService.instance
                        .unreadCountStream(),
                    builder: (context, snapshot) {
                      final unread = (snapshot.data ?? 0) > 0;

                      return _glassIconButton(
                        icon: Icons.notifications_rounded,
                        onTap: () async {
                          await MoodlyNotificationService.instance
                              .syncForCurrentUser();
                          if (!mounted) return;
                          _goToPage(const NotificationPage());
                        },
                        showDot: unread,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                _greetingText,
                style: AppText.subtitle(context).copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 4),
              _headerUserName(),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _profileAvatar(),
      ],
    );
  }

  Widget _streakFlame({
    required int streakCount,
    required bool isStreakLitToday,
  }) {
    final double flameSize = isStreakLitToday ? 62 : 42;
    final double flameOpacity = isStreakLitToday ? 1.0 : 0.28;
    final double countOpacity = isStreakLitToday ? 1.0 : 0.0;

    final String assetPath = isStreakLitToday
        ? 'assets/homepage_assets/streak_moving.gif'
        : 'assets/homepage_assets/streak_static.png';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: 72,
      height: 74,
      alignment: Alignment.center,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 220),
        opacity: flameOpacity,
        child: AnimatedScale(
          duration: const Duration(milliseconds: 240),
          scale: isStreakLitToday ? 1.0 : 0.82,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                child: Image.asset(
                  assetPath,
                  key: ValueKey(assetPath),
                  width: flameSize,
                  height: flameSize,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Text(
                      '🔥',
                      style: TextStyle(fontSize: flameSize * 0.82),
                    );
                  },
                ),
              ),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: countOpacity,
                child: Transform.translate(
                  offset: const Offset(0, 6),
                  child: Text(
                    '$streakCount',
                    style: AppText.bodyAlt(context).copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      shadows: const [
                        Shadow(
                          color: Color(0x66000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _streakCommandSection() {
    return StreamBuilder<StreakState>(
      stream: StreakService.instance.watchState(),
      builder: (context, snapshot) {
        final streakState = snapshot.data ?? StreakState.initial();
        final liveStreakCount = streakState.currentStreak;
        final liveIsStreakLitToday = streakState.moodDoneToday;
        final points = streakState.totalPoints;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _card,
            borderRadius: BorderRadius.circular(26),
            boxShadow: _softShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => _goToPage(const StreakPage()),
                child: Container(
                  width: 90,
                  height: 104,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: _softShadow,
                  ),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Positioned(
                        left: -8,
                        top: 10,
                        child: Transform.rotate(
                          angle: -0.58,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 13,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFECCFD6),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _softShadow,
                            ),
                            child: Text(
                              _t('streakLabel'),
                              style: AppText.bodyAlt(context).copyWith(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4E4247),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: _streakFlame(
                            streakCount: liveStreakCount,
                            isStreakLitToday: liveIsStreakLitToday,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SizedBox(
                  height: 104,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 50,
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _greenMint,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.stars_rounded,
                                      size: 18,
                                      color: _greenDark,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _replace(_t('pointLabel'), {'points': '$points'}),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppText.bodyAlt(context)
                                            .copyWith(
                                              fontSize: 15,
                                              color: _greenDark,
                                              fontWeight: FontWeight.w800,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: GestureDetector(
                                onTap: () =>
                                    _goToPage(RewardPage(totalPoints: points)),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _pinkSoft,
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.redeem_rounded,
                                        size: 17,
                                        color: _textDark,
                                      ),
                                      const SizedBox(width: 6),
                                      Flexible(
                                        child: Text(
                                          _t('points'),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppText.bodyAlt(context)
                                              .copyWith(
                                                fontSize: 11.5,
                                                color: _textDark,
                                                fontWeight: FontWeight.w800,
                                              ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          await openMoodlyPremiumPage(
                            context,
                            source: PremiumEntrySource.home,
                          );

                          if (!mounted) return;
                          await _loadPremiumStatus();
                        },
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: _isPremiumUser
                                ? null
                                : const LinearGradient(
                                    colors: [_premiumA, _premiumB],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                            color: _isPremiumUser ? _greenSoft : null,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _softShadow,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              Icon(
                                _isPremiumUser
                                    ? Icons.verified_rounded
                                    : Icons.workspace_premium_rounded,
                                color: _isPremiumUser ? _greenDark : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _isPremiumUser
                                      ? _t('premiumSubscribed')
                                      : _t('premiumCta'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyAlt(context).copyWith(
                                    fontSize: 12,
                                    color: _isPremiumUser ? _greenDark : Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: _isPremiumUser ? _greenDark : Colors.white,
                              ),
                            ],
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
      },
    );
  }

  Widget _calendarNavigator() {
    final week = _weekDates(selectedDate);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(28),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              _navCircle(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () async {
                  setState(() {
                    selectedDate = selectedDate.subtract(
                      const Duration(days: 7),
                    );
                  });
                  await _loadSelectedDateMood();
                },
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 42,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: _softShadow,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _monthLabel(selectedDate),
                    style: AppText.subtitle(context).copyWith(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              _navCircle(
                icon: Icons.arrow_forward_ios_rounded,
                onTap: () async {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 7));
                  });
                  await _loadSelectedDateMood();
                },
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _pickDate,
                child: Container(
                  height: 42,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: _card,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: _softShadow,
                  ),
                  child: Row(
                    children: [
                      Text(
                        _t('pickDate'),
                        style: AppText.bodyAlt(context).copyWith(
                          fontSize: 13,
                          color: const Color(0xFF65516A),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: _greenSoft,
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: const Icon(
                          Icons.calendar_today_rounded,
                          size: 14,
                          color: _greenDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: week
                .map(
                  (date) => Expanded(
                    child: Column(
                      children: [
                        Text(
                          _weekdayLabel(date),
                          style: AppText.bodyAlt(context).copyWith(
                            fontSize: 12,
                            color: const Color(0xFF6B6A68),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _dayChip(date),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _navCircle({required IconData icon, required VoidCallback onTap}) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: _green,
        shape: BoxShape.circle,
        boxShadow: _softShadow,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onTap,
        icon: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }

  Widget _dayChip(DateTime date) {
    final isSelected =
        date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    return GestureDetector(
      onTap: () async {
        setState(() => selectedDate = date);
        await _loadSelectedDateMood();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        width: 42,
        height: isSelected ? 56 : 46,
        margin: EdgeInsets.only(top: isSelected ? 0 : 10),
        decoration: BoxDecoration(
          color: isSelected ? _green : _greenSoft,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _softShadow,
        ),
        child: Center(
          child: Text(
            '${date.day}',
            style: AppText.title(context).copyWith(
              fontSize: isSelected ? 24 : 22,
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: AppText.subtitle(
        context,
      ).copyWith(fontSize: 20, color: _textDark, fontWeight: FontWeight.w800),
    );
  }

  Widget _diaryBridgeSection() {
    return Column(
      children: [
        GestureDetector(
          onTap: _openAfirmasiFlow,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _softShadow,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _pinkSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: _greenDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _affirmationCategory.isNotEmpty
                            ? _affirmationCategory
                            : _t('todayAffirmation'),
                        style: AppText.bodyAlt(context).copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _affirmationPreview,
                        style: AppText.body(context).copyWith(
                          fontSize: 12,
                          color: _textSoft,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: _textDark,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _bridgeButton(
                label: _t('myDiary'),
                icon: Icons.lock_outline_rounded,
                bg: _peach,
                onTap: () => _goToPage(const MonthPage()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _bridgeButton(
                label: _t('publicDiary'),
                icon: Icons.public_rounded,
                bg: _greenMint,
                onTap: () => _goToPage(const PublicDiaryPage()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _bridgeButton({
    required String label,
    required IconData icon,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 58,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: _greenDark),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: AppText.bodyAlt(context).copyWith(
                  fontSize: 12,
                  color: _textDark,
                  fontWeight: FontWeight.w800,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodCluster() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 11, child: _bigMoodCard()),
        const SizedBox(width: 12),
        Expanded(
          flex: 10,
          child: Column(
            children: [
              _moodGraphCard(),
              const SizedBox(height: 12),
              _diaryReminderCard(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _bigMoodCard() {
    final isToday = _isSameDay(selectedDate, DateTime.now());

    return GestureDetector(
      onTap: _openMoodInput,
      child: Container(
        height: 258,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: _blueSoft,
          boxShadow: _softShadow,
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildMoodCardBackground(
                  imagePath: 'assets/homepage_assets/background_input_mood.png',
                ),
              ),
            ),
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isToday
                        ? _t('howToday')
                        : _replace(_t('howOnDate'), {'date': _selectedDateLabel()}),
                    style: AppText.subtitle(context).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasSelectedMood ? tipMood : _t('tellSlowly'),
                    style: AppText.body(context).copyWith(
                      fontSize: 13,
                      color: const Color(0xFF6A6A6A),
                      height: 1.45,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 114,
              child: Center(
                child: Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: _softShadow,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _hasSelectedMood
                      ? _replace(_t('editMoodDate'), {'date': _selectedDateLabel()})
                      : _replace(_t('fillMoodDate'), {'date': _selectedDateLabel()}),
                  style: AppText.bodyAlt(context).copyWith(
                    fontSize: 11,
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodCardBackground({String? imagePath}) {
    if (imagePath != null && imagePath.isNotEmpty) {
      return Image.asset(
        imagePath,
        fit: BoxFit.cover,
        alignment: Alignment.center,
        errorBuilder: (_, __, ___) => _defaultBeachBackground(),
      );
    }

    return _defaultBeachBackground();
  }

  Widget _defaultBeachBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFEFFF), Color(0xFF6EDCFF), Color(0xFFF2D47D)],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            left: 12,
            bottom: 14,
            child: Text('🌴', style: TextStyle(fontSize: 42)),
          ),
          Positioned(
            right: 12,
            bottom: 18,
            child: Text('🕶️', style: TextStyle(fontSize: 26)),
          ),
        ],
      ),
    );
  }

  Widget _moodGraphCard() {
    return GestureDetector(
      onTap: () {
        if (!_canOpenMoodAnalysis) {
          showCuteTopPopup(
            context,
            title: _t('premiumLockedTitle'),
            message: _t('premiumLockedDesc'),
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

        _goToPage(const MoodAnalysis());
      },
      child: Container(
        height: 156,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _softShadow,
        ),
        child: Column(
          children: [
            Container(
              height: 38,
              decoration: const BoxDecoration(
                color: Color(0xFFCBE8B9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _t('moodAnalysis'),
                      style: AppText.bodyAlt(context).copyWith(
                        fontSize: 12.5,
                        color: _textDark,
                        fontWeight: FontWeight.w800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const Icon(
                    Icons.insights_rounded,
                    size: 18,
                    color: _greenDark,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _t('moodAnalysisDesc'),
                      style: AppText.body(context).copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6A6A6A),
                        height: 1.4,
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _greenMint,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            size: 14,
                            color: _greenDark,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _monthLabel(selectedDate),
                            style: AppText.bodyAlt(context).copyWith(
                              fontSize: 11,
                              color: _greenDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _diaryCardTitle() {
    return _isSameDay(selectedDate, DateTime.now())
        ? _t('todayDiary')
        : _replace(_t('diaryOnDate'), {'date': _selectedDateLabel()});
  }

  String _diaryCardText() {
    return _isSameDay(selectedDate, DateTime.now())
        ? _t('todayDiaryDesc')
        : _t('selectedDiaryDesc');
  }

  Widget _diaryReminderCard() {
    return GestureDetector(
      onTap: () => _goToPage(const AddDiaryPage()),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(24),
          boxShadow: _softShadow,
        ),
        child: Column(
          children: [
            Container(
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFCBE8B9),
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _diaryCardTitle(),
                      style: AppText.bodyAlt(context).copyWith(
                        fontSize: 13,
                        color: _textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.edit_note_rounded,
                    size: 18,
                    color: _greenDark,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _diaryCardText(),
                        style: AppText.body(context).copyWith(
                          fontSize: 12,
                          color: const Color(0xFF555555),
                          height: 1.35,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: Color(0xFF555555),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestrictionOverlay() {
    final item = _activeRestrictionItem;
    if (item == null) return const SizedBox.shrink();

    final actionLabel = UserAppealService.instance.buildCurrentActionLabel(item);
    final appealLabel = UserAppealService.instance.buildAppealStatusLabel(item);
    final reportSummary = UserAppealService.instance
        .buildReportSummary(_latestModerationItem ?? item);

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.34),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: _softShadow,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 82,
                      height: 82,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _pinkSoft,
                      ),
                      child: Icon(
                        _isPermanentRestriction
                            ? Icons.gpp_bad_rounded
                            : Icons.lock_clock_rounded,
                        size: 40,
                        color: _greenDark,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _restrictionTitle(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontSize: 24,
                            color: _textDark,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _restrictionDescription(),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _textSoft,
                            height: 1.5,
                          ),
                    ),
                    const SizedBox(height: 14),
                    if (_isTemporaryRestriction) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: _greenMint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _t('remainingTime'),
                              style:
                                  Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: _greenDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatRestrictionRemaining(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    fontSize: 22,
                                    color: _greenDark,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _pinkSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_t('freezeAction')}: $actionLabel',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: _greenSoft,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            '${_t('freezeAppeal')}: $appealLabel',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: _card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: _greenSoft),
                      ),
                      child: Text(
                        '${_t('freezeReason')}: $reportSummary',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: _textSoft,
                              height: 1.45,
                            ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: _openReportHistoryFromFreeze,
                            style: TextButton.styleFrom(
                              backgroundColor: _pinkSoft,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _t('openReportHistory'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _openAppealFromFreeze,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: Text(
                              _t('openAppealPage'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.labelLarge,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const OnboardingPage();
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: _homeSystemUi,
      child: WillPopScope(
        onWillPop: () async => !_isRestrictionActive,
        child: Scaffold(
          backgroundColor: _bg,
          body: Stack(
            children: [
              Positioned(
                top: -50,
                right: -30,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pinkSoft.withOpacity(0.52),
                  ),
                ),
              ),
              Positioned(
                top: 210,
                left: -65,
                child: Container(
                  width: 170,
                  height: 170,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greenMint.withOpacity(0.75),
                  ),
                ),
              ),
              Positioned(
                bottom: 120,
                right: -70,
                child: Container(
                  width: 230,
                  height: 230,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _greenSoft.withOpacity(0.55),
                  ),
                ),
              ),
              SafeArea(
                child: ScrollConfiguration(
                  behavior: const _SoftScrollBehavior(),
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _headerSection(),
                              const SizedBox(height: 18),
                              _streakCommandSection(),
                              const SizedBox(height: 18),
                              _calendarNavigator(),
                              const SizedBox(height: 18),
                              _diaryBridgeSection(),
                              const SizedBox(height: 18),
                              _sectionHeader(_t('dailyRoom')),
                              const SizedBox(height: 12),
                              _moodCluster(),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_isRestrictionActive) _buildRestrictionOverlay(),
            ],
          ),
          bottomNavigationBar: IgnorePointer(
            ignoring: _isRestrictionActive,
            child: Opacity(
              opacity: _isRestrictionActive ? 0.45 : 1,
              child: MoodlyBottomNavbar(
                currentIndex: _currentNavIndex,
                onTap: _onNavbarTap,
                onEmergencyTap: _onEmergencyTap,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<Offset> points;
  final Color color;

  const _LineChartPainter({required this.points, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final p = Offset(size.width * points[i].dx, size.height * points[i].dy);

      if (i == 0) {
        path.moveTo(p.dx, p.dy);
      } else {
        path.lineTo(p.dx, p.dy);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.color != color;
  }
}

class _SoftScrollBehavior extends ScrollBehavior {
  const _SoftScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}
