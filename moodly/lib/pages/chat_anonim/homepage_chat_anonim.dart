// Flutter material package for core UI widgets like Scaffold, Container, Text, Icon, etc.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';

// App entry point.
// Flutter starts here, then mounts HomeChatAnonim as the root widget.
void main() {
  runApp(const HomeChatAnonim());
}

// Root application widget.
// Keeps global app config like theme, title, and first page.
class HomeChatAnonim extends StatelessWidget {
  const HomeChatAnonim({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnonymousChatHomePage();
  }
}

// Homepage widget.
// Stateful because gender selection and navbar selection can change.
class AnonymousChatHomePage extends StatefulWidget {
  const AnonymousChatHomePage({super.key});

  @override
  State<AnonymousChatHomePage> createState() => _AnonymousChatHomePageState();
}

class _AnonymousChatHomePageState extends State<AnonymousChatHomePage> {
  // Tracks which gender card is selected.
  // 0 = Laki-laki, 1 = Keduanya, 2 = Perempuan.
  int selectedGenderIndex = 1;

  // Tracks which bottom navigation item is active.
  // Default is 2 because Connect is selected in the design.
  int selectedNavIndex = 2;

  int? pressedGenderIndex;
  bool isProfilePressed = false;
  bool isCtaPressed = false;

  // Static data for the three gender cards.
  // Each option stores its text, icon, colors, and border style.

  final List<_NavItemData> navItems = const [
    _NavItemData(
      label: 'Beranda',
      outlineIcon: Icons.home_outlined,
      filledAsset: 'assets/icons/navbar/beranda_filled.svg',
    ),
    _NavItemData(
      label: 'Diary',
      outlineIcon: Icons.eco_outlined,
      filledAsset: 'assets/icons/navbar/diary_filled.svg',
    ),
    _NavItemData(
      label: 'Connect',
      outlineIcon: Icons.forum_outlined,
      filledAsset: 'assets/icons/navbar/connect_filled.svg',
    ),
    _NavItemData(
      label: 'Afirmasi',
      outlineIcon: Icons.local_florist_outlined,
      filledAsset: 'assets/icons/navbar/affirmasi_filled.svg',
    ),
  ];

  final List<_GenderOption> genders = const [
    _GenderOption(
      label: 'Laki-laki',
      icon: Icons.male_rounded,
      background: Color(0xFFA5E2F9),
      border: Color(0xFFC97B26),
      iconColor: Color(0xFFF8FAFF),
    ),
    _GenderOption(
      label: 'Keduanya',
      icon: Icons.transgender_rounded,
      background: Color(0xFFF3F5F2),
      border: Color(0xFFAED48B),
      iconColor: Color(0xFF7FC066),
    ),
    _GenderOption(
      label: 'Perempuan',
      icon: Icons.female_rounded,
      background: Color(0xFFF8BDC0),
      border: Color(0xFFC97B26),
      iconColor: Color(0xFFF8FAFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFF3FADC),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFF3FADC),
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: Color(0xFFE0EBBB),
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFDDE2C4),
        extendBody: true,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(child: Container(color: const Color(0xFFF3FADC))),

              // TOP CONTENT
              Positioned(
                top: 16,
                left: 20,
                right: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 88),
                    _buildCenterContent(),
                    const SizedBox(height: 52),
                  ],
                ),
              ),

              Positioned(right: 20, bottom: 350, child: _buildProfileButton()),

              // BOTTOM SHEET
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFilterCard(),
              ),

              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: IgnorePointer(
                  child: Container(
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                        Color(0x00EFCACC),
                        Color(0x66EFCACC),
                        Color(0xFFEFCACC),
                        ],
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              // FLOATING NAVBAR
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildFloatingBottomNav(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Top header section.
  // Contains the back button and page title.
  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(
          Icons.arrow_back_ios_new_rounded,
          size: 20,
          color: Colors.black87,
        ),
        const SizedBox(width: 6),
        Text('Ruang Curhat', style: Theme.of(context).textTheme.headlineLarge),
      ],
    );
  }

  // Center hero content.
  // Recreates the circular face avatar, anonymous username, and prompt text.
  Widget _buildCenterContent() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 105,
            height: 105,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/profile_pic/PP.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Spaghetti Unyu',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Mulailah Mengobrol!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // Green rounded button on the right.
  // In the screenshot this acts like a profile setup shortcut.
  Widget _buildProfileButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isProfilePressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isProfilePressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isProfilePressed = false;
        });
      },
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AturProfilSheet(),
        );
      },
      child: AnimatedScale(
        scale: isProfilePressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 126,
          height: 36,
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFF82C46B),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              'Atur Profil',
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
        ),
      ),
    );
  }

  // Rounded card above the navbar.
  // Holds filter title, gender options, CTA button, and helper text.
  Widget _buildFilterCard() {
    return Container(
      height: 340,
      decoration: const BoxDecoration(
        color: Color(0xFFDCE9BE),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x33A4CD87),
                      blurRadius: 20,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 138),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Filter Gender',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _buildGenderOptions(),
                const SizedBox(height: 16),
                _buildCTAButton(),
                const SizedBox(height: 10),
                _buildHelperText(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderOptions() {
    return Row(
      children: List.generate(genders.length, (index) {
        final option = genders[index];
        final isSelected = selectedGenderIndex == index;
        final isPressed = pressedGenderIndex == index;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == genders.length - 1 ? 0 : 12,
            ),
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  pressedGenderIndex = index;
                });
              },
              onTapUp: (_) {
                setState(() {
                  pressedGenderIndex = null;
                  selectedGenderIndex = index;
                });
              },
              onTapCancel: () {
                setState(() {
                  pressedGenderIndex = null;
                });
              },
              child: AnimatedScale(
                scale: isPressed ? 0.96 : 1.0,
                duration: const Duration(milliseconds: 120),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    SizedBox(
                      height: 74,
                      width: double.infinity,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: option.background,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? option.border
                                : option.border.withOpacity(0.7),
                            width: isSelected ? 2.0 : 1.4,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              size: 26,
                              color: isSelected
                                  ? option.iconColor
                                  : const Color(0xFF88B97A),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              option.label,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (index != 1)
                      Positioned(
                        top: -8,
                        right: 6,
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: Image.asset(
                            'assets/icons/crown.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildCTAButton() {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          isCtaPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          isCtaPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          isCtaPressed = false;
        });
      },
      onTap: () {
        // TODO: action for CTA button
      },
      child: AnimatedScale(
        scale: isCtaPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          width: double.infinity,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF84C76A),
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.center,
          child: Text(
            'Mulai Bercerita',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ),
      ),
    );
  }

  Widget _buildHelperText() {
    return Center(
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(height: 1.2, color: Colors.black87),
          children: [
            const TextSpan(text: 'Tolong hormati orang lain dan patuhi '),
            TextSpan(
              text: 'peraturan kami',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF7DCB66),
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Floating bottom navigation bar.
  // Built with Stack so the center Connect button can sit above the bar.
Widget _buildFloatingBottomNav() {
  const double navHeight = 84;
  const double bubbleSize = 60;
  const double outerBottom = 14;
  const double horizontalMargin = 10;
  const double navHorizontalPadding = 12;
  const Duration animDuration = Duration(milliseconds: 260);

  return SizedBox(
    height: 126,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final double barWidth = constraints.maxWidth - (horizontalMargin * 2);
        final double contentWidth = barWidth - (navHorizontalPadding * 2);
        final double itemWidth = contentWidth / navItems.length;

        final List<double> slotCenters = List.generate(
          navItems.length,
          (index) =>
              navHorizontalPadding + (itemWidth * index) + (itemWidth / 2),
        );

        final double selectedCenterX = slotCenters[selectedNavIndex];
        final double bubbleLeft =
            horizontalMargin + selectedCenterX - (bubbleSize / 2);

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: horizontalMargin,
              right: horizontalMargin,
              bottom: outerBottom,
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(end: selectedCenterX),
                duration: animDuration,
                curve: Curves.easeOutCubic,
                builder: (context, animatedCenterX, _) {
                  return CustomPaint(
                    painter: _NavBarNotchPainter(
                      selectedCenterX: animatedCenterX,
                    ),
                    child: SizedBox(
                      height: navHeight,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          navHorizontalPadding,
                          8,
                          navHorizontalPadding,
                          10,
                        ),
                        child: Row(
                          children: List.generate(navItems.length, (index) {
                            final item = navItems[index];
                            final isSelected = selectedNavIndex == index;

                            return SizedBox(
                              width: itemWidth,
                              child: _BottomNavItem(
                                icon: item.outlineIcon,
                                label: item.label,
                                selected: isSelected,
                                filledAsset: item.filledAsset,
                                onTap: () {
                                  if (selectedNavIndex == index) return;
                                  setState(() {
                                    selectedNavIndex = index;
                                  });
                                },
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            AnimatedPositioned(
              duration: animDuration,
              curve: Curves.easeOutCubic,
              left: bubbleLeft,
              bottom: outerBottom + 56,
              child: Container(
                width: bubbleSize,
                height: bubbleSize,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFF5F5F1),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x4D000000), // 30%
                      offset: Offset(0, 10),
                      blurRadius: 20,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 180),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: 0.92,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: SvgPicture.asset(
                      navItems[selectedNavIndex].filledAsset,
                      key: ValueKey(navItems[selectedNavIndex].filledAsset),
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}
}

// Simple data model for each gender card.
class _GenderOption {
  final String label;
  final IconData icon;
  final Color background;
  final Color border;
  final Color iconColor;

  const _GenderOption({
    required this.label,
    required this.icon,
    required this.background,
    required this.border,
    required this.iconColor,
  });
}

class _NavItemData {
  final String label;
  final IconData outlineIcon;
  final String filledAsset;

  const _NavItemData({
    required this.label,
    required this.outlineIcon,
    required this.filledAsset,
  });
}

// Reusable widget for the bottom nav items.
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final String filledAsset;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.filledAsset,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color inactiveColor = Color(0xFFEBF4E6);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        // Drastically push the active item down into the cutout area
        padding: EdgeInsets.only(top: selected ? 22 : 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AnimatedOpacity(
              duration: const Duration(milliseconds: 160),
              opacity: selected ? 0.0 : 1.0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 160),
                scale: selected ? 0.6 : 1.0,
                child: Icon(icon, color: inactiveColor, size: 26),
              ),
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              style: TextStyle(
                color: selected ? Colors.white : inactiveColor,
                fontSize: selected ? 13.0 : 12.0,
                fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                letterSpacing: selected ? 0.2 : 0,
              ),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Paints the small face inside the avatar.
// Using CustomPainter makes it easy to mimic the exact playful expression.
class _CuteFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Paint objects define how strokes/fills will look.
    final eyePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cheekPaint = Paint()
      ..color = const Color(0xFFEA6E80)
      ..style = PaintingStyle.fill;

    final mouthPaint = Paint()
      ..color = Colors.black
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(
      const Offset(16, 39),
      2.1,
      eyePaint..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      const Offset(64, 39),
      2.1,
      eyePaint..style = PaintingStyle.fill,
    );

    eyePaint.style = PaintingStyle.stroke;
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(16, 36), radius: 5),
      3.8,
      1.0,
      false,
      eyePaint,
    );
    canvas.drawArc(
      Rect.fromCircle(center: const Offset(64, 36), radius: 5),
      5.7,
      1.0,
      false,
      eyePaint,
    );

    canvas.drawCircle(const Offset(14, 50), 2.2, cheekPaint);
    canvas.drawCircle(const Offset(66, 50), 2.2, cheekPaint);

    // Smiling mouth path.
    final mouthPath = Path()
      ..moveTo(24, 49)
      ..quadraticBezierTo(41, 62, 57, 49);
    canvas.drawPath(mouthPath, mouthPaint);

    canvas.drawArc(
      const Rect.fromLTWH(28, 40, 9, 8),
      0.6,
      1.7,
      false,
      mouthPaint,
    );

    canvas.drawArc(
      const Rect.fromLTWH(52, 42, 6, 10),
      -0.2,
      1.4,
      false,
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Paints the floating navbar background with a center notch.
// The notch visually makes space for the circular Connect button.
class _NavBarNotchPainter extends CustomPainter {
  final double selectedCenterX;

  _NavBarNotchPainter({required this.selectedCenterX});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = const Color(0x4D000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    final Paint fillPaint = Paint()
      ..color = const Color(0xFFB5E0A6);

    const double cornerRadius = 32.0;
    const double notchRadius = 38.0; // Wider
    const double notchDepth = 48.0; // Deeper
    const double shoulderSpread = 28.0;

    // Do NOT clamp the center. Let it bleed out of bounds to carve out the edge corners perfectly!
    final double center = selectedCenterX;
    final double leftStart = center - notchRadius - shoulderSpread;
    final double rightEnd = center + notchRadius + shoulderSpread;

    // 1. The perfect Base Rounded Rectangle
    final RRect baseRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(cornerRadius),
    );
    final Path basePath = Path()..addRRect(baseRRect);

    // 2. The Shape we want to "cut out" of the base
    final Path notchPath = Path()
      ..moveTo(leftStart, -50) // Start high above the container
      ..lineTo(leftStart, 0)
      ..cubicTo(
        leftStart + shoulderSpread * 0.7,
        0,
        center - notchRadius * 0.8,
        notchDepth,
        center,
        notchDepth,
      )
      ..cubicTo(
        center + notchRadius * 0.8,
        notchDepth,
        rightEnd - shoulderSpread * 0.7,
        0,
        rightEnd,
        0,
      )
      ..lineTo(rightEnd, -50)
      ..close();

    // 3. Subtract the notch from the base container
    final Path finalPath = Path.combine(
      PathOperation.difference,
      basePath,
      notchPath,
    );

    // Draw shadow slightly shifted down to prevent it muddying up the inside of the hole
    canvas.save();
    canvas.translate(0, 10);
    canvas.drawPath(finalPath, shadowPaint);
    canvas.restore();

    canvas.drawPath(finalPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _NavBarNotchPainter oldDelegate) {
    return oldDelegate.selectedCenterX != selectedCenterX;
  }
}

class AturProfilSheet extends StatefulWidget {
  const AturProfilSheet({super.key});

  @override
  State<AturProfilSheet> createState() => _AturProfilSheetState();
}

class _AturProfilSheetState extends State<AturProfilSheet> {
  final TextEditingController controller =
      TextEditingController(text: "Spaghetti Unyu");

  bool showAvatarPicker = false;

  int selectedAvatar = 0;

  final List<String> avatars = List.generate(
    12,
    (i) => 'assets/profile_pic/avatar_$i.png',
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.4),
      body: SafeArea(
        child: Stack(
          children: [
            // MAIN CONTENT
            Column(
              children: [
                const SizedBox(height: 20),

                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Atur Profil",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                // AVATAR
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showAvatarPicker = !showAvatarPicker;
                    });
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage(avatars[selectedAvatar]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // INPUT NAMA
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: TextField(
                    controller: controller,
                    maxLength: 20,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      counterText: "",
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "*Jangan gunakan nama asli\n*Maksimal 20 huruf",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),

                const Spacer(),

                // BUTTON
                Padding(
                  padding: const EdgeInsets.only(right: 20, bottom: 120),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 26, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF84C76A),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        "Konfirmasi",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // AVATAR PICKER (BOTTOM)
            if (showAvatarPicker)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  height: 260,
                  decoration: const BoxDecoration(
                    color: Color(0xFFEAF5DE),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: avatars.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                    ),
                    itemBuilder: (_, index) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedAvatar = index;
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: selectedAvatar == index
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              avatars[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
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
}