import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../homepage.dart';
import '../setting/moodly_settings_support.dart';
import 'detail_afirmasi_page.dart';
import 'widgets/cute_top_popup.dart';

class AfirmasiPage extends StatefulWidget {
  final bool forcePicker;

  const AfirmasiPage({
    super.key,
    this.forcePicker = false,
  });

  static const String categoriesPrefKey = 'afirmasi_selected_categories';
  static const List<String> legacyCategoryKeys = [
    'selectedAfirmasiCategories',
    'selected_affirmation_categories',
    'afirmasi_categories',
  ];

  static Future<List<String>> loadSavedCategories() async {
    final prefs = await SharedPreferences.getInstance();

    final primary = prefs.getStringList(categoriesPrefKey);
    if (primary != null && primary.isNotEmpty) {
      return primary.where((e) => e.trim().isNotEmpty).toList();
    }

    for (final key in legacyCategoryKeys) {
      final legacy = prefs.getStringList(key);
      if (legacy != null && legacy.isNotEmpty) {
        return legacy.where((e) => e.trim().isNotEmpty).toList();
      }
    }

    return <String>[];
  }

  static Future<void> clearSavedCategories() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(categoriesPrefKey);
    for (final key in legacyCategoryKeys) {
      if (key != categoriesPrefKey) {
        await prefs.remove(key);
      }
    }
  }

  static Future<Widget> resolveEntryPage({
    bool forcePicker = false,
  }) async {
    if (forcePicker) {
      return const AfirmasiPage(forcePicker: true);
    }

    final saved = await loadSavedCategories();
    if (saved.isNotEmpty) {
      return DetailAfirmasiPage(selectedCategories: saved);
    }

    return const AfirmasiPage(forcePicker: true);
  }

  @override
  State<AfirmasiPage> createState() => _AfirmasiPageState();
}

class _AfirmasiPageState extends State<AfirmasiPage> {
  static const Color _bg = Color(0xFFF3F7E8);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF96D47E);
  static const Color _greenDark = Color(0xFF5E9E4F);
  static const Color _greenSoft = Color(0xFFE4F4D7);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6F7866);

  static const List<Map<String, dynamic>> _categories = [
    {
      'raw': 'Rasa Syukur',
      'color': Color(0xFFB7D99A),
      'icon': Icons.eco_rounded,
      'iconColor': Color(0xFF4E7B3F),
    },
    {
      'raw': 'Meredakan Kecemasan',
      'color': Color(0xFFFFE0E2),
      'icon': Icons.air_rounded,
      'iconColor': Color(0xFFC97C86),
    },
    {
      'raw': 'Motivasi',
      'color': Color(0xFFD9ED84),
      'icon': Icons.wb_sunny_outlined,
      'iconColor': Color(0xFF768B2E),
    },
    {
      'raw': 'Kesehatan Mental',
      'color': Color(0xFF9DDBF7),
      'icon': Icons.self_improvement_rounded,
      'iconColor': Color(0xFF2D8DB1),
    },
    {
      'raw': 'Cinta Diri',
      'color': Color(0xFFF5B2BC),
      'icon': Icons.favorite_rounded,
      'iconColor': Color(0xFFA84F62),
    },
  ];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'heroTitle': 'Afirmasi untukmu',
      'heroBody':
          'Pilih sampai 3 kategori yang paling kamu butuhkan sekarang.',
      'selectedChip': '{count}/3 kategori dipilih',
      'selected': 'Dipilih',
      'continue': 'Lanjutkan',
      'maxTitle': 'Maksimal 3 kategori',
      'maxBody':
          'Pilih sampai 3 kategori saja biar afirmasinya tetap terasa personal.',
      'emptyTitle': 'Pilih kategori dulu',
      'emptyBody':
          'Pilih minimal 1 kategori afirmasi untuk melanjutkan.',
      'gratitude': 'Rasa Syukur',
      'gratitudeDesc': 'Untuk mengingat hal kecil yang tetap berarti.',
      'anxiety': 'Meredakan Kecemasan',
      'anxietyDesc': 'Untuk menenangkan pikiran yang sedang ramai.',
      'motivation': 'Motivasi',
      'motivationDesc': 'Untuk bantu kamu tetap melangkah pelan-pelan.',
      'mental': 'Kesehatan Mental',
      'mentalDesc': 'Untuk ruang yang lebih lembut bagi isi kepala.',
      'selfLove': 'Cinta Diri',
      'selfLoveDesc': 'Untuk mengingat bahwa kamu juga pantas dipeluk.',
    },
    'en': {
      'heroTitle': 'Affirmations for you',
      'heroBody': 'Pick up to 3 categories that feel most needed right now.',
      'selectedChip': '{count}/3 categories selected',
      'selected': 'Selected',
      'continue': 'Continue',
      'maxTitle': 'Maximum 3 categories',
      'maxBody':
          'Choose up to 3 categories so the affirmations still feel personal.',
      'emptyTitle': 'Pick a category first',
      'emptyBody': 'Choose at least 1 affirmation category to continue.',
      'gratitude': 'Gratitude',
      'gratitudeDesc': 'To remember the small things that still matter.',
      'anxiety': 'Ease Anxiety',
      'anxietyDesc': 'To calm a mind that feels a little too loud.',
      'motivation': 'Motivation',
      'motivationDesc': 'To help you keep moving, slowly but surely.',
      'mental': 'Mental Health',
      'mentalDesc': 'For a softer space for everything in your head.',
      'selfLove': 'Self Love',
      'selfLoveDesc': 'To remember that you deserve tenderness too.',
    },
  };

  final List<String> selectedCategories = [];
  bool _isCheckingSavedCategories = true;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 10),
          blurRadius: 24,
        ),
      ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _bootstrapFlow();
    });
  }

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? _copy['id']![key] ?? key;

  String _categoryLabel(String languageCode, String raw) {
    switch (raw) {
      case 'Rasa Syukur':
        return _t(languageCode, 'gratitude');
      case 'Meredakan Kecemasan':
        return _t(languageCode, 'anxiety');
      case 'Motivasi':
        return _t(languageCode, 'motivation');
      case 'Kesehatan Mental':
        return _t(languageCode, 'mental');
      case 'Cinta Diri':
        return _t(languageCode, 'selfLove');
      default:
        return raw;
    }
  }

  Future<void> _bootstrapFlow() async {
    if (widget.forcePicker) {
      if (!mounted) return;
      setState(() {
        _isCheckingSavedCategories = false;
      });
      return;
    }

    final saved = await AfirmasiPage.loadSavedCategories();
    if (!mounted) return;

    if (saved.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DetailAfirmasiPage(
            selectedCategories: saved,
          ),
        ),
      );
      return;
    }

    setState(() {
      _isCheckingSavedCategories = false;
    });
  }

  Future<void> _saveSelectedCategories() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      AfirmasiPage.categoriesPrefKey,
      List<String>.from(selectedCategories),
    );

    for (final key in AfirmasiPage.legacyCategoryKeys) {
      if (key != AfirmasiPage.categoriesPrefKey) {
        await prefs.remove(key);
      }
    }
  }

  void _openHomepage() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Homepage()),
      (route) => false,
    );
  }

  void _toggleCategory(String languageCode, String kategori) {
    setState(() {
      if (selectedCategories.contains(kategori)) {
        selectedCategories.remove(kategori);
      } else {
        if (selectedCategories.length >= 3) {
          showCuteTopPopup(
            context,
            title: _t(languageCode, 'maxTitle'),
            message: _t(languageCode, 'maxBody'),
            type: CutePopupType.warning,
          );
          return;
        }
        selectedCategories.add(kategori);
      }
    });
  }

  Future<void> _goToDetailPage(String languageCode) async {
    if (selectedCategories.isEmpty) {
      showCuteTopPopup(
        context,
        title: _t(languageCode, 'emptyTitle'),
        message: _t(languageCode, 'emptyBody'),
        type: CutePopupType.warning,
      );
      return;
    }

    await _saveSelectedCategories();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DetailAfirmasiPage(
          selectedCategories: List<String>.from(selectedCategories),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingSavedCategories) {
      return const Scaffold(
        backgroundColor: _bg,
        body: Center(
          child: CircularProgressIndicator(color: _green),
        ),
      );
    }

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
                  top: -56,
                  right: -44,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinkSoft,
                    ),
                  ),
                ),
                Positioned(
                  left: -70,
                  bottom: 120,
                  child: Container(
                    width: 190,
                    height: 190,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _greenSoft.withOpacity(0.72),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 148),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TopBar(onBack: _openHomepage),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                        decoration: BoxDecoration(
                          color: _card.withOpacity(0.94),
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: _softShadow,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/icon/images/heart_mascot.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                                const SizedBox(width: 8),
                                Image.asset(
                                  'assets/icon/images/brain_mascot.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) =>
                                      const SizedBox.shrink(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(
                              _t(languageCode, 'heroTitle'),
                              textAlign: TextAlign.center,
                              style: textTheme.headlineLarge?.copyWith(
                                color: _textDark,
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
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: _greenSoft,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _t(languageCode, 'selectedChip').replaceFirst(
                                  '{count}',
                                  '${selectedCategories.length}',
                                ),
                                style: textTheme.bodySmall?.copyWith(
                                  color: _greenDark,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      GridView.builder(
                        itemCount: _categories.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.04,
                        ),
                        itemBuilder: (context, index) {
                          final item = _categories[index];
                          final raw = item['raw'] as String;
                          final color = item['color'] as Color;
                          final icon = item['icon'] as IconData;
                          final iconColor = item['iconColor'] as Color;

                          return _CategoryMoodlyCard(
                            title: _categoryLabel(languageCode, raw),
                            color: color,
                            icon: icon,
                            iconColor: iconColor,
                            selectedLabel: _t(languageCode, 'selected'),
                            isSelected: selectedCategories.contains(raw),
                            onTap: () => _toggleCategory(languageCode, raw),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ClipRect(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              _bg.withOpacity(0.02),
                              _bg.withOpacity(0.62),
                              _bg.withOpacity(0.96),
                            ],
                          ),
                        ),
                        child: SafeArea(
                          top: false,
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _card.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: _softShadow,
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              height: 54,
                              child: ElevatedButton(
                                onPressed: () => _goToDetailPage(languageCode),
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: _green,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text(
                                  _t(languageCode, 'continue'),
                                  style: textTheme.labelLarge,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
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

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Material(
          color: Colors.white.withOpacity(0.94),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onBack,
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
      ],
    );
  }
}

class _CategoryMoodlyCard extends StatelessWidget {
  final String title;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final String selectedLabel;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryMoodlyCard({
    required this.title,
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.selectedLabel,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white.withOpacity(0.94),
            borderRadius: BorderRadius.circular(26),
            border: Border.all(
              color: isSelected ? iconColor : color.withOpacity(0.95),
              width: isSelected ? 2 : 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.38),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.06),
                      blurRadius: 18,
                      offset: Offset(0, 8),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              if (isSelected)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.92),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      selectedLabel,
                      style: textTheme.bodySmall?.copyWith(
                        color: iconColor,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: isSelected ? 10 : 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(isSelected ? 0.88 : 1),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.10),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.titleMedium?.copyWith(
                          color: _AfirmasiPageState._textDark,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ],
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