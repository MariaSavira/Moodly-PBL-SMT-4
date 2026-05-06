import 'package:flutter/material.dart';
import '../../core/moodly_colors.dart';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(
                title: "Pilih Bahasa",
                onBack: () => Navigator.pop(context),
              ),

              const SizedBox(height: 30),

              const Text(
                "Pilih Bahasa",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                "Pilih bahasa utama Anda untuk pengalaman perlindungan yang lebih personal.",
                style: TextStyle(fontSize: 14),
              ),

              const SizedBox(height: 24),

              // 🔥 LIST
              Flexible(
                child: ListView.builder(
                  itemCount: languages.length,
                  itemBuilder: (context, index) {
                    final lang = languages[index];
                    final isSelected = selected == lang['code'];

                    if (isSelected) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selected = lang['code']!;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 50,
                                height: 50,
                                decoration: BoxDecoration(
                                  color: MoodlyColors.greenLight,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const Icon(
                                  Icons.translate,
                                  color: MoodlyColors.green,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lang['name']!,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "Sedang aktif",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.check_circle,
                                color: MoodlyColors.green,
                                size: 28,
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selected = lang['code']!;
                        });
                      },
                      child: Container(
                        height: 60,
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                lang['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: MoodlyColors.green,
                                  width: 2,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // 🔥 BUTTON TERAPKAN
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
                        fontWeight: FontWeight.bold,
                      ),
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
}

//
// 🔥 HEADER (WAJIB ADA BIAR GAK ERROR)
//
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
          ),
        ),
      ],
    );
  }
}