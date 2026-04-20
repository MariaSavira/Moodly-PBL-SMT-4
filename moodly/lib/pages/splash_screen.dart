import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../main.dart';

class SplashScreenMoodly extends StatefulWidget {
  const SplashScreenMoodly({super.key});

  @override
  State<SplashScreenMoodly> createState() => _SplashScreenMoodlyState();
}

class _SplashScreenMoodlyState extends State<SplashScreenMoodly>
    with TickerProviderStateMixin {
  late final AnimationController _introController;
  late final AnimationController _pulseController;
  late final AnimationController _floatController;
  late final AnimationController _sparkleController;

  late final Animation<double> _bgFade;
  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _titleFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<double> _subtitleFade;

  @override
  void initState() {
    super.initState();

    _introController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);

    _sparkleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    _bgFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    _logoFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.12, 0.52, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.72, end: 1.0).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.12, 0.58, curve: Curves.easeOutBack),
      ),
    );

    _titleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.42, 0.72, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _introController,
        curve: const Interval(0.42, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    _subtitleFade = CurvedAnimation(
      parent: _introController,
      curve: const Interval(0.62, 0.95, curve: Curves.easeOut),
    );

    _introController.forward();

    Timer(const Duration(milliseconds: 3600), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 600),
          pageBuilder: (_, __, ___) => const MainMenuPage(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }

  @override
  void dispose() {
    _introController.dispose();
    _pulseController.dispose();
    _floatController.dispose();
    _sparkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgTop = Color(0xFFFDFCF6);
    const Color bgBottom = Color(0xFFF6F9EC);
    const Color pinkMain = Color(0xFFE94C67);
    const Color pinkSoft = Color(0xFFFFD6DE);
    const Color greenSoft = Color(0xFFBFE3AF);
    const Color textDark = Color(0xFF222222);
    const Color textSub = Color(0xFF6E7D61);

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _introController,
          _pulseController,
          _floatController,
          _sparkleController,
        ]),
        builder: (context, child) {
          final double pulse = 1 + (_pulseController.value * 0.06);
          final double floatY =
              math.sin(_floatController.value * 2 * math.pi) * 10;
          final double sparkleTurn = _sparkleController.value * 2 * math.pi;

          return Stack(
            children: [
              Positioned.fill(
                child: FadeTransition(
                  opacity: _bgFade,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [bgTop, bgBottom],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: -80,
                left: -50,
                child: _blob(
                  size: 220,
                  color: pinkSoft.withOpacity(0.35),
                ),
              ),

              Positioned(
                top: 110,
                right: -40,
                child: _blob(
                  size: 170,
                  color: greenSoft.withOpacity(0.28),
                ),
              ),

              Positioned(
                bottom: 80,
                left: -70,
                child: _blob(
                  size: 250,
                  color: pinkSoft.withOpacity(0.20),
                ),
              ),

              Positioned(
                bottom: -20,
                right: -50,
                child: _blob(
                  size: 220,
                  color: greenSoft.withOpacity(0.22),
                ),
              ),

              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Transform.translate(
                      offset: Offset(0, floatY),
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: ScaleTransition(
                          scale: _logoScale,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Transform.scale(
                                scale: pulse * 1.28,
                                child: Container(
                                  width: 220,
                                  height: 220,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        pinkSoft.withOpacity(0.75),
                                        pinkSoft.withOpacity(0.18),
                                        Colors.transparent,
                                      ],
                                      stops: const [0.0, 0.55, 1.0],
                                    ),
                                  ),
                                ),
                              ),

                              Transform.scale(
                                scale: pulse,
                                child: Container(
                                  width: 160,
                                  height: 160,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: pinkMain.withOpacity(0.18),
                                        blurRadius: 42,
                                        spreadRadius: 10,
                                        offset: const Offset(0, 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(
                                width: 240,
                                height: 240,
                                child: Stack(
                                  children: [
                                    Positioned(
                                      top: 16 + (math.sin(sparkleTurn) * 4),
                                      left: 34,
                                      child: Transform.rotate(
                                        angle: sparkleTurn * 0.8,
                                        child: _sparkle(
                                          size: 16,
                                          color: pinkMain.withOpacity(0.95),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 44,
                                      right: 24 + (math.cos(sparkleTurn) * 4),
                                      child: Transform.rotate(
                                        angle: -sparkleTurn,
                                        child: _sparkle(
                                          size: 12,
                                          color: const Color(0xFF8FD276),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 42,
                                      left: 18 + (math.cos(sparkleTurn) * 3),
                                      child: Transform.rotate(
                                        angle: sparkleTurn * 0.6,
                                        child: _sparkle(
                                          size: 13,
                                          color: const Color(0xFFFFB8C3),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 18 + (math.sin(sparkleTurn) * 2),
                                      right: 32,
                                      child: Transform.rotate(
                                        angle: -sparkleTurn * 0.7,
                                        child: _sparkle(
                                          size: 18,
                                          color: const Color(0xFFB9E6AA),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Image.asset(
                                'assets/images/moodly_heart.png',
                                width: 230,
                                fit: BoxFit.contain,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    FadeTransition(
                      opacity: _titleFade,
                      child: SlideTransition(
                        position: _titleSlide,
                        child: _AnimatedMoodlyTitle(controller: _introController),
                      ),
                    ),

                    const SizedBox(height: 8),

                    FadeTransition(
                      opacity: _subtitleFade,
                      child: const Text(
                        'Tempat kecil untuk merasa,\nmenulis, dan pulih pelan-pelan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: textSub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              Positioned(
                bottom: 50,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _subtitleFade,
                  child: Column(
                    children: [
                      SizedBox(
                        width: 120,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            valueColor: const AlwaysStoppedAnimation(pinkMain),
                            backgroundColor: greenSoft.withOpacity(0.45),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Menyiapkan ruang amanmu...',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF8A9580),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _blob({required double size, required Color color}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }

  Widget _sparkle({required double size, required Color color}) {
    return Icon(
      Icons.auto_awesome_rounded,
      size: size,
      color: color,
    );
  }
}

class _AnimatedMoodlyTitle extends AnimatedWidget {
  const _AnimatedMoodlyTitle({
    required AnimationController controller,
  }) : super(listenable: controller);

  AnimationController get controller => listenable as AnimationController;

  @override
  Widget build(BuildContext context) {
    const textDark = Color(0xFF222222);

    final double restOpacity = CurvedAnimation(
      parent: controller,
      curve: const Interval(0.58, 0.88, curve: Curves.easeOut),
    ).value;

    final double restOffsetY = Tween<double>(
      begin: 10,
      end: 0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.58, 0.88, curve: Curves.easeOutCubic),
      ),
    ).value;

    final double mScale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(0.42, 0.68, curve: Curves.easeOutBack),
      ),
    ).value;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Transform.scale(
          scale: mScale,
          child: const Text(
            'M',
            style: TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.w900,
              color: textDark,
              letterSpacing: 0.4,
            ),
          ),
        ),
        Transform.translate(
          offset: Offset(0, restOffsetY),
          child: Opacity(
            opacity: restOpacity,
            child: const Text(
              'oodly',
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w900,
                color: textDark,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}