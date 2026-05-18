import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 6),
          blurRadius: 18,
          spreadRadius: 0,
        ),
      ];

  static const List<Map<String, String>> _contacts = [
    {
      'title': 'Kontak orang terdekat',
      'subtitle': 'Isi dengan keluarga / sahabat yang paling cepat dihubungi',
      'number': 'ISI-NOMOR-KONTAK-DARURAT',
    },
    {
      'title': 'Hotline profesional',
      'subtitle': 'Ganti dengan hotline kesehatan mental yang sudah divalidasi timmu',
      'number': 'ISI-NOMOR-HOTLINE-VALID',
    },
    {
      'title': 'Layanan darurat umum',
      'subtitle': 'Ganti dengan nomor darurat lokal yang relevan',
      'number': 'ISI-NOMOR-DARURAT-LOKAL',
    },
  ];

  Future<void> _copyNumber(
    BuildContext context,
    String title,
    String number,
  ) async {
    await Clipboard.setData(ClipboardData(text: number));
    if (!context.mounted) return;

    showCuteTopPopup(
      context,
      title: 'Nomor disalin',
      message: '$title siap ditempel ke teleponmu.',
      type: CutePopupType.success,
    );
  }

  Widget _sectionTitle(BuildContext context, String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: _textDark,
          ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
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
            decoration: BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _textDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact['title'] ?? '',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: _textDark,
                      ),
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
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: _textDark,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _copyNumber(
                          context,
                          contact['title'] ?? 'Nomor',
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

  @override
  Widget build(BuildContext context) {
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
                      'Bantuan Darurat',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: _textDark,
                          ),
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
                      decoration: BoxDecoration(
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
                      'Kalau situasimu terasa mendesak, jangan hadapi sendirian.',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: _textDark,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Halaman ini dibuat untuk membantumu bertindak cepat: tenangkan diri, hubungi orang aman, lalu cari bantuan profesional.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _textSoft,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _sectionTitle(context, 'Langkah cepat'),
              const SizedBox(height: 10),
              _stepCard(
                context,
                number: '1',
                title: 'Jeda 10 detik',
                desc: 'Letakkan ponsel, tarik napas perlahan, lalu duduk atau berdiri di tempat yang lebih aman.',
                bg: _greenSoft,
              ),
              const SizedBox(height: 10),
              _stepCard(
                context,
                number: '2',
                title: 'Hubungi orang aman',
                desc: 'Pilih satu orang yang bisa merespons cepat dan beri tahu bahwa kamu butuh bantuan sekarang.',
                bg: _peachSoft,
              ),
              const SizedBox(height: 10),
              _stepCard(
                context,
                number: '3',
                title: 'Cari bantuan profesional',
                desc: 'Gunakan nomor hotline atau layanan darurat yang sudah kamu simpan di bawah.',
                bg: _pinkSoft,
              ),
              const SizedBox(height: 18),
              _sectionTitle(context, 'Kontak darurat'),
              const SizedBox(height: 10),
              _contactCard(
                context,
                contact: _contacts[0],
                tint: _greenSoft,
                icon: Icons.people_alt_rounded,
              ),
              const SizedBox(height: 12),
              _contactCard(
                context,
                contact: _contacts[1],
                tint: _pinkSoft,
                icon: Icons.support_agent_rounded,
              ),
              const SizedBox(height: 12),
              _contactCard(
                context,
                contact: _contacts[2],
                tint: _peachSoft,
                icon: Icons.local_hospital_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}