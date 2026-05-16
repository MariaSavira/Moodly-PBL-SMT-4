import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';
import '../core/services/streak_service.dart';
import '../widgets/moodly_bottom_navbar.dart';
import 'streak/streak_page.dart';
import 'streak/reward_page.dart';
import 'mood/mood_input.dart';
import 'private_diary/month_page.dart';
import 'private_diary/add_diary_page.dart';
import 'pages.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentNavIndex = 0;

  String? moodHariIni;
  String tipMood = 'Pelan-pelan ya, semuanya bisa dibicarakan nanti 😉';
  DateTime selectedDate = DateTime.now();

  bool get _hasSelectedMood =>
      moodHariIni != null && moodHariIni!.trim().isNotEmpty;

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
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
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  Future<void> _openMoodInput() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MoodInput()),
    );

    if (!mounted) return;

    if (result is Map<String, dynamic>) {
      setState(() {
        final mood = result['mood'];
        final tip = result['tip'];

        if (mood is String && mood.trim().isNotEmpty) {
          moodHariIni = mood.trim();
        }

        if (tip is String && tip.trim().isNotEmpty) {
          tipMood = tip.trim();
        }
      });
    } else if (result is String && result.trim().isNotEmpty) {
      setState(() {
        moodHariIni = result.trim();
      });
    }
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
    await _openMoodCalendar();
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
        targetPage = const MonthPage();
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tombol Darurat ditekan'),
      ),
    );
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
            Center(
              child: Icon(
                icon,
                size: 22,
                color: _greenDark,
              ),
            ),
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
                gradient: const LinearGradient(
                  colors: [Color(0xFFF3CDD3), Color(0xFFEBDCC4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: _softShadow,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/profile_pic/PP.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.person,
                      size: 34,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 0,
            bottom: 10,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFFF06E7F),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
                boxShadow: _softShadow,
              ),
              child: const Center(
                child: Text(
                  '☹',
                  style: TextStyle(fontSize: 14),
                ),
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
                  _glassIconButton(
                    icon: Icons.notifications_rounded,
                    onTap: () {},
                    showDot: true,
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
                                        style: AppText.bodyAlt(context).copyWith(
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
                                onTap: () => _goToPage(
                                  RewardPage(totalPoints: points),
                                ),
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
                                          style: AppText.bodyAlt(context).copyWith(
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
                        onTap: () => _goToPage(
                          RewardPage(totalPoints: points),
                        ),
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
                onTap: () {
                  setState(() {
                    selectedDate =
                        selectedDate.subtract(const Duration(days: 7));
                  });
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
                onTap: () {
                  setState(() {
                    selectedDate = selectedDate.add(const Duration(days: 7));
                  });
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

  Widget _navCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
        icon: Icon(
          icon,
          size: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _dayChip(DateTime date) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    return GestureDetector(
      onTap: () => setState(() => selectedDate = date),
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
      style: AppText.subtitle(context).copyWith(
        fontSize: 20,
        color: _textDark,
        fontWeight: FontWeight.w800,
      ),
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
                        'Untuk hari ini',
                        style: AppText.bodyAlt(context).copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kamu tidak harus buru-buru. Tarik napas, lalu tulis yang ingin kamu keluarkan.',
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
        Expanded(
          flex: 11,
          child: _bigMoodCard(),
        ),
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
                    _hasSelectedMood
                        ? 'Bagaimana harimu berjalan?'
                        : 'Bagaimana harimu berjalan?',
                    style: AppText.subtitle(context).copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _hasSelectedMood
                        ? 'Ceritakan lebih lanjut, pelan-pelan saja.'
                        : 'Ceritakan pada kami, pelan-pelan saja.',
                    style: AppText.body(context).copyWith(
                      fontSize: 13,
                      color: const Color(0xFF6A6A6A),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              top: 98,
              child: Center(
                child: Container(
                  width: 88,
                  height: 58,
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: _softShadow,
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
            ),
            Positioned(
              left: 18,
              bottom: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _hasSelectedMood ? 'Lanjut tulis mood' : 'Mulai tulis mood',
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
          colors: [
            Color(0xFFBFEFFF),
            Color(0xFF6EDCFF),
            Color(0xFFF2D47D),
          ],
        ),
      ),
      child: Stack(
        children: const [
          Positioned(
            left: 12,
            bottom: 14,
            child: Text(
              '🌴',
              style: TextStyle(fontSize: 42),
            ),
          ),
          Positioned(
            right: 12,
            bottom: 18,
            child: Text(
              '🕶️',
              style: TextStyle(fontSize: 26),
            ),
          ),
        ],
      ),
    );
  }

  Widget _moodGraphCard() {
    final points = [
      const Offset(0.10, 0.52),
      const Offset(0.23, 0.56),
      const Offset(0.37, 0.65),
      const Offset(0.51, 0.76),
      const Offset(0.66, 0.46),
      const Offset(0.82, 0.58),
      const Offset(0.92, 0.70),
    ];

    final labels = ['Kam', 'Jum', 'Sab', 'Min', 'Sen', 'Sel', 'Rab'];

    return GestureDetector(
      onTap: _openMoodCalendar,
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
                  Text(
                    'Mood Terakhir',
                    style: AppText.bodyAlt(context).copyWith(
                      fontSize: 13,
                      color: _textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Text('🌼', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: _LineChartPainter(
                              points: points,
                              color: const Color(0xFFC6C6C6),
                            ),
                          ),
                        ),
                        ...List.generate(points.length, (index) {
                          final point = points[index];
                          final left = constraints.maxWidth * point.dx - 11;
                          final top = constraints.maxHeight * point.dy - 11;
                          final emojis = ['🙂', '🙂', '🙂', '😡', '🙂', '🙂', '😡'];

                          return Positioned(
                            left: left,
                            top: top,
                            child: SizedBox(
                              width: 22,
                              height: 22,
                              child: Center(
                                child: Text(
                                  emojis[index],
                                  style: const TextStyle(fontSize: 17),
                                ),
                              ),
                            ),
                          );
                        }),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: labels
                                .map(
                                  (e) => Text(
                                    e,
                                    style: AppText.body(context).copyWith(
                                      fontSize: 10,
                                      color: const Color(0xFF6A6A6A),
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
                      'Diary Hari Ini',
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
                        'Anda belum menulis diary hari ini. Tulis diary →',
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

  const _LineChartPainter({
    required this.points,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    final path = Path();

    for (int i = 0; i < points.length; i++) {
      final p = Offset(
        size.width * points[i].dx,
        size.height * points[i].dy,
      );

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