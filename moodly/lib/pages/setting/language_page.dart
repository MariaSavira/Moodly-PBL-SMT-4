
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

class LanguagePage extends StatefulWidget {
  final String initialLanguageCode;

  const LanguagePage({
    super.key,
    this.initialLanguageCode = 'id',
  });

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late String _selectedLanguageCode;
  bool _isSaving = false;

  static const List<Map<String, String>> _languages = [
    {'code': 'id', 'nameId': 'Bahasa Indonesia', 'nameEn': 'Indonesian'},
    {'code': 'en', 'nameId': 'Bahasa Inggris', 'nameEn': 'English'},
  ];

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Bahasa',
      'title': 'Pilih Bahasa',
      'description':
          'Atur bahasa yang ingin dipakai di halaman pengaturan terlebih dahulu. Biar rapi dan tidak setengah jadi.',
      'active': 'Sedang aktif',
      'apply': 'Terapkan Bahasa',
    },
    'en': {
      'header': 'Language',
      'title': 'Choose Language',
      'description':
          'Set the language used in the settings flow first. Cleaner, and far less chaotic.',
      'active': 'Currently active',
      'apply': 'Apply Language',
    },
  };

  @override
  void initState() {
    super.initState();
    _selectedLanguageCode = widget.initialLanguageCode == 'en' ? 'en' : 'id';
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;

    setState(() {
      _selectedLanguageCode = (savedLanguage == 'en') ? 'en' : _selectedLanguageCode;
    });
  }

  Future<void> _applyLanguage() async {
    setState(() => _isSaving = true);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, _selectedLanguageCode);

    if (!mounted) return;

    setState(() => _isSaving = false);
    Navigator.pop(context, _selectedLanguageCode);
  }

  String _t(String key) => _copy[_selectedLanguageCode]?[key] ?? key;

  String _labelFor(Map<String, String> item) {
    return _selectedLanguageCode == 'en'
        ? item['nameEn'] ?? ''
        : item['nameId'] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final palette = _SettingsPalette.of();

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          _BackgroundBubbles(palette: palette),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isSmall = width < 380;

                return Center(
                  child: SizedBox(
                    width: width > 430 ? 430 : width,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PageHeader(
                            title: _t('header'),
                            palette: palette,
                            onBack: () => Navigator.pop(context),
                          ),
                          const SizedBox(height: 22),
                          _InfoCard(
                            palette: palette,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _t('title'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        color: palette.textDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _t('description'),
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: palette.textSoft,
                                        height: 1.45,
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 18),
                          Expanded(
                            child: ListView.builder(
                              itemCount: _languages.length,
                              physics: const BouncingScrollPhysics(),
                              itemBuilder: (context, index) {
                                final language = _languages[index];
                                final code = language['code'] ?? 'id';
                                final isSelected = _selectedLanguageCode == code;

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _OptionTile(
                                    palette: palette,
                                    icon: Icons.translate_rounded,
                                    title: _labelFor(language),
                                    subtitle: isSelected ? _t('active') : null,
                                    isSelected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        _selectedLanguageCode = code;
                                      });
                                    },
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            height: isSmall ? 52 : 54,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _applyLanguage,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: palette.greenDark,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.6,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      _t('apply'),
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PageHeader extends StatelessWidget {
  final String title;
  final _SettingsPalette palette;
  final VoidCallback onBack;

  const _PageHeader({
    required this.title,
    required this.palette,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(
            Icons.arrow_back_rounded,
            color: palette.greenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: palette.greenDark,
              ),
        ),
        const Spacer(),
        Text(
          'Moodly',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: palette.brand,
              ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final _SettingsPalette palette;
  final Widget child;

  const _InfoCard({
    required this.palette,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: palette.shadow,
        border: Border.all(color: palette.cardBorder),
      ),
      child: child,
    );
  }
}

class _OptionTile extends StatelessWidget {
  final _SettingsPalette palette;
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _OptionTile({
    required this.palette,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isSelected ? palette.pinkSoft : palette.mintSoft;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: isSelected ? palette.greenDark.withOpacity(0.22) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: palette.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: palette.greenDark, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: subtitle == null
                  ? Text(
                      title,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: palette.textDark,
                          ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: palette.textDark,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: palette.textSoft,
                              ),
                        ),
                      ],
                    ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? palette.greenDark : palette.textSoft,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _BackgroundBubbles extends StatelessWidget {
  final _SettingsPalette palette;

  const _BackgroundBubbles({required this.palette});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.pinkSoft.withOpacity(0.72),
            ),
          ),
        ),
        Positioned(
          top: 250,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.mintSoft.withOpacity(0.82),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: palette.greenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsPalette {
  final Color bg;
  final Color card;
  final Color cardBorder;
  final Color greenDark;
  final Color greenSoft;
  final Color mintSoft;
  final Color pinkSoft;
  final Color textDark;
  final Color textSoft;
  final Color brand;
  final List<BoxShadow> shadow;

  const _SettingsPalette({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.greenDark,
    required this.greenSoft,
    required this.mintSoft,
    required this.pinkSoft,
    required this.textDark,
    required this.textSoft,
    required this.brand,
    required this.shadow,
  });

  factory _SettingsPalette.of() {
    return const _SettingsPalette(
      bg: Color(0xFFF4F8EA),
      card: Colors.white,
      cardBorder: Color(0x00000000),
      greenDark: Color(0xFF5E9E49),
      greenSoft: Color(0xFFDDEFCF),
      mintSoft: Color(0xFFE9F7E8),
      pinkSoft: Color(0xFFFFEEF2),
      textDark: Color(0xFF1F1F1F),
      textSoft: Color(0xFF6F746E),
      brand: Color(0xFFC65F59),
      shadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
