import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';

class TermsConditionsPage extends StatelessWidget {
  const TermsConditionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 24.0 : 32.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Syarat & Ketentuan',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 28),

                  Text(
                    'Ketentuan penggunaan aplikasi Moodly',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: isSmall ? 20 : 22,
                      height: 1.3,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    'Dengan menggunakan Moodly, pengguna dianggap memahami dan menyetujui aturan penggunaan aplikasi.',
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: isSmall ? 13 : 14,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 28),

                  const _TermsCard(
                    number: '1',
                    title: 'Penggunaan Aplikasi',
                    content:
                        'Moodly digunakan untuk membantu pengguna mencatat mood harian, menulis diary, melihat perkembangan mood, membaca afirmasi, dan menggunakan fitur pendukung kesehatan mental secara mandiri.',
                  ),
                  const _TermsCard(
                    number: '2',
                    title: 'Akun Pengguna',
                    content:
                        'Pengguna bertanggung jawab menjaga keamanan akun, email, dan kata sandi. Jangan membagikan akses akun kepada orang lain.',
                  ),
                  const _TermsCard(
                    number: '3',
                    title: 'Diary dan Data Mood',
                    content:
                        'Catatan mood dan diary bersifat pribadi. Pengguna diharapkan menulis data dengan bijak dan tidak menyalahgunakan fitur yang tersedia.',
                  ),
                  const _TermsCard(
                    number: '4',
                    title: 'Curhat Anonim',
                    content:
                        'Pengguna tidak diperbolehkan mengirim konten yang mengandung hinaan, ancaman, pelecehan, ujaran kebencian, atau hal lain yang dapat merugikan pengguna lain.',
                  ),
                  const _TermsCard(
                    number: '5',
                    title: 'Pelaporan Konten',
                    content:
                        'Moodly menyediakan fitur pelaporan untuk konten anonim yang tidak pantas. Laporan dapat ditinjau oleh admin untuk menjaga keamanan komunitas.',
                  ),
                  const _TermsCard(
                    number: '6',
                    title: 'Privasi Pengguna',
                    content:
                        'Data pribadi pengguna dilindungi dan tidak dibagikan tanpa izin. Moodly berupaya menjaga keamanan data sesuai kebutuhan privasi aplikasi.',
                  ),
                  const _TermsCard(
                    number: '7',
                    title: 'Bantuan Darurat',
                    content:
                        'Fitur bantuan darurat dan hotline hanya berfungsi sebagai arahan awal. Jika pengguna mengalami kondisi emosional berat, segera hubungi bantuan profesional atau pihak terpercaya.',
                  ),
                  const _TermsCard(
                    number: '8',
                    title: 'Perubahan Ketentuan',
                    content:
                        'Syarat dan ketentuan dapat diperbarui sesuai perkembangan aplikasi. Pengguna disarankan membaca halaman ini secara berkala.',
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Terakhir diperbarui: Mei 2026',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
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
    final isSmall = MediaQuery.of(context).size.width < 380;

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
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: MoodlyColors.green,
              fontSize: isSmall ? 15 : 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Text(
          'Moodly',
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

class _TermsCard extends StatelessWidget {
  final String number;
  final String title;
  final String content;

  const _TermsCard({
    required this.number,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: isSmall ? 32 : 34,
            height: isSmall ? 32 : 34,
            decoration: const BoxDecoration(
              color: MoodlyColors.green,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isSmall ? 15 : 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: isSmall ? 12 : 13,
                    height: 1.45,
                    fontWeight: FontWeight.w400,
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