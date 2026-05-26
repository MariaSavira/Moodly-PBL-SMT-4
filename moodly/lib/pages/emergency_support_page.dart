import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'setting/moodly_settings_support.dart';
import 'afirmasi/widgets/cute_top_popup.dart';

class EmergencySupportPage extends StatelessWidget {
  const EmergencySupportPage({super.key});

  static const Color _bg = Color(0xFFF1F5E4);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF82C46B);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _peachSoft = Color(0xFFFFE9DE);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF677164);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Bantuan Darurat',
      'copyTitle': 'Nomor disalin',
      'copyFallback': 'Nomor',
      'copyMessageSuffix': 'siap ditempel ke teleponmu.',
      'sectionContacts': 'Kontak darurat',
      'sectionSteps': 'Langkah cepat',
      'contact1Title': 'Kontak orang terdekat',
      'contact1Subtitle':
          'Isi dengan keluarga / sahabat yang paling cepat dihubungi',
      'contact2Title': 'Hotline profesional',
      'contact2Subtitle':
          'Ganti dengan hotline kesehatan mental yang sudah divalidasi timmu',
      'contact3Title': 'Layanan darurat umum',
      'contact3Subtitle': 'Ganti dengan nomor darurat lokal yang relevan',
    },
    'en': {
      'header': 'Emergency Support',
      'copyTitle': 'Number copied',
      'copyFallback': 'Number',
      'copyMessageSuffix': 'is ready to paste into your phone.',
      'sectionContacts': 'Emergency contacts',
      'sectionSteps': 'Quick steps',
      'contact1Title': 'Trusted person contact',
      'contact1Subtitle':
          'Fill this with the family member / friend you can reach fastest',
      'contact2Title': 'Professional hotline',
      'contact2Subtitle':
          'Replace this with a mental health hotline already validated by your team',
      'contact3Title': 'General emergency service',
      'contact3Subtitle': 'Replace this with a relevant local emergency number',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  List<BoxShadow> get _softShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];

  List<Map<String, String>> _contacts(String languageCode) => [
    {
      'title': _t(languageCode, 'contact1Title'),
      'subtitle': _t(languageCode, 'contact1Subtitle'),
      'number': 'ISI-NOMOR-KONTAK-DARURAT',
    },
    {
      'title': _t(languageCode, 'contact2Title'),
      'subtitle': _t(languageCode, 'contact2Subtitle'),
      'number': 'ISI-NOMOR-HOTLINE-VALID',
    },
    {
      'title': _t(languageCode, 'contact3Title'),
      'subtitle': _t(languageCode, 'contact3Subtitle'),
      'number': 'ISI-NOMOR-DARURAT-LOKAL',
    },
  ];

  Future<void> _copyNumber(
    BuildContext context,
    String languageCode,
    String title,
    String number,
  ) async {
    await Clipboard.setData(ClipboardData(text: number));
    if (!context.mounted) return;

    showCuteTopPopup(
      context,
      title: _t(languageCode, 'copyTitle'),
      message: '$title ${_t(languageCode, 'copyMessageSuffix')}',
      type: CutePopupType.success,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(color: _textDark),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required String languageCode,
    required Map<String, String> contact,
    required Color tint,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(icon, color: _textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['title'] ?? '',
                  style: Theme.of(
                    context,
                  ).textTheme.titleMedium?.copyWith(color: _textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  contact['subtitle'] ?? '',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _textSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: tint,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          contact['number'] ?? '',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: _textDark,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyNumber(
                          context,
                          languageCode,
                          contact['title'] ?? _t(languageCode, 'copyFallback'),
                          contact['number'] ?? '',
                        ),
                        child: const Icon(
                          Icons.copy_rounded,
                          color: _textDark,
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stepCard(
    BuildContext context, {
    required String number,
    required String title,
    required String desc,
    required Color bg,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Text(
              number,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: _textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: _textSoft,
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

  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: MoodlySettingsPrefs.languageNotifier,
      builder: (context, languageCode, _) {
        final contacts = _contacts(languageCode);

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.88),
                            shape: BoxShape.circle,
                            boxShadow: _softShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _t(languageCode, 'header'),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(color: _textDark),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: _softShadow,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 58,
                          height: 58,
                          decoration: const BoxDecoration(
                            color: _pinkSoft,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Color(0xFFE26D7D),
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          languageCode == 'en'
                              ? 'If your situation feels urgent, do not face it alone.'
                              : 'Kalau situasimu terasa mendesak, jangan hadapi sendirian.',
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(color: _textDark),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          languageCode == 'en'
                              ? 'This page is here to help you act quickly: calm down, contact a safe person, then seek professional support.'
                              : 'Halaman ini dibuat untuk membantumu bertindak cepat: tenangkan diri, hubungi orang aman, lalu cari bantuan profesional.',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: _textSoft, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle(context, _t(languageCode, 'sectionSteps')),
                  const SizedBox(height: 10),
                  _stepCard(
                    context,
                    number: '1',
                    title: languageCode == 'en'
                        ? 'Pause and breathe slowly'
                        : 'Berhenti dan atur napas',
                    desc: languageCode == 'en'
                        ? 'Give yourself a few seconds to reduce the rush before deciding what to do next.'
                        : 'Beri dirimu jeda beberapa detik untuk menurunkan panik sebelum menentukan langkah berikutnya.',
                    bg: _greenSoft,
                  ),
                  const SizedBox(height: 10),
                  _stepCard(
                    context,
                    number: '2',
                    title: languageCode == 'en'
                        ? 'Contact someone safe'
                        : 'Hubungi orang yang aman',
                    desc: languageCode == 'en'
                        ? 'Reach out to family, a close friend, or someone who can stay with you.'
                        : 'Hubungi keluarga, sahabat, atau orang yang bisa menemanimu sekarang.',
                    bg: _pinkSoft,
                  ),
                  const SizedBox(height: 10),
                  _stepCard(
                    context,
                    number: '3',
                    title: languageCode == 'en'
                        ? 'Use professional help if needed'
                        : 'Gunakan bantuan profesional bila perlu',
                    desc: languageCode == 'en'
                        ? 'If the condition feels severe, use a hotline or emergency service immediately.'
                        : 'Kalau kondisi terasa berat, gunakan hotline atau layanan darurat secepatnya.',
                    bg: _peachSoft,
                  ),
                  const SizedBox(height: 18),
                  _sectionTitle(context, _t(languageCode, 'sectionContacts')),
                  const SizedBox(height: 10),
                  _contactCard(
                    context,
                    languageCode: languageCode,
                    contact: contacts[0],
                    tint: _greenSoft,
                    icon: Icons.people_alt_rounded,
                  ),
                  const SizedBox(height: 12),
                  _contactCard(
                    context,
                    languageCode: languageCode,
                    contact: contacts[1],
                    tint: _pinkSoft,
                    icon: Icons.support_agent_rounded,
                  ),
                  const SizedBox(height: 12),
                  _contactCard(
                    context,
                    languageCode: languageCode,
                    contact: contacts[2],
                    tint: _peachSoft,
                    icon: Icons.local_hospital_rounded,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
