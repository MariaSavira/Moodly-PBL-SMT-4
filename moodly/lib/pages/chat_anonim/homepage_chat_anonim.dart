import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/auth_service.dart';
import 'profil_anonim.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ruang_chat.dart';

// App entry point.
void main() {
  runApp(const HomeChatAnonim());
}

// Root application widget.
class HomeChatAnonim extends StatelessWidget {
  const HomeChatAnonim({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnonymousChatHomePage();
  }
}

// Homepage widget.
class AnonymousChatHomePage extends StatefulWidget {
  const AnonymousChatHomePage({super.key});

  @override
  State<AnonymousChatHomePage> createState() => _AnonymousChatHomePageState();
}

class _AnonymousChatHomePageState extends State<AnonymousChatHomePage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    final user = await _authService.signInAnonymously();
    print('AUTH UID: ${user?.uid}');

    await loadProfileData();

    if (!mounted) return;

    await syncUserProfileToFirestore();
    print('SYNC PROFILE TO FIRESTORE SUCCESS');
  }

  Future<void> syncUserProfileToFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      print('FIRESTORE SYNC BATAL: user null');
      return;
    }

    print('SYNCING USER: ${user.uid}');
    print('nickname: $profileName');
    print('avatarId: $selectedProfileImage');

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'uid': user.uid,
      'nickname': profileName,
      'avatarId': selectedProfileImage,
      'status': 'idle',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    print('FIRESTORE WRITE BERHASIL');
  }

  int selectedGenderIndex = 1;
  int selectedNavIndex = 2;

  int? pressedGenderIndex;
  bool isProfilePressed = false;
  bool isCtaPressed = false;

  bool showProfileOverlay = false;

  String profileName = 'Spaghetti Unyu';
  String selectedProfileImage = 'assets/profile_pic/PP.png';

  final List<String> profileAvatars = const [
    'assets/profile_pic/PP.png',
    'assets/profile_pic/PP_2.png',
    'assets/profile_pic/PP_3.png',
    'assets/profile_pic/PP_4.png',
    'assets/profile_pic/PP_5.png',
    'assets/profile_pic/PP_6.png',
    'assets/profile_pic/PP_7.png',
    'assets/profile_pic/PP_8.png',
    'assets/profile_pic/PP_9.png',
    'assets/profile_pic/PP_10.png',
    'assets/profile_pic/PP_11.png',
    'assets/profile_pic/PP_12.png',
    'assets/profile_pic/PP_13.png',
    'assets/profile_pic/PP_14.png',
    'assets/profile_pic/PP_15.png',
    'assets/profile_pic/PP_16.png',
    'assets/profile_pic/PP_17.png',
    'assets/profile_pic/PP_18.png',
    'assets/profile_pic/PP_19.png',
    'assets/profile_pic/PP_20.png',
    'assets/profile_pic/PP_21.png',
    'assets/profile_pic/PP_22.png',
  ];

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

  Future<void> loadProfileData() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      profileName = prefs.getString('profileName') ?? 'Spaghetti Unyu';
      selectedProfileImage =
          prefs.getString('selectedProfileImage') ??
          'assets/profile_pic/PP.png';
    });
  }

  Future<void> saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileName', profileName);
    await prefs.setString('selectedProfileImage', selectedProfileImage);
  }

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
        resizeToAvoidBottomInset: false,
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
                    Opacity(
                      opacity: showProfileOverlay ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: showProfileOverlay,
                        child: _buildHeader(),
                      ),
                    ),
                    const SizedBox(height: 88),
                    Opacity(
                      opacity: showProfileOverlay ? 0.0 : 1.0,
                      child: IgnorePointer(
                        ignoring: showProfileOverlay,
                        child: _buildCenterContent(),
                      ),
                    ),
                    const SizedBox(height: 52),
                  ],
                ),
              ),

              Positioned(
                right: 20,
                bottom: 350,
                child: Opacity(
                  opacity: showProfileOverlay ? 0.0 : 1.0,
                  child: IgnorePointer(
                    ignoring: showProfileOverlay,
                    child: _buildProfileButton(),
                  ),
                ),
              ),

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
                    decoration: const BoxDecoration(
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
              child: Image.asset(selectedProfileImage, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 18),
          Text(profileName, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Mulailah Mengobrol!',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

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
      onTap: () async {
        FocusScope.of(context).unfocus();

        setState(() {
          showProfileOverlay = true;
        });

        final result = await Navigator.of(context).push(
          PageRouteBuilder(
            opaque: false,
            barrierDismissible: false,
            pageBuilder: (context, animation, secondaryAnimation) =>
                ProfileOverlayPage(
                  profileName: profileName,
                  selectedProfileImage: selectedProfileImage,
                  profileAvatars: profileAvatars,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
            transitionDuration: const Duration(milliseconds: 150),
            reverseTransitionDuration: const Duration(milliseconds: 150),
          ),
        );

        if (!mounted) return;

        setState(() {
          showProfileOverlay = false;
        });

        if (result is Map<String, dynamic>) {
          setState(() {
            profileName = result['profileName'] as String;
            selectedProfileImage = result['selectedProfileImage'] as String;
          });

          await saveProfileData();
          await syncUserProfileToFirestore();
        }
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
                Text(
                  'Filter Gender',
                  style: Theme.of(context).textTheme.bodySmall,
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
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ChatAnonimPage(),
          ),
        );
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
                        color: Color(0x4D000000),
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
              child: Text(label, maxLines: 1, overflow: TextOverflow.visible),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarNotchPainter extends CustomPainter {
  final double selectedCenterX;

  _NavBarNotchPainter({required this.selectedCenterX});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint shadowPaint = Paint()
      ..color = const Color(0x30000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final Paint fillPaint = Paint()..color = const Color(0xFFB5E0A6);

    const double cornerRadius = 32.0;
    const double notchDepth = 30.0;
    const double notchHalfWidth = 44.0;
    const double shoulderWidth = 22.0;

    final double center = selectedCenterX.clamp(
      notchHalfWidth + shoulderWidth + 12,
      size.width - notchHalfWidth - shoulderWidth - 12,
    );

    final double leftShoulder = center - notchHalfWidth - shoulderWidth;
    final double leftDipStart = center - notchHalfWidth;
    final double rightDipEnd = center + notchHalfWidth;
    final double rightShoulder = center + notchHalfWidth + shoulderWidth;

    final Path path = Path()
      ..moveTo(cornerRadius, 0)
      ..lineTo(leftShoulder, 0)
      ..cubicTo(
        leftShoulder + shoulderWidth * 0.45,
        0,
        leftDipStart - shoulderWidth * 0.35,
        notchDepth * 0.18,
        leftDipStart,
        notchDepth * 0.42,
      )
      ..cubicTo(
        center - notchHalfWidth * 0.55,
        notchDepth,
        center + notchHalfWidth * 0.55,
        notchDepth,
        rightDipEnd,
        notchDepth * 0.42,
      )
      ..cubicTo(
        rightDipEnd + shoulderWidth * 0.35,
        notchDepth * 0.18,
        rightShoulder - shoulderWidth * 0.45,
        0,
        rightShoulder,
        0,
      )
      ..lineTo(size.width - cornerRadius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, cornerRadius)
      ..lineTo(size.width, size.height - cornerRadius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - cornerRadius,
        size.height,
      )
      ..lineTo(cornerRadius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - cornerRadius)
      ..lineTo(0, cornerRadius)
      ..quadraticBezierTo(0, 0, cornerRadius, 0)
      ..close();

    canvas.save();
    canvas.translate(0, 8);
    canvas.drawPath(path, shadowPaint);
    canvas.restore();

    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _NavBarNotchPainter oldDelegate) {
    return oldDelegate.selectedCenterX != selectedCenterX;
  }
}
