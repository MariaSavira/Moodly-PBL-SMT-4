import 'package:flutter/material.dart';

import '../setting/moodly_settings_support.dart';

class CaraMemasangWidgetPage extends StatelessWidget {
  const CaraMemasangWidgetPage({super.key});

  static const Color _bg = Color(0xFFF3F7E8);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF96D47E);
  static const Color _greenSoft = Color(0xFFE4F4D7);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6F7866);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Cara memasang\nwidget',
      'heroTitle': 'Pasang widget Moodly',
      'heroBody':
          'Biar afirmasi harianmu bisa muncul langsung di home screen dengan tampilan yang lebih hangat dan cepat dilihat.',
      'step1Title': 'Langkah 1',
      'step1Body': 'Tekan dan tahan layar utama\n(home screen).',
      'step2Title': 'Langkah 2',
      'step2Body': 'Pilih menu “Widget”.',
      'step3Title': 'Langkah 3',
      'step3Body':
          'Cari dan pilih widget Moodly\nyang ingin digunakan.',
      'step4Title': 'Langkah 4',
      'step4Body': 'Geser widget ke layar utama,\nlalu lepaskan.',
    },
    'en': {
      'title': 'How to install\nthe widget',
      'heroTitle': 'Install the Moodly widget',
      'heroBody':
          'So your daily affirmation can appear directly on your home screen with a warmer and faster-to-read look.',
      'step1Title': 'Step 1',
      'step1Body': 'Tap and hold the main screen\n(home screen).',
      'step2Title': 'Step 2',
      'step2Body': 'Choose the “Widget” menu.',
      'step3Title': 'Step 3',
      'step3Body':
          'Find and choose the Moodly widget\nyou want to use.',
      'step4Title': 'Step 4',
      'step4Body': 'Drag the widget to the home screen,\nthen release it.',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 10),
          blurRadius: 24,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: MoodlySettingsPrefs.languageNotifier,
      builder: (context, languageCode, _) {
        final textTheme = Theme.of(context).textTheme;

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: -46,
                  right: -36,
                  child: Container(
                    width: 164,
                    height: 164,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinkSoft,
                    ),
                  ),
                ),
                Positioned(
                  left: -56,
                  bottom: 80,
                  child: Container(
                    width: 178,
                    height: 178,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _greenSoft.withOpacity(0.72),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Material(
                            color: Colors.white.withOpacity(0.94),
                            shape: const CircleBorder(),
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              customBorder: const CircleBorder(),
                              child: const SizedBox(
                                width: 46,
                                height: 46,
                                child: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  size: 22,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _t(languageCode, 'title'),
                              textAlign: TextAlign.center,
                              style: textTheme.headlineLarge?.copyWith(
                                color: _textDark,
                                height: 1.08,
                              ),
                            ),
                          ),
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.94),
                              shape: BoxShape.circle,
                              boxShadow: _softShadow,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Image.asset(
                                'assets/icon/images/brain_mascot_tutorial.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const SizedBox(
                                  width: 54,
                                  height: 54,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: _softShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icon/images/heart_mascot.png',
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/icon/images/brain_mascot.png',
                                  width: 46,
                                  height: 46,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _t(languageCode, 'heroTitle'),
                              textAlign: TextAlign.center,
                              style: textTheme.titleMedium?.copyWith(
                                color: _textDark,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t(languageCode, 'heroBody'),
                              textAlign: TextAlign.center,
                              style: textTheme.bodyMedium?.copyWith(
                                color: _textSoft,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      _StepItem(
                        imagePath: 'assets/icon/images/tutorial_step1.png',
                        stepTitle: _t(languageCode, 'step1Title'),
                        description: _t(languageCode, 'step1Body'),
                        imageWidth: 145,
                        imageHeight: 95,
                      ),
                      const SizedBox(height: 20),
                      _StepItem(
                        imagePath: 'assets/icon/images/tutorial_step2.png',
                        stepTitle: _t(languageCode, 'step2Title'),
                        description: _t(languageCode, 'step2Body'),
                        imageWidth: 145,
                        imageHeight: 119,
                      ),
                      const SizedBox(height: 20),
                      _StepItem(
                        imagePath: 'assets/icon/images/tutorial_step3.png',
                        stepTitle: _t(languageCode, 'step3Title'),
                        description: _t(languageCode, 'step3Body'),
                        imageWidth: 145,
                        imageHeight: 118,
                      ),
                      const SizedBox(height: 20),
                      _StepItem(
                        imagePath: 'assets/icon/images/tutorial_step4.png',
                        stepTitle: _t(languageCode, 'step4Title'),
                        description: _t(languageCode, 'step4Body'),
                        imageWidth: 145,
                        imageHeight: 146,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepItem extends StatelessWidget {
  final String imagePath;
  final String stepTitle;
  final String description;
  final double imageWidth;
  final double imageHeight;

  const _StepItem({
    required this.imagePath,
    required this.stepTitle,
    required this.description,
    required this.imageWidth,
    required this.imageHeight,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            offset: Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: imageWidth,
            height: imageHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Image.asset(
                imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFE8E3EA),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_outlined,
                    color: Colors.grey,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE4F4D7),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      stepTitle,
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF5E9E4F),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    description,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      height: 1.5,
                      color: const Color(0xFF2F2F2F),
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
}