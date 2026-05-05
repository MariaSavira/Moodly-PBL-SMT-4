import 'package:flutter/material.dart';
import '../../core/moodly_colors.dart';

class ThemePage extends StatefulWidget {
  const ThemePage({super.key});

  @override
  State<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends State<ThemePage> {
  String selected = 'light';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 24.0 : 48.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: "Pilih Tema",
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 92),

                  const Center(
                    child: Text(
                      "Personalisasikan\nSuaka Anda",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: MoodlyColors.textDark,
                        fontSize: 38,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Center(
                    child: Text(
                      "Sesuaikan antarmuka agar sesuai dengan kondisi\npikiran anda saat ini.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        height: 1.55,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Image.asset(
                      'assets/icon/image3.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.contain,
                    ),
                  ),

                  const SizedBox(height: 2),

                  _ThemeOption(
                    icon: Icons.wb_sunny_rounded,
                    title: "Mode Terang",
                    subtitle: "Cerah, bersih, dan menyegarkan",
                    isSelected: selected == 'light',
                    onTap: () => setState(() => selected = 'light'),
                  ),

                  const SizedBox(height: 28),

                  _ThemeOption(
                    icon: Icons.nightlight_round,
                    title: "Mode Gelap",
                    subtitle: "Lembut di mata untuk beristirahat",
                    isSelected: selected == 'dark',
                    onTap: () => setState(() => selected = 'dark'),
                  ),

                  const SizedBox(height: 28),

                  _ThemeOption(
                    icon: Icons.settings,
                    title: "Bawaan Sistem",
                    subtitle: "Ikut pengaturan perangkat anda",
                    isSelected: selected == 'system',
                    onTap: () => setState(() => selected = 'system'),
                  ),

                  const SizedBox(height: 78),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: width < 500 ? width * 0.78 : 420,
                        height: 58,
                        decoration: BoxDecoration(
                          color: MoodlyColors.green,
                          borderRadius: BorderRadius.circular(32),
                        ),
                        child: const Center(
                          child: Text(
                            "Terapkan Tema",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 27,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: MoodlyColors.green,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          "Moodly",
          style: TextStyle(
            color: Color(0xFFC65F59),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 96,
        padding: const EdgeInsets.symmetric(horizontal: 26),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(48),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: MoodlyColors.bgLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: MoodlyColors.green,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            isSelected
                ? const CircleAvatar(
                    radius: 19,
                    backgroundColor: MoodlyColors.green,
                    child: Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 28,
                    ),
                  )
                : Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MoodlyColors.green,
                        width: 3,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}