import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../widgets/moodly_bottom_navbar.dart';
import '../core/styles/app_text.dart';
import 'onboarding_page.dart';
import 'streak/streak_page.dart';
import 'pages.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentNavIndex = 0;

  void _onNavbarTap(int index) {
    setState(() {
      _currentNavIndex = index;
    });

    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeChatAnonim(),
        ),
      );
    }
    // Nanti kalau sudah ada halaman masing-masing, taruh navigasi di sini.
    // Contoh:
    // if (index == 1) { Navigator.push(...); }
  }

  void _onEmergencyTap() {
    // sementara placeholder dulu
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Tombol Darurat ditekan'),
      ),
    );

    // nanti kalau halaman darurat sudah ada:
    // Navigator.push(context, MaterialPageRoute(builder: (_) => const EmergencyPage()));
  }
  String? moodHariIni;
  String tipMood = 'Pelan-pelan ya, semuanya bisa dibicarakan nanti 😉';

  bool get _hasSelectedMood =>
      moodHariIni != null && moodHariIni!.trim().isNotEmpty;
  int streakCount = 99;
  bool isStreakLitToday = true;

  DateTime selectedDate = DateTime.now();

  String get _greetingText {
    final hour = DateTime.now().hour;
    if (hour >= 4 && hour < 11) return 'Selamat pagi,';
    if (hour >= 11 && hour < 15) return 'Selamat siang,';
    if (hour >= 15 && hour < 18) return 'Selamat sore,';
    return 'Selamat malam,';
  }

  String get _affirmationTitle {
    if (!_hasSelectedMood) return 'Afirmasi Hari Ini';
    if (moodHariIni == 'Sedih' || moodHariIni == 'Marah') {
      return 'Butuh dukungan hari ini?';
    }
    return 'Afirmasi Hari Ini';
  }

  String get _affirmationText {
    if (!_hasSelectedMood) {
      return 'Hari ini kamu tidak harus sempurna. Cukup hadir dan bertahan.';
    }
    if (moodHariIni == 'Sedih' || moodHariIni == 'Marah') {
      return 'Coba pelan-pelan. Kamu boleh istirahat, bernapas, dan minta bantuan.';
    }
    return 'Kamu sedang bertumbuh, meski pelan. Itu tetap berarti.';
  }

  String get _publicDiaryChipLabel {
    if (!_hasSelectedMood) return 'Diary Publik';
    if (moodHariIni == 'Sedih' || moodHariIni == 'Marah') {
      return 'Lihat cerita & dukungan';
    }
    return 'Diary Publik';
  }

  static const Color _bgColor = Color(0xFFF1F5E4);
  static const Color _greenMain = Color(0xFF82C46B);
  static const Color _greenDark = Color(0xFF68AF56);
  static const Color _greenSoft = Color(0xFFB5E0A6);
  static const Color _pinkSoft = Color(0xFFFFE0E2);
  static const Color _pinkCard = Color(0xFFF8BDC0);
  static const Color _blueSoft = Color(0xFFD8F2FB);
  static const Color _cardWhite = Color(0xFFFCFCFA);
  static const Color _textDark = Color(0xFF202020);
  static const Color _shadowColor = Color(0x40000000);

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.251),
          offset: Offset(0, 1),
          blurRadius: 5,
          spreadRadius: 0,
        ),
      ];

  Widget _publicDiaryChip() {
    return GestureDetector(
      onTap: () {
        // nanti arahkan ke halaman diary publik
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFD8EDC7),
          borderRadius: BorderRadius.circular(99),
          boxShadow: _softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.menu_book_rounded,
              size: 14,
              color: _greenDark,
            ),
            const SizedBox(width: 6),
            Text(
              _publicDiaryChipLabel,
              style: AppText.bodyAlt(context).copyWith(
                fontSize: 11,
                color: _greenDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _navCircle({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: _greenMain,
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

  Widget _pickDateButton() {
    return GestureDetector(
      onTap: _pickDate,
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: _cardWhite,
          borderRadius: BorderRadius.circular(99),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Text(
              'Pilih Tanggal',
              style: AppText.subtitle(context).copyWith(
                fontSize: 14,
                color: const Color(0xFF65516A),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _greenSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: _greenDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _streakFlame() {
    final double flameSize = isStreakLitToday ? 70 : 44;
    final double flameOpacity = isStreakLitToday ? 1.0 : 0.28;
    final double countOpacity = isStreakLitToday ? 1.0 : 0.0;

    final String assetPath = isStreakLitToday
        ? 'assets/homepage_assets/streak_moving.gif'
        : 'assets/homepage_assets/streak_static.png';

    return AnimatedContainer(
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      width: 76,
      height: 84,
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
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
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
                  offset: const Offset(0, 7),
                  child: Text(
                    '$streakCount',
                    style: AppText.bodyAlt(context).copyWith(
                      fontSize: 15,
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

  Future<void> _showSettingsSheet() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 46,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
                const SizedBox(height: 14),
                ListTile(
                  leading: const Icon(Icons.logout_rounded, color: Colors.redAccent),
                  title: Text(
                    'Logout',
                    style: AppText.subtitle(context).copyWith(
                      color: _textDark,
                      fontSize: 16,
                    ),
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await FirebaseAuth.instance.signOut();
                    if (!mounted) return;
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const OnboardingPage()),
                      (route) => false,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _greenMain,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
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

  Widget _iconCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(99),
      onTap: onTap,
      child: SizedBox(
        width: 34,
        height: 34,
        child: Icon(
          icon,
          color: _greenDark,
          size: 28,
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _iconCircleButton(
                      icon: Icons.settings,
                      onTap: _showSettingsSheet,
                    ),
                    const SizedBox(width: 10),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _iconCircleButton(
                          icon: Icons.notifications,
                          onTap: () {},
                        ),
                        Positioned(
                          right: 5,
                          top: 4,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE74A63),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _greetingText,
                  style: AppText.subtitle(context).copyWith(
                    fontSize: 15,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Kucing Oren Imut',
                  style: AppText.title(context).copyWith(
                    fontSize: 22,
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 6),
          child: SizedBox(
            width: 86,
            height: 86,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 74,
                    height: 74,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFEBC3C7),
                        width: 4,
                      ),
                      boxShadow: _softShadow,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/profile_pic/PP.png',
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: const Color(0xFFE7D8CA),
                          child: const Icon(
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
                  bottom: 8,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF26A7C),
                      shape: BoxShape.circle,
                      border: Border.all(color: _cardWhite, width: 3),
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
                Positioned(
                  right: -2,
                  top: -4,
                  child: Image.asset(
                    'assets/mascots/mini_badge.png',
                    width: 26,
                    height: 26,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _streakAndMoodSection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StreakPage()),
            );
          },
          child: Container(
            width: 94,
            height: 104,
            decoration: BoxDecoration(
              color: _cardWhite,
              borderRadius: BorderRadius.circular(24),
              boxShadow: _softShadow,
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  left: -10,
                  top: 8,
                  child: Transform.rotate(
                    angle: -0.75,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEECFD6),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: _softShadow,
                      ),
                      child: Text(
                        'Streak',
                        style: AppText.bodyAlt(context).copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF4D3F46),
                        ),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: _streakFlame(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 104,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: _softShadow,
            ),
            child: Column(
              children: [
                Container(
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFFF2CDCF),
                        Color(0xFFDCE9C7),
                      ],
                    ),
                  ),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    _hasSelectedMood
                        ? 'Mood Hari ini : ${moodHariIni!}'
                        : 'Bagaimana perasaanmu hari ini?',
                    style: AppText.subtitle(context).copyWith(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                    decoration: BoxDecoration(
                      color: _cardWhite,
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(24),
                      ),
                    ),
                    child: _hasSelectedMood
                        ? Text(
                            'Tip: $tipMood',
                            style: AppText.body(context).copyWith(
                              fontSize: 13,
                              color: _textDark,
                              height: 1.38,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          )
                        : Center(
                            child: Text(
                              'Isi mood tracker dulu supaya Moodly bisa kasih insight yang lebih pas buat kamu.',
                              style: AppText.body(context).copyWith(
                                fontSize: 12,
                                color: _textDark,
                                height: 1.32,
                              ),
                              textAlign: TextAlign.left,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _monthNavigator() {
    return Row(
      children: [
        _navCircle(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () {
            setState(() {
              selectedDate = selectedDate.subtract(const Duration(days: 7));
            });
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 38,
            decoration: BoxDecoration(
              color: _greenMain,
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
        _pickDateButton(),
      ],
    );
  }

  Widget _dayChip(DateTime date) {
    final isSelected = date.year == selectedDate.year &&
        date.month == selectedDate.month &&
        date.day == selectedDate.day;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: GestureDetector(
        onTap: () => setState(() => selectedDate = date),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: 45,
          height: isSelected ? 56 : 45,
          margin: EdgeInsets.only(top: isSelected ? 0 : 10),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF82C46B)
                : const Color(0xFFCDE8B9),
            borderRadius: BorderRadius.circular(16),
            boxShadow: _softShadow,
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withOpacity(0.08),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: AppText.title(context).copyWith(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                  child: Text('${date.day}'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weekStrip() {
    final week = _weekDates(selectedDate);

    return Column(
      children: [
        Row(
          children: week
              .map(
                (date) => Expanded(
                  child: Center(
                    child: Text(
                      _weekdayLabel(date),
                      style: AppText.bodyAlt(context).copyWith(
                        fontSize: 13,
                        color: const Color(0xFF6B6A68),
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 10),
        Row(
          children: week.map((date) => _dayChip(date)).toList(),
        ),
      ],
    );
  }

  Widget _diaryCard() {
    return Container(
      height: 238,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: _blueSoft,
        boxShadow: _softShadow,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: _buildMoodCardBackground(
                      imagePath: 'assets/homepage_assets/background_input_mood.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 16,
            top: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bagaimana liburanmu?',
                  style: AppText.subtitle(context).copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ceritakan pada kami!',
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
            top: 82,
            child: Center(
              child: Container(
                width: 70,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFA8D78B),
                  borderRadius: BorderRadius.circular(18),
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
        ],
      ),
    );
  }

  Widget _buildMoodCardBackground({
    String? imagePath,
  }) {
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

    return Container(
      height: 146,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFBFE3AF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  'Mood Terakhir',
                  style: AppText.bodyAlt(context).copyWith(
                    fontSize: 13,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text('🌼', style: TextStyle(fontSize: 18)),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
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
                          child: Container(
                            width: 22,
                            height: 22,
                            alignment: Alignment.center,
                            child: Text(
                              emojis[index],
                              style: const TextStyle(fontSize: 17),
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
    );
  }

  Widget _affirmationCard() {
    return Container(
      height: 84,
      decoration: BoxDecoration(
        color: _cardWhite,
        borderRadius: BorderRadius.circular(22),
        boxShadow: _softShadow,
      ),
      child: Column(
        children: [
          Container(
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFBFE3AF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text(
                  _affirmationTitle,
                  style: AppText.bodyAlt(context).copyWith(
                    fontSize: 13,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                const Text('✨', style: TextStyle(fontSize: 16)),
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
                      _affirmationText,
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
    );
  }

  Widget _moodSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Mood Harian',
              style: AppText.subtitle(context).copyWith(
                fontSize: 18,
                color: _textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            _publicDiaryChip(),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 11,
              child: _diaryCard(),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 10,
              child: Column(
                children: [
                  _moodGraphCard(),
                  const SizedBox(height: 10),
                  _affirmationCard(),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _headerSection(),
              const SizedBox(height: 18),
              _streakAndMoodSection(),
              const SizedBox(height: 18),
              _monthNavigator(),
              const SizedBox(height: 12),
              _weekStrip(),
              const SizedBox(height: 18),
              _moodSection(),
            ],
          ),
        ),
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