import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  String selected = 'id';

  final List<Map<String, String>> languages = [
    {'code': 'id', 'name': 'Indonesia'},
    {'code': 'en', 'name': 'Inggris'},
    {'code': 'es', 'name': 'Spanyol'},
    {'code': 'fr', 'name': 'Prancis'},
    {'code': 'de', 'name': 'Jerman'},
    {'code': 'jp', 'name': 'Jepang'},
    {'code': 'kr', 'name': 'Korea'},
    {'code': 'hi', 'name': 'India'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 20.0 : 24.0;

            return Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: "Pilih Bahasa",
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    "Pilih Bahasa",
                    style: TextStyle(
                      color: MoodlyColors.textDark,
                      fontSize: isSmall ? 28 : 32,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Pilih bahasa utama Anda untuk pengalaman perlindungan yang lebih personal.",
                    style: TextStyle(
                      color: Colors.black.withOpacity(0.75),
                      fontSize: isSmall ? 13 : 14,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Expanded(
                    child: ListView.builder(
                      itemCount: languages.length,
                      physics: const BouncingScrollPhysics(),
                      itemBuilder: (context, index) {
                        final lang = languages[index];
                        final isSelected = selected == lang['code'];

                        return _LanguageOption(
                          name: lang['name']!,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              selected = lang['code']!;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      height: 52,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: MoodlyColors.green,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          "Terapkan Bahasa",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        height: isSelected ? 76 : 58,
        margin: const EdgeInsets.only(bottom: 14),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 14 : 16,
          vertical: isSelected ? 13 : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.14 : 0.08),
              blurRadius: isSelected ? 12 : 8,
              offset: Offset(0, isSelected ? 5 : 3),
            ),
          ],
        ),
        child: Row(
          children: [
            if (isSelected) ...[
              Container(
                width: isSmall ? 46 : 50,
                height: isSmall ? 46 : 50,
                decoration: BoxDecoration(
                  color: MoodlyColors.greenLight,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.translate_rounded,
                  color: MoodlyColors.green,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSelected ? 18 : 16,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 2),
                    Text(
                      "Sedang aktif",
                      style: TextStyle(
                        color: Colors.black.withOpacity(0.65),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            isSelected
                ? const Icon(
                    Icons.check_circle,
                    color: MoodlyColors.green,
                    size: 28,
                  )
                : Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: MoodlyColors.green,
                        width: 2,
                      ),
                    ),
                  ),
          ],
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