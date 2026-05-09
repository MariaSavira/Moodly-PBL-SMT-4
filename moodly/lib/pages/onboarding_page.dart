import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import '../core/styles/app_text.dart';
import 'auth/auth.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with TickerProviderStateMixin {
  late final PageController _pageController;
  late final AnimationController _ambientController;

  double _pageValue = 0;
  int _currentPage = 0;

  static const Color _bgTop = Color(0xFFFDFCF6);
  static const Color _bgBottom = Color(0xFFF6F9EC);
  static const Color _pinkMain = Color(0xFFE94C67);
  static const Color _pinkSoft = Color(0xFFFFD6DE);
  static const Color _greenSoft = Color(0xFFBFE3AF);
  static const Color _greenMain = Color(0xFF46A148);
  static const Color _textDark = Color(0xFF222222);

  final List<_OnboardingSlideData> _slides = const [
    _OnboardingSlideData(
      title: 'Halo, selamat datang di Moodly!',
      desc:
          'Tempat kecil untuk datang apa adanya. Pelan-pelan, kamu bisa mulai merasa lebih aman, lebih tenang, dan lebih dipahami.',
      // GANTI path ini sesuai file maskot superhero milikmu
      assetPath: 'assets/mascots/6.png',
      accent: _pinkMain,
      titleColor: Color(0xFFD96078),
    ),
    _OnboardingSlideData(
      title: 'Kenali dirimu, satu hari sekali',
      desc:
          'Catat mood harian, tulis diary digital, lakukan afirmasi, dan pahami pola emosimu tanpa harus terburu-buru.',
      // GANTI path ini sesuai file maskot otak baca buku
      assetPath: 'assets/mascots/4.png',
      accent: _greenMain,
      titleColor: Color(0xFF3E9242),
      mascotScale: 0.78,
    ),
    _OnboardingSlideData(
      title: 'Siap tumbuh bareng Moodly?',
      desc:
          'Bangun kebiasaan kecil yang bikin kamu makin kuat setiap hari. Yuk bergabung dan mulai perjalananmu bersama kami.',
      // GANTI path ini sesuai file maskot otak flexing
      assetPath: 'assets/mascots/11.png',
      accent: _pinkMain,
      titleColor: Color(0xFFE94C67),
      mascotScale: 0.78,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _pageController = PageController();
    _pageController.addListener(() {
      final value = _pageController.hasClients && _pageController.page != null
          ? _pageController.page!
          : 0.0;

      if (!mounted) return;
      setState(() {
        _pageValue = value;
        _currentPage = value.round().clamp(0, _slides.length - 1);
      });
    });

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_currentPage < _slides.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubicEmphasized,
      );
    }
  }

  void _skipToLast() {
    _pageController.animateToPage(
      _slides.length - 1,
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeInOutCubicEmphasized,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bodyStyle = AppText.body(context).copyWith(
      fontSize: 15,
      height: 1.6,
      color: _textDark.withOpacity(0.90),
      fontWeight: FontWeight.w600,
    );

    return Scaffold(
      body: AnimatedBuilder(
        animation: _ambientController,
        builder: (context, _) {
          final ambient = _ambientController.value * 2 * math.pi;

          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [_bgTop, _bgBottom],
                    ),
                  ),
                ),
              ),

              Positioned.fill(
                child: IgnorePointer(
                  child: _DynamicBokehLayer(
                    pageValue: _pageValue,
                    ambient: ambient,
                    pinkSoft: _pinkSoft,
                    greenSoft: _greenSoft,
                  ),
                ),
              ),

              PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  final delta = (_pageValue - index);
                  final absDelta = delta.abs().clamp(0.0, 1.0);

                  final scale = 1 - (absDelta * 0.06);
                  final contentX = delta * -24;
                  final opacity = 1 - (absDelta * 0.18);

                  final titleStyle = AppText.title(context).copyWith(
                    fontSize: 28,
                    height: 1.15,
                    color: slide.titleColor,
                    fontWeight: FontWeight.w700,
                  );

                  return SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 28),
                          child: Column(
                            children: [
                              SizedBox(height: constraints.maxHeight * 0.05),

                              Expanded(
                                child: Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()
                                    ..translate(contentX)
                                    ..scale(scale, 1 - (absDelta * 0.02)),
                                  child: Opacity(
                                    opacity: opacity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          flex: 7,
                                          child: Center(
                                            child: _MascotHero(
                                              assetPath: slide.assetPath,
                                              accent: slide.accent,
                                              delta: delta,
                                              ambient: ambient,
                                              mascotScale: slide.mascotScale,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 18),
                                        AnimatedSlide(
                                          offset: Offset(
                                            _currentPage == index ? 0 : 0.03,
                                            0,
                                          ),
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: _currentPage == index
                                                ? 1
                                                : 0.95,
                                            duration: const Duration(
                                              milliseconds: 500,
                                            ),
                                            child: Text(
                                              slide.title,
                                              textAlign: TextAlign.center,
                                              style: titleStyle,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        AnimatedSlide(
                                          offset: Offset(
                                            _currentPage == index ? 0 : 0.04,
                                            0,
                                          ),
                                          duration: const Duration(
                                            milliseconds: 620,
                                          ),
                                          curve: Curves.easeOutCubic,
                                          child: AnimatedOpacity(
                                            opacity: _currentPage == index
                                                ? 1
                                                : 0.92,
                                            duration: const Duration(
                                              milliseconds: 620,
                                            ),
                                            child: ConstrainedBox(
                                              constraints:
                                                  const BoxConstraints(
                                                maxWidth: 340,
                                              ),
                                              child: Text(
                                                slide.desc,
                                                textAlign: TextAlign.center,
                                                style: bodyStyle,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 22),

                              SizedBox(
                                height: 168,
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 320),
                                  switchInCurve: Curves.easeOutCubic,
                                  switchOutCurve: Curves.easeInCubic,
                                  child: _currentPage == _slides.length - 1
                                      ? const _FinalCtaSection(
                                          key: ValueKey('final_cta'),
                                        )
                                      : _BottomPagerBar(
                                          key: const ValueKey('pager_bar'),
                                          currentPage: _currentPage,
                                          totalPage: _slides.length,
                                          onSkip: _skipToLast,
                                          onNext: _goNext,
                                        ),
                                ),
                              ),

                              const SizedBox(height: 14),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _OnboardingSlideData {
  final String title;
  final String desc;
  final String assetPath;
  final Color accent;
  final Color titleColor;
  final double mascotScale;

  const _OnboardingSlideData({
    required this.title,
    required this.desc,
    required this.assetPath,
    required this.accent,
    required this.titleColor,
    this.mascotScale = 1.0,
  });
}

class _DynamicBokehLayer extends StatelessWidget {
  final double pageValue;
  final double ambient;
  final Color pinkSoft;
  final Color greenSoft;

  const _DynamicBokehLayer({
    required this.pageValue,
    required this.ambient,
    required this.pinkSoft,
    required this.greenSoft,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final shift = pageValue * width * 0.22;

    return Stack(
      children: [
        _bokeh(
          left: -95 - shift,
          top: -70 + (math.sin(ambient * 0.95) * 12),
          size: 240,
          color: pinkSoft.withOpacity(0.28),
          blur: 20,
        ),
        _bokeh(
          right: -65 - (shift * 0.65),
          top: 120 + (math.cos(ambient * 0.82) * 16),
          size: 190,
          color: greenSoft.withOpacity(0.24),
          blur: 20,
        ),
        _bokeh(
          left: -85 - (shift * 0.40),
          bottom: 115 + (math.sin(ambient * 0.90) * 16),
          size: 270,
          color: pinkSoft.withOpacity(0.16),
          blur: 22,
        ),
        _bokeh(
          right: -95 - (shift * 0.95),
          bottom: -18 + (math.cos(ambient * 1.10) * 14),
          size: 250,
          color: greenSoft.withOpacity(0.18),
          blur: 24,
        ),
        _bokeh(
          left: 92 - (shift * 0.78),
          top: 335 + (math.sin(ambient * 1.30) * 14),
          size: 120,
          color: pinkSoft.withOpacity(0.13),
          blur: 18,
        ),
      ],
    );
  }

  Widget _bokeh({
    double? left,
    double? right,
    double? top,
    double? bottom,
    required double size,
    required Color color,
    required double blur,
  }) {
    return Positioned(
      left: left,
      right: right,
      top: top,
      bottom: bottom,
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _MascotHero extends StatelessWidget {
  final String assetPath;
  final Color accent;
  final double delta;
  final double ambient;
  final double mascotScale;

  const _MascotHero({
    required this.assetPath,
    required this.accent,
    required this.delta,
    required this.ambient,
    this.mascotScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    final absDelta = delta.abs().clamp(0.0, 1.0);
    final floatY = math.sin(ambient * 1.2) * 7;
    final pageScale = 1 - (absDelta * 0.08);

    return Transform.translate(
      offset: Offset(delta * -18, floatY),
      child: Transform.scale(
        scale: pageScale,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withOpacity(0.13),
                    accent.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            Container(
              width: 185,
              height: 185,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: accent.withOpacity(0.14),
                    blurRadius: 36,
                    spreadRadius: 6,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                children: [
                  Positioned(
                    top: 16 + (math.sin(ambient) * 4),
                    left: 26,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: accent.withOpacity(0.82),
                    ),
                  ),
                  Positioned(
                    top: 38 + (math.cos(ambient * 0.8) * 4),
                    right: 20,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 11,
                      color: Color(0xFF8FD276),
                    ),
                  ),
                  Positioned(
                    bottom: 32 + (math.cos(ambient * 1.1) * 4),
                    left: 18,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 11,
                      color: Color(0xFFFFB8C3),
                    ),
                  ),
                  Positioned(
                    bottom: 18 + (math.sin(ambient * 0.9) * 4),
                    right: 30,
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 15,
                      color: Color(0xFFB9E6AA),
                    ),
                  ),
                ],
              ),
            ),

            // ✅ CUMA MASKOT YANG DISCALE
            Transform.scale(
              scale: mascotScale,
              child: Image.asset(
                assetPath,
                height: 220,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) {
                  return Icon(
                    Icons.psychology_alt_rounded,
                    size: 110,
                    color: accent.withOpacity(0.78),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomPagerBar extends StatelessWidget {
  final int currentPage;
  final int totalPage;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _BottomPagerBar({
    super.key,
    required this.currentPage,
    required this.totalPage,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: onSkip,
                  child: Text(
                    'Lewati',
                    style: AppText.subtitle(context).copyWith(
                      color: const Color(0xFF7C69B8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(totalPage, (index) {
                final selected = index == currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  width: selected ? 28 : 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFF46A148)
                        : Colors.grey.withOpacity(0.38),
                    borderRadius: BorderRadius.circular(99),
                  ),
                );
              }),
            ),
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: onNext,
                  child: Text(
                    'Next',
                    style: AppText.subtitle(context).copyWith(
                      color: const Color(0xFF7C69B8),
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _FinalCtaSection extends StatelessWidget {
  const _FinalCtaSection({super.key});

  static const Color greenMain = Color(0xFF46A148);
  static const Color pinkMain = Color(0xFFE94C67);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 8,
              shadowColor: greenMain.withOpacity(0.25),
              backgroundColor: greenMain,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Sudah punya akun',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              elevation: 8,
              shadowColor: const Color(0xFFF8BDC0).withOpacity(0.22),
              backgroundColor: const Color(0xFFF8BDC0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            child: Text(
              'Bergabung dengan kami',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: const Color(0xFFD96078),
                    fontSize: 15,
                  ),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}