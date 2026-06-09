import 'package:flutter/material.dart';

import '../../widgets/moodly_bottom_navbar.dart';
import '../pages.dart';
import '../private_diary/month_page.dart';
import '../setting/moodly_settings_support.dart';
import 'public_diary_page.dart';

class SelectedDiaryPage extends StatefulWidget {
  const SelectedDiaryPage({super.key});

  @override
  State<SelectedDiaryPage> createState() => _SelectedDiaryPageState();
}

class _SelectedDiaryPageState extends State<SelectedDiaryPage> {
  static const Color _bg = Color(0xFFF4F8EA);
  static const Color _card = Colors.white;
  static const Color _greenDark = Color(0xFF5F9E4E);
  static const Color _greenMint = Color(0xFFEFF7E6);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _peach = Color(0xFFFFE9DE);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF6D7568);

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  int _currentNavIndex = 1;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'pageTitle': 'Diary Entries',
      'heroTitle': 'Pilih ruang ceritamu',
      'heroDesc':
          'Simpan sendiri saat ingin tenang, atau bagikan saat ingin didengar.',
      'privateTitle': 'Diary Privat',
      'privateDesc': 'Untuk catatan yang lebih personal.',
      'publicTitle': 'Diary Publik',
      'publicDesc': 'Untuk cerita yang ingin kamu bagikan.',
      'openPrivate': 'Masuk diary privat',
      'openPublic': 'Masuk diary publik',
    },
    'en': {
      'pageTitle': 'Diary Entries',
      'heroTitle': 'Choose your story space',
      'heroDesc':
          'Keep it to yourself when you need calm, or share it when you want to be heard.',
      'privateTitle': 'Private Diary',
      'privateDesc': 'For more personal notes.',
      'publicTitle': 'Public Diary',
      'publicDesc': 'For stories you want to share.',
      'openPrivate': 'Open private diary',
      'openPublic': 'Open public diary',
    },
  };

  String _t(String key) => _copy[_languageCode]?[key] ?? key;
  TextTheme get _text => Theme.of(context).textTheme;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          blurRadius: 18,
          offset: Offset(0, 8),
        ),
      ];

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  Future<void> _handleNavTap(int index) async {
    if (index == 1) return;

    Widget? target;
    switch (index) {
      case 0:
        target = const Homepage();
        break;
      case 3:
        target = const HomeChatAnonim();
        break;
      case 4:
        target = const AfirmasiPage();
        break;
    }

    if (target == null || !mounted) return;

    await Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => target!),
    );
  }

  void _onEmergencyTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EmergencySupportPage()),
    );
  }

  Widget _buildOptionCard({
    required Color accentBg,
    required IconData icon,
    required String title,
    required String desc,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _card,
          borderRadius: BorderRadius.circular(28),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: accentBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                icon,
                color: _greenDark,
                size: 38,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    desc,
                    style: _text.bodyMedium?.copyWith(
                      color: _textSoft,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: accentBg,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      buttonText,
                      style: _text.bodySmall?.copyWith(
                        color: _greenDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: _greenDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      bottomNavigationBar: MoodlyBottomNavbar(
        currentIndex: _currentNavIndex,
        onTap: _handleNavTap,
        onEmergencyTap: _onEmergencyTap,
      ),
      body: Stack(
        children: [
          Positioned(
            top: -40,
            right: -24,
            child: Container(
              width: 170,
              height: 170,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _pinkSoft.withOpacity(0.72),
              ),
            ),
          ),
          Positioned(
            bottom: 150,
            left: -70,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _greenMint.withOpacity(0.82),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('pageTitle'),
                    style: _text.headlineLarge?.copyWith(
                      color: _textDark,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _softShadow,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _t('heroTitle'),
                                style: _text.headlineLarge?.copyWith(
                                  color: _textDark,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _t('heroDesc'),
                                style: _text.bodyMedium?.copyWith(
                                  color: _textSoft,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 14),
                        Container(
                          width: 82,
                          height: 82,
                          decoration: const BoxDecoration(
                            color: _greenMint,
                            shape: BoxShape.circle,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Image.asset(
                              'assets/icon/images/maskot_favorit.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOptionCard(
                    accentBg: _peach,
                    icon: Icons.lock_rounded,
                    title: _t('privateTitle'),
                    desc: _t('privateDesc'),
                    buttonText: _t('openPrivate'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const MonthPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildOptionCard(
                    accentBg: _greenMint,
                    icon: Icons.public_rounded,
                    title: _t('publicTitle'),
                    desc: _t('publicDesc'),
                    buttonText: _t('openPublic'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PublicDiaryPage()),
                      );
                    },
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