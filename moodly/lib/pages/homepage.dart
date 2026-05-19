import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/styles/app_text.dart';
import '../core/services/moodly_notification_service.dart';
import '../widgets/shared/moodly_user_avatar.dart';
import '../core/services/streak_service.dart';
import '../widgets/moodly_bottom_navbar.dart';
import '../services/afirmasi/afirmasi_service.dart';
import 'afirmasi/widgets/cute_top_popup.dart';
import 'pages.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentNavIndex = 0;

  String? moodHariIni;
  String tipMood = 'Pelan-pelan ya, semuanya bisa dibicarakan nanti.';
  String _affirmationPreview =
      'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.';
  String _affirmationCategory = 'Untuk hari ini';

  DateTime selectedDate = DateTime.now();

  bool _hasUnreadNotifications = false;

  static const String _moodDocumentId = 'BeZzql14Y8xGyoLUDb0L';

  static const List<String> _homepageAfirmasiCategories = [
    'Rasa Syukur',
    'Meredakan Kecemasan',
    'Motivasi',
    'Kesehatan Mental',
    'Cinta Diri',
  ];

  bool get _hasSelectedMood =>
      moodHariIni != null && moodHariIni!.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _syncHomepageState();
    _bootstrapSignals();
  }

  Future<void> _bootstrapSignals() async {
    await MoodlyNotificationService.instance.syncForCurrentUser();
  }

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  String _dateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String _selectedDateLabel() {
    const months = [
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
    return '${selectedDate.day} ${months[selectedDate.month - 1]}';
  }

  String _defaultTipForMood(String? mood) {
    switch (mood) {
      case 'Senang':
        return 'Senang itu valid. Nikmati tanpa merasa bersalah.';
      case 'Netral':
        return 'Hari yang biasa tetap layak dihargai.';
      case 'Sedih':
        return 'Pelan-pelan. Hari berat tidak membuatmu gagal.';
      case 'Marah':
        return 'Tarik napas. Jeda sebentar juga bentuk merawat diri.';
      default:
        return 'Pelan-pelan ya, semuanya bisa dibicarakan nanti.';
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
    await _loadSelectedDateMood();
    await _loadHomepageAffirmationPreview();
  }

  Future<void> _loadSelectedDateMood() async {
    final key = _dateKey(selectedDate);

    String? mood;
    String? note;

    try {
      final prefs = await SharedPreferences.getInstance();

      mood = prefs.getString('mood_$key');
      note = prefs.getString('note_$key');

      if (mood == null || mood.trim().isEmpty || note == null) {
        final doc = await FirebaseFirestore.instance
            .collection('moods')
            .doc(_moodDocumentId)
            .get();

        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>?;
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
      moodHariIni = (mood != null && mood.trim().isNotEmpty)
          ? mood.trim()
          : null;
      tipMood = (note != null && note.trim().isNotEmpty)
          ? note.trim()
          : _defaultTipForMood(moodHariIni);
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
          _affirmationCategory = cachedCategory ?? 'Untuk hari ini';
        });
        return;
      }

      final items = await AfirmasiService.getAfirmasiByCategories(
        _homepageAfirmasiCategories,
      );

      if (items.isEmpty) {
        if (!mounted) return;
        setState(() {
          _affirmationPreview =
              'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.';
          _affirmationCategory = 'Untuk hari ini';
        });
        return;
      }

      items.shuffle();
      final picked = items.first;

      final text = (picked['teks'] ?? '').trim();
      final category = (picked['kategori'] ?? 'Untuk hari ini').trim();

      await prefs.setString('homepage_afirmasi_date', todayKey);
      await prefs.setString('homepage_afirmasi_text', text);
      await prefs.setString('homepage_afirmasi_category', category);

      if (!mounted) return;
      setState(() {
        _affirmationPreview = text.isNotEmpty
            ? text
            : 'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.';
        _affirmationCategory = category.isNotEmpty
            ? category
            : 'Untuk hari ini';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _affirmationPreview =
            'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.';
        _affirmationCategory = 'Untuk hari ini';
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

  void _goToPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  Future<void> _openMoodInput() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => MoodInput(selectedDate: selectedDate)),
    );

    if (!mounted) return;

    await _loadSelectedDateMood();
    await MoodlyNotificationService.instance.syncForCurrentUser();
  }

  Future<void> _openMoodCalendar() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodYearCalendar()),
    );

    if (!mounted) return;

    if (result is DateTime) {
      setState(() => selectedDate = result);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020, 1, 1),
      lastDate: DateTime(2030, 12, 31),
    );

    if (picked == null) return;

    setState(() {
      selectedDate = picked;
    });

    await _loadSelectedDateMood();
  }

  Future<void> _onNavbarTap(int index) async {
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
        targetPage = const AfirmasiPage();
        break;
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
    _goToPage(const EmergencySupportPage());
  }

  String _monthLabel(DateTime date) {
    const months = [
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
    return '${months[date.month - 1]} ${date.year}';
  }

  String _weekdayLabel(DateTime date) {
    const labels = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];
    return labels[date.weekday % 7];
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

    return SizedBox(
      width: 86,
      height: 86,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              width: 78,
              height: 78,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: _profileGradientForMood(moodHariIni),
                boxShadow: _softShadow,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: MoodlyUserAvatar(
                    uid: FirebaseAuth.instance.currentUser?.uid,
                    radius: 35,
                    backgroundColor: Colors.transparent,
                    borderWidth: 0,
                    borderColor: Colors.transparent,
                    placeholderAsset:
                        'assets/profile_pic/PP_default.jpg', // <- placeholder homepage
                  ),
                ),
              ),
            ),
          ),
          if (badgeAsset != null)
            Positioned(
              left: 0,
              bottom: 10,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: _moodBadgeBg(moodHariIni),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: _softShadow,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Image.asset(badgeAsset, fit: BoxFit.contain),
                ),
              ),
            ),
        ],
      ),
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
              Text(
                'Kucing Oren Imut',
                style: AppText.title(context).copyWith(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
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
                              'Streak',
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
                                        '$points poin',
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
                                          'Gunakan poin',
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
                        onTap: () => _goToPage(RewardPage(totalPoints: points)),
                        child: Container(
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [_premiumA, _premiumB],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _softShadow,
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.workspace_premium_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Jelajahi paket premium',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppText.bodyAlt(context).copyWith(
                                    fontSize: 12,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios_rounded,
                                size: 13,
                                color: Colors.white,
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
                        'Pilih Tanggal',
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
          onTap: () => _goToPage(const AfirmasiPage()),
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
                            : 'Untuk hari ini',
                        style: AppText.bodyAlt(context).copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _affirmationPreview,
                        style: AppText.body(
                          context,
                        ).copyWith(fontSize: 12, color: _textSoft, height: 1.4),
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
                label: 'Lihat diarymu',
                icon: Icons.lock_outline_rounded,
                bg: _peach,
                onTap: () => _goToPage(const MonthPage()),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _bridgeButton(
                label: 'Kunjungi diary publik',
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
                        ? 'Bagaimana harimu berjalan?'
                        : 'Bagaimana harimu di $_selectedDateLabel()?',
                    style: AppText.subtitle(context).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasSelectedMood
                        ? tipMood
                        : 'Ceritakan pada kami, pelan-pelan saja.',
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
                  width: 74,
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
                      ? 'Edit mood $_selectedDateLabel()'
                      : 'Isi mood $_selectedDateLabel()',
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
      onTap: () => _goToPage(const MoodAnalysis()),
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
                      'Lihat Analisa Mood Anda',
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
                      'Buka ringkasan mingguan dan bulanan mood-mu.',
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
        ? 'Diary Hari Ini'
        : 'Diary ${_selectedDateLabel()}';
  }

  String _diaryCardText() {
    return _isSameDay(selectedDate, DateTime.now())
        ? 'Buka diary untuk menulis catatanmu hari ini.'
        : 'Buka diary untuk melihat atau menulis catatan di tanggal ini.';
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

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const OnboardingPage();
    }

    return Scaffold(
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
                          _sectionHeader('Ruang Harian'),
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
        ],
      ),
      bottomNavigationBar: MoodlyBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _onNavbarTap,
        onEmergencyTap: _onEmergencyTap,
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
