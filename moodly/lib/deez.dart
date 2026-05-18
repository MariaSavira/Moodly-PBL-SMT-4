import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ─────────────────────────────────────────────
///  MOODLY – Homepage (Figma-exact + animations)
///  Drop this file into your lib/pages/ folder
///  and route to HomePage() from your navigator.
/// ─────────────────────────────────────────────

void main() => runApp(const _Demo());

class _Demo extends StatelessWidget {
  const _Demo();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF4CAF7D)),
        scaffoldBackgroundColor: const Color(0xFFEDF7EF),
        textTheme: GoogleFonts.fredokaTextTheme(),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

// ─── Colour tokens ────────────────────────────
const kGreen = Color(0xFF4CAF7D);
const kGreenLight = Color(0xFFEDF7EF);
const kGreenCard = Color(0xFFD6F0E0);
const kGreenDark = Color(0xFF2E7D52);
const kWhite = Colors.white;
const kPink = Color(0xFFF8BDC0); // emergency button
const kPinkDark = Color(0xFFE57373);
const kStreakOrange = Color(0xFFFF9A3C);
const kCalSelected = Color(0xFF4CAF7D);

// ─── Data models ─────────────────────────────
class MoodEntry {
  final String day;
  final String emoji;
  final double intensity; // 0..1
  const MoodEntry(this.day, this.emoji, this.intensity);
}

// ─── Main Page ────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedDay = 8;
  int _navIndex = 0;

  // Animation controllers
  late final AnimationController _headerCtrl;
  late final AnimationController _bannerCtrl;
  late final AnimationController _calCtrl;
  late final AnimationController _cardsCtrl;
  late final AnimationController _streakPulse;
  late final AnimationController _emergencyPulse;
  late final AnimationController _avatarRing;
  late final AnimationController _floatCtrl;

  late final Animation<double> _headerFade;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _bannerFade;
  late final Animation<Offset> _bannerSlide;
  late final Animation<double> _calFade;
  late final Animation<double> _cardsFade;
  late final Animation<Offset> _cardsSlide;
  late final Animation<double> _streakAnim;
  late final Animation<double> _emergencyAnim;
  late final Animation<double> _avatarRingAnim;
  late final Animation<double> _floatAnim;

  final List<MoodEntry> _moodHistory = const [
    MoodEntry('Kam', '😊', 0.55),
    MoodEntry('Jum', '😄', 0.75),
    MoodEntry('Sab', '😔', 0.40),
    MoodEntry('Min', '😊', 0.60),
    MoodEntry('Sen', '😌', 0.80),
    MoodEntry('Sel', '😢', 0.35),
    MoodEntry('Rab', '😠', 0.25),
  ];

  final List<_DayData> _weekDays = const [
    _DayData('Min', 5, hasMood: true),
    _DayData('Sen', 6, hasMood: true),
    _DayData('Sel', 7, hasMood: true),
    _DayData('Rab', 8),
    _DayData('Kam', 9),
    _DayData('Jum', 10),
    _DayData('Sab', 11),
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _headerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _bannerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _calCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _cardsCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));

    _streakPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _emergencyPulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))
      ..repeat(reverse: true);
    _avatarRing = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))
      ..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500))
      ..repeat(reverse: true);

    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));

    _bannerFade = CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut);
    _bannerSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _bannerCtrl, curve: Curves.easeOut));

    _calFade = CurvedAnimation(parent: _calCtrl, curve: Curves.easeOut);
    _cardsFade = CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut);
    _cardsSlide = Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _cardsCtrl, curve: Curves.easeOut));

    _streakAnim = Tween<double>(begin: 1.0, end: 1.05)
        .animate(CurvedAnimation(parent: _streakPulse, curve: Curves.easeInOut));
    _emergencyAnim = Tween<double>(begin: 1.0, end: 1.08)
        .animate(CurvedAnimation(parent: _emergencyPulse, curve: Curves.easeInOut));
    _avatarRingAnim = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _avatarRing, curve: Curves.easeInOut));
    _floatAnim = Tween<double>(begin: 0, end: -6)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 100));
    _headerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _bannerCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _calCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 150));
    _cardsCtrl.forward();
  }

  @override
  void dispose() {
    for (final c in [
      _headerCtrl, _bannerCtrl, _calCtrl, _cardsCtrl,
      _streakPulse, _emergencyPulse, _avatarRing, _floatCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreenLight,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopBar(),
                    _buildMoodBanner(),
                    _buildCalendar(),
                    _buildMoodHarianTitle(),
                    _buildMoodCards(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ─── Top Bar ──────────────────────────────
  Widget _buildTopBar() {
    return FadeTransition(
      opacity: _headerFade,
      child: SlideTransition(
        position: _headerSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            children: [
              // Icons
              _iconBtn(Icons.settings_rounded),
              const SizedBox(width: 10),
              _iconBtnNotif(),
              const Spacer(),
              // Avatar
              AnimatedBuilder(
                animation: _avatarRing,
                builder: (_, child) => Stack(
                  alignment: Alignment.center,
                  children: [
                    // Ring pulse
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: kGreen.withOpacity(_avatarRingAnim.value),
                          width: 2.5,
                        ),
                      ),
                    ),
                    child!,
                    // Floating sticker
                    AnimatedBuilder(
                      animation: _floatCtrl,
                      builder: (_, __) => Positioned(
                        top: _floatAnim.value + 0,
                        right: -2,
                        child: const Text('🐟', style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kWhite, width: 3),
                    color: const Color(0xFFFFCC80),
                  ),
                  child: const ClipOval(
                    child: Center(child: Text('🐱', style: TextStyle(fontSize: 26))),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: kWhite.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, size: 20, color: kGreenDark),
    );
  }

  Widget _iconBtnNotif() {
    return Stack(
      children: [
        _iconBtn(Icons.notifications_none_rounded),
        Positioned(
          top: 6,
          right: 6,
          child: Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(
              color: Colors.redAccent,
              shape: BoxShape.circle,
              border: Border.all(color: kGreenLight, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Greeting + Mood Banner ────────────────
  Widget _buildMoodBanner() {
    return FadeTransition(
      opacity: _bannerFade,
      child: SlideTransition(
        position: _bannerSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting
              Text('Selamat pagi,',
                  style: GoogleFonts.fredoka(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
              Text('Kucing Oren Imut',
                  style: GoogleFonts.fredoka(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black87,
                      height: 1.2)),
              const SizedBox(height: 14),
              // Banner Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Streak
                  AnimatedBuilder(
                    animation: _streakPulse,
                    builder: (_, child) => Transform.scale(scale: _streakAnim.value, child: child),
                    child: _buildStreakBox(),
                  ),
                  const SizedBox(width: 12),
                  // Mood info
                  Expanded(child: _buildMoodInfo()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakBox() {
    return Container(
      width: 80,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text('Streak',
              style: GoogleFonts.fredoka(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kStreakOrange.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Text('🔥', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(height: 6),
          Text('99',
              style: GoogleFonts.fredoka(fontSize: 22, fontWeight: FontWeight.w700, color: kStreakOrange)),
        ],
      ),
    );
  }

  Widget _buildMoodInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('😠', style: TextStyle(fontSize: 18)),
              const SizedBox(width: 6),
              Text('Mood Hari ini : Marah',
                  style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.redAccent)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Tip: Pelan-pelan ya, semuanya\nbisa dibicarakan nanti 😊',
            style: GoogleFonts.openSans(fontSize: 12, color: Colors.black54, height: 1.45),
          ),
        ],
      ),
    );
  }

  // ─── Calendar ─────────────────────────────
  Widget _buildCalendar() {
    return FadeTransition(
      opacity: _calFade,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Column(
          children: [
            // Header row
            Row(
              children: [
                _calNavBtn(Icons.arrow_back_ios_new_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text('April 2026',
                          style: GoogleFonts.fredoka(fontSize: 14, fontWeight: FontWeight.w600, color: kWhite)),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                _calNavBtn(Icons.arrow_forward_ios_rounded),
                const SizedBox(width: 8),
                // Date picker chip
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: kGreen.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Text('Pilih Tanggal',
                          style: GoogleFonts.fredoka(fontSize: 12, color: kGreenDark, fontWeight: FontWeight.w500)),
                      const SizedBox(width: 4),
                      const Icon(Icons.calendar_today_rounded, size: 14, color: kGreenDark),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Day labels
            Row(
              children: _weekDays.map((d) => Expanded(
                child: Center(
                  child: Text(d.label,
                      style: GoogleFonts.fredoka(fontSize: 12, color: Colors.black45, fontWeight: FontWeight.w500)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 8),
            // Day numbers
            Row(
              children: _weekDays.map((d) {
                final isSelected = d.number == _selectedDay;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedDay = d.number),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? kCalSelected : Colors.transparent,
                        boxShadow: isSelected
                            ? [BoxShadow(color: kGreen.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Text(
                            '${d.number}',
                            style: GoogleFonts.fredoka(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? kWhite : Colors.black,
                            ),
                          ),
                          if (d.hasMood && !isSelected)
                            Positioned(
                              bottom: 3,
                              child: Container(
                                width: 5,
                                height: 5,
                                decoration: const BoxDecoration(color: kGreen, shape: BoxShape.circle),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _calNavBtn(IconData icon) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: kGreen,
        shape: BoxShape.circle,
        boxShadow: [BoxShadow(color: kGreen.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 3))],
      ),
      child: Icon(icon, size: 15, color: kWhite),
    );
  }

  // ─── Section Title ────────────────────────
  Widget _buildMoodHarianTitle() {
    return FadeTransition(
      opacity: _cardsFade,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
        child: Text('Mood Harian',
            style: GoogleFonts.fredoka(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87)),
      ),
    );
  }

  // ─── Mood Cards ───────────────────────────
  Widget _buildMoodCards() {
    return FadeTransition(
      opacity: _cardsFade,
      child: SlideTransition(
        position: _cardsSlide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left – diary card (tall)
              Expanded(child: _buildDiaryCard()),
              const SizedBox(width: 10),
              // Right – stacked cards
              Expanded(
                child: Column(
                  children: [
                    _buildMoodTrackCard(),
                    const SizedBox(height: 10),
                    _buildReminderCard(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiaryCard() {
    return GestureDetector(
      onTap: () {},
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 5))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Sky gradient background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF87CEEB), Color(0xFF4FC3F7)],
                ),
              ),
            ),
            // Sand / beach ground
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFFD97D),
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: kWhite.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Bagaimana liburanmu?',
                        style: GoogleFonts.fredoka(fontSize: 11, fontWeight: FontWeight.w600, color: kGreenDark)),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: Text('Ceritakan pada kami!',
                        style: GoogleFonts.openSans(fontSize: 10, color: kWhite, fontWeight: FontWeight.w600)),
                  ),
                  const Spacer(),
                  // Add button
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: kGreen,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: kGreen.withOpacity(0.4), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    child: const Icon(Icons.add_rounded, color: kWhite, size: 22),
                  ),
                ],
              ),
            ),
            // Beach character
            AnimatedBuilder(
              animation: _floatCtrl,
              builder: (_, __) => Positioned(
                bottom: 14 + (_floatAnim.value * 0.5).abs(),
                right: 8,
                child: const Text('🏖️', style: TextStyle(fontSize: 36)),
              ),
            ),
            // Decorative wave dot
            Positioned(
              bottom: 56,
              left: 10,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.7), shape: BoxShape.circle),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTrackCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Mood Terakhir',
                  style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
              const Text('🌟', style: TextStyle(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          // Mini graph
          SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: _moodHistory.map((m) {
                final colors = {
                  '😊': const Color(0xFFFFCA28),
                  '😄': const Color(0xFF66BB6A),
                  '😔': const Color(0xFF90CAF9),
                  '😌': const Color(0xFF80CBC4),
                  '😢': const Color(0xFF9FA8DA),
                  '😠': const Color(0xFFEF9A9A),
                };
                final barColor = colors[m.emoji] ?? kGreen;
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(m.emoji, style: const TextStyle(fontSize: 9)),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        curve: Curves.easeOut,
                        height: (m.intensity * 36).clamp(6, 36),
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: _moodHistory.map((m) => Expanded(
              child: Center(
                child: Text(m.day,
                    style: GoogleFonts.fredoka(fontSize: 8, color: Colors.black45, fontWeight: FontWeight.w500)),
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notifications_active_rounded, color: Color(0xFF1565C0), size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Reminder',
                    style: GoogleFonts.fredoka(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)),
                const SizedBox(height: 3),
                Text('Mood Tracker Bulanan telah siap',
                    style: GoogleFonts.openSans(fontSize: 10, color: Colors.black54, height: 1.3)),
                const SizedBox(height: 4),
                Row(children: List.generate(3, (_) => Padding(
                  padding: const EdgeInsets.only(right: 3),
                  child: Container(width: 5, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, shape: BoxShape.circle)),
                ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Bottom Navigation ────────────────────
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 20, offset: const Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(0, Icons.home_rounded, 'Beranda'),
              _navItem(1, Icons.menu_book_rounded, 'Diary'),
              _navItem(2, Icons.forum_rounded, 'Connect'),
              _navItem(3, Icons.auto_awesome_rounded, 'Afirmasi'),
              _emergencyNavItem(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(int index, IconData icon, String label) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _navIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? kGreen.withOpacity(0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: isActive ? 46 : 0,
              height: isActive ? 46 : 0,
              decoration: isActive
                  ? BoxDecoration(
                      color: kGreen,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: kGreen.withOpacity(0.35), blurRadius: 10, offset: const Offset(0, 4))],
                    )
                  : null,
              child: isActive
                  ? Icon(icon, color: kWhite, size: 22)
                  : null,
            ),
            if (!isActive) ...[
              Icon(icon, color: Colors.grey.shade400, size: 24),
              const SizedBox(height: 3),
              Text(label,
                  style: GoogleFonts.fredoka(fontSize: 11, color: Colors.grey.shade400, fontWeight: FontWeight.w500)),
            ] else ...[
              const SizedBox(height: 3),
              Text(label,
                  style: GoogleFonts.fredoka(fontSize: 11, color: kGreen, fontWeight: FontWeight.w600)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _emergencyNavItem() {
    return GestureDetector(
      onTap: () {
        // Navigate to emergency page
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Halaman Darurat', style: GoogleFonts.fredoka()),
            backgroundColor: kPinkDark,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _emergencyPulse,
            builder: (_, child) => Transform.scale(
              scale: _emergencyAnim.value,
              child: child,
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: kPink,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: kPink.withOpacity(0.55), blurRadius: 12, offset: const Offset(0, 4)),
                  BoxShadow(color: kPinkDark.withOpacity(0.15), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFE53935), size: 22),
            ),
          ),
          const SizedBox(height: 3),
          Text('Darurat',
              style: GoogleFonts.fredoka(fontSize: 11, color: kPinkDark, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ─── Helper class ─────────────────────────────
class _DayData {
  final String label;
  final int number;
  final bool hasMood;
  const _DayData(this.label, this.number, {this.hasMood = false});
}