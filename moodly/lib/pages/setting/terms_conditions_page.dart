import 'package:flutter/material.dart';

import 'moodly_settings_support.dart';

class TermsConditionsPage extends StatefulWidget {
  const TermsConditionsPage({super.key});

  @override
  State<TermsConditionsPage> createState() => _TermsConditionsPageState();
}

class _TermsConditionsPageState extends State<TermsConditionsPage> {
  bool _isLoadingPrefs = true;
  String _languageCode = 'id';

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Syarat & Ketentuan',
      'title': 'Ketentuan penggunaan Moodly',
      'description':
          'Dokumen ini dibuat supaya aturan dasar aplikasi jelas. Bukan supaya halaman terlihat resmi lalu semua orang pura-pura membacanya.',
      'updated': 'Terakhir diperbarui: Mei 2026',
      '1t': 'Penggunaan Aplikasi',
      '1b': 'Moodly membantu pengguna mencatat mood, menulis diary, membaca afirmasi, dan memakai fitur pendukung refleksi diri secara mandiri.',
      '2t': 'Akun Pengguna',
      '2b': 'Pengguna bertanggung jawab menjaga keamanan akun, email, dan kata sandi. Jangan bagikan akses akun ke orang lain.',
      '3t': 'Diary dan Data Mood',
      '3b': 'Data mood dan diary diperlakukan sebagai data pribadi. Gunakan fitur dengan bijak dan jangan menyalahgunakannya.',
      '4t': 'Curhat Anonim',
      '4b': 'Pengguna dilarang mengirim hinaan, ancaman, pelecehan, ujaran kebencian, atau konten lain yang merugikan pengguna lain.',
      '5t': 'Pelaporan Konten',
      '5b': 'Moodly menyediakan fitur pelaporan untuk konten yang tidak pantas. Laporan dapat ditinjau admin untuk menjaga keamanan komunitas.',
      '6t': 'Privasi Pengguna',
      '6b': 'Data pribadi pengguna dijaga dan tidak dibagikan tanpa izin, kecuali bila dibutuhkan untuk operasional aplikasi sesuai kebijakan yang berlaku.',
      '7t': 'Bantuan Darurat',
      '7b': 'Fitur bantuan darurat hanya menjadi arahan awal. Jika kondisi emosional terasa berat, segera hubungi bantuan profesional atau orang terpercaya.',
      '8t': 'Perubahan Ketentuan',
      '8b': 'Ketentuan ini dapat diperbarui mengikuti perkembangan aplikasi. Pengguna disarankan memeriksa halaman ini secara berkala.',
    },
    'en': {
      'header': 'Terms & Conditions',
      'title': 'Moodly usage terms',
      'description':
          'This page exists to make the app rules clear, not to look official while everyone pretends they read it.',
      'updated': 'Last updated: May 2026',
      '1t': 'App Usage',
      '1b': 'Moodly helps users log moods, write diaries, read affirmations, and use self-reflection support features independently.',
      '2t': 'User Accounts',
      '2b': 'Users are responsible for protecting their account, email, and password. Do not share account access with others.',
      '3t': 'Diary and Mood Data',
      '3b': 'Mood logs and diary entries are treated as personal data. Use the features responsibly and do not misuse them.',
      '4t': 'Anonymous Sharing',
      '4b': 'Users must not send insults, threats, harassment, hate speech, or any content that harms other users.',
      '5t': 'Content Reporting',
      '5b': 'Moodly provides a reporting feature for inappropriate content. Reports may be reviewed by admins to keep the community safer.',
      '6t': 'User Privacy',
      '6b': 'Personal data is protected and will not be shared without permission, except when needed for app operations under the applicable policy.',
      '7t': 'Emergency Help',
      '7b': 'Emergency help features are only an initial guide. If emotional distress becomes serious, contact professional help or a trusted person immediately.',
      '8t': 'Changes to Terms',
      '8b': 'These terms may be updated as the app evolves. Users are encouraged to review this page regularly.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: palette.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: MediaQuery.of(context).size.width > 430 ? 430 : MediaQuery.of(context).size.width,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodlySettingsHeader(
                        palette: palette,
                        title: _t('header'),
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 22),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('title'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: palette.textDark,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('description'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textSoft,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      for (int i = 1; i <= 8; i++) ...[
                        _TermsCard(
                          number: i.toString(),
                          title: _t('${i}t'),
                          content: _t('${i}b'),
                          palette: palette,
                        ),
                        const SizedBox(height: 12),
                      ],
                      const SizedBox(height: 6),
                      Text(
                        _t('updated'),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: palette.textSoft,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TermsCard extends StatelessWidget {
  final String number;
  final String title;
  final String content;
  final MoodlySettingsPalette palette;

  const _TermsCard({
    required this.number,
    required this.title,
    required this.content,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return MoodlySettingsCard(
      palette: palette,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: palette.pinkSoft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                number,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: palette.greenDark,
                    ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: palette.textDark,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: palette.textSoft,
                        height: 1.45,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
