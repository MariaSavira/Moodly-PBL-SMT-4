import 'package:flutter/material.dart';
import 'detail_afirmasi_page.dart';

class AfirmasiPage extends StatelessWidget {
  const AfirmasiPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> kategoriAfirmasi = [
      {
        'judul': 'Rasa Syukur',
        'warna': const Color(0xFFB7D99A),
      },
      {
        'judul': 'Meredakan\nKecemasan',
        'warna': const Color(0xFFF3C6CF),
      },
      {
        'judul': 'Motivasi',
        'warna': const Color(0xFFDCEB9B),
      },
      {
        'judul': 'Kesehatan\nMental',
        'warna': const Color(0xFFAEE3F5),
      },
      {
        'judul': 'Cinta Diri',
        'warna': const Color(0xFFF6B6BE),
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF1F4DE),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                              size: 24,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icon/images/heart_mascot.png',
                            width: 52,
                            height: 52,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.favorite,
                                color: Colors.pink,
                                size: 40,
                              );
                            },
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/icon/images/brain_mascot.png',
                            width: 52,
                            height: 52,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.auto_awesome,
                                color: Colors.pinkAccent,
                                size: 40,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),
                      Text(
                        'Tentukan Afirmasi',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge,
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Apa yang paling anda butuhkan\nsaat ini?',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 34),

                      Wrap(
                        spacing: 16,
                        runSpacing: 18,
                        alignment: WrapAlignment.center,
                        children: kategoriAfirmasi.map((item) {
                          return _KategoriButton(
                            title: item['judul'],
                            color: item['warna'],
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailAfirmasiPage(
                                    kategori: item['judul']
                                        .toString()
                                        .replaceAll('\n', ' '),
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 290),
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/icon/images/plant_bottom.png',
                  width: double.infinity,
                  height: 280,
                  fit: BoxFit.fill,
                  alignment: Alignment.topCenter,
                  errorBuilder: (context, error, stackTrace) {
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KategoriButton extends StatelessWidget {
  final String title;
  final Color color;
  final VoidCallback onTap;

  const _KategoriButton({
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          width: 138,
          height: 74,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ),
        ),
      ),
    );
  }
}