// Flutter material package for core UI widgets like Scaffold, Container, Text, Icon, etc.
import 'package:flutter/material.dart';

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
    // Main page layout.
    // Uses a Stack so the floating navbar can sit above the page content.
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      // App title metadata.
      title: 'Anonymous Chat Home',
      // Global theme used across this demo page.
      theme: ThemeData(
        // Material 3 styling enabled.
        useMaterial3: true,
        // Background color for Scaffold by default.
        scaffoldBackgroundColor: const Color(0xFFDDE2C4),
        // Rounded playful font if available in the project.
        fontFamily: 'SFProDisplay',
      ),
      // First screen shown when the app launches.
      home: const AnonymousChatHomePage(),
    );
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
  int selectedGenderIndex = 0;

  // Tracks which bottom navigation item is active.
  // Default is 2 because Connect is selected in the design.
  int selectedNavIndex = 2;

  // Static data for the three gender cards.
  // Each option stores its text, icon, colors, and border style.

  final List<_GenderOption> genders = const [
    _GenderOption(
      label: 'Laki-laki',
      icon: Icons.male_rounded,
      background: Color(0xFFBFE5FF),
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
      background: Color(0xFFFFD7DB),
      border: Color(0xFFC97B26),
      iconColor: Color(0xFFF8FAFF),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // SafeArea keeps content away from system UI like the notch/status bar.
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFDDE2C4),
              ),
              child: Column(
                children: [
                  Expanded(
                    // Makes the content scroll if vertical space becomes tight.
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 170),
                      // Extra bottom padding keeps content from being hidden behind the floating navbar.
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(), // Top back arrow + page title
                          const SizedBox(height: 88),
                          _buildCenterContent(), // Avatar + nickname + subtitle
                          const SizedBox(height: 44),
                          Align(
                            alignment: Alignment.centerRight,
                            child: _buildProfileButton(), // Small green action button on the right
                          ),
                          const SizedBox(height: 12),
                          _buildFilterCard(), // Bottom card containing gender filter and CTA
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // NAVBAR STARTS HERE
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: _buildFloatingBottomNav(),
            // ),
            // NAVBAR ENDS HERE
          ],
        ),
      ),
    );
  }

  // Top header section.
// Contains the back button and page title.
  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          // Small touch area for the back icon.
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Ruang Curhat',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.black,
            letterSpacing: -0.3,
          ),
        ),
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
            // Outer avatar circle with soft gradient/shadow for depth.
            width: 108,
            height: 108,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF6D9DD), Color(0xFFCAAFAF)],
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Container(
                // Inner pink face circle.
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF97A6),
                ),
                child: CustomPaint(
                  // Face details are hand-drawn with CustomPainter.
                  painter: _CuteFacePainter(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Spaghetti Unyu',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: Colors.black,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Mulailah Mengobrol!',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  // Green rounded button on the right.
// In the screenshot this acts like a profile setup shortcut.
  Widget _buildProfileButton() {
    return Container(
      width: 127,
      height: 39,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [Color(0xFF78B95B), Color(0xFF8FD16F)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F4F7E36),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: const Text(
        'Atur Profil',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  // Rounded card above the navbar.
// Holds filter title, gender options, CTA button, and helper text.
  Widget _buildFilterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F4D6), Color(0xFFD6EDBC)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x336EA04D),
            blurRadius: 18,
            offset: Offset(0, -2),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Text(
                'Filter Gender',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 6),
              Text('👑', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(genders.length, (index) {
              // Builds each gender card from the genders list.
              final option = genders[index];
              final isSelected = selectedGenderIndex == index;
              // Highlights the currently selected card.
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: index == genders.length - 1 ? 0 : 12),
                  child: GestureDetector(
                    onTap: () {
                      // Updates selected card and redraws the widget.
                      setState(() {
                        selectedGenderIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      // Smoothly animates border/visual changes when selection changes.
                      duration: const Duration(milliseconds: 180),
                      height: 74,
                      decoration: BoxDecoration(
                        color: option.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? option.border : option.border.withOpacity(0.7),
                          width: isSelected ? 2.0 : 1.4,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            option.icon,
                            size: 26,
                            color: isSelected ? option.iconColor : const Color(0xFF88B97A),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option.label,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 16),
          Container(
            // Primary call-to-action button.
            width: double.infinity,
            height: 46,
            decoration: BoxDecoration(
              color: const Color(0xFF84C76A),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Text(
              'Mulai Bercerita',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: RichText(
              // Mixed-style text so "peraturan kami" can be highlighted in green.
              textAlign: TextAlign.center,
              text: const TextSpan(
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.35,
                ),
                children: [
                  TextSpan(text: 'Tolong hormati orang lain dan patuhi '),
                  TextSpan(
                    text: 'peraturan kami',
                    style: TextStyle(
                      color: Color(0xFF7DCB66),
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Floating bottom navigation bar.
// Built with Stack so the center Connect button can sit above the bar.
  Widget _buildFloatingBottomNav() {
    return SizedBox(
      // Fixed height area reserved for the navbar and floating center button.
      height: 130,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 18,
            child: Center(
              child: Container(
                width: 402,
                height: 86,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(34),
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xFFBEE1AE), Color(0xFFA7D590)],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x2D6EA04D),
                      blurRadius: 20,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: CustomPaint(
                  painter: _NavBarNotchPainter(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.home_outlined,
                            label: 'Beranda',
                            selected: selectedNavIndex == 0,
                            onTap: () {
                              setState(() => selectedNavIndex = 0);
                            },
                          ),
                        ),
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.eco_outlined,
                            label: 'Diary',
                            selected: selectedNavIndex == 1,
                            onTap: () {
                              setState(() => selectedNavIndex = 1);
                            },
                          ),
                        ),
                        const SizedBox(width: 78), // Empty gap reserved for the center floating button
                        Expanded(
                          child: _BottomNavItem(
                            icon: Icons.local_florist_outlined,
                            label: 'Affirmasi',
                            selected: selectedNavIndex == 3,
                            onTap: () {
                              setState(() => selectedNavIndex = 3);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 38,
            child: GestureDetector(
              onTap: () {
                // Marks Connect as active when the floating button is tapped.
                setState(() => selectedNavIndex = 2);
              },
              child: Container(
                // Circular floating center action button.
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF5F5F1),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ],
                  border: Border.all(color: const Color(0xFFF0F0E8), width: 3),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.forum_rounded,
                      color: Color(0xFF8ABC76),
                      size: 24,
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Connect',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF8ABC76),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

// Reusable widget for the bottom nav items.
class _BottomNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Selected item gets stronger contrast, inactive items stay soft.
    final color = selected ? Colors.white : const Color(0xFFF0F8E8);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
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

    canvas.drawCircle(const Offset(16, 39), 2.1, eyePaint..style = PaintingStyle.fill);
    canvas.drawCircle(const Offset(64, 39), 2.1, eyePaint..style = PaintingStyle.fill);

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
  @override
  void paint(Canvas canvas, Size size) {
    // Soft shadow under the navbar shape.
    final shadowPaint = Paint()
      ..color = const Color(0x15000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    // Gradient fill for the navbar body.
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBEE1AE), Color(0xFFA7D590)],
      ).createShader(Offset.zero & size);

    // Path defines the custom curved outline of the navbar.
    final path = Path();
    final radius = 34.0;
    // Controls how wide the center notch area feels.
    final notchRadius = 46.0;
    // Controls how deep the top notch dips downward.
    final notchDepth = 22.0;
    final centerX = size.width / 2;

    path.moveTo(radius, 0);
    path.lineTo(centerX - notchRadius - 20, 0);
    path.cubicTo(
      centerX - notchRadius + 2,
      0,
      centerX - notchRadius + 10,
      notchDepth,
      centerX,
      notchDepth,
    );
    path.cubicTo(
      centerX + notchRadius - 10,
      notchDepth,
      centerX + notchRadius - 2,
      0,
      centerX + notchRadius + 20,
      0,
    );
    path.lineTo(size.width - radius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, radius);
    path.lineTo(size.width, size.height - radius);
    path.quadraticBezierTo(size.width, size.height, size.width - radius, size.height);
    path.lineTo(radius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - radius);
    path.lineTo(0, radius);
    path.quadraticBezierTo(0, 0, radius, 0);
    path.close();

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
