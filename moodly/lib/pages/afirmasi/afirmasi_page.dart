import 'package:flutter/material.dart';
import 'detail_afirmasi_page.dart';

class AfirmasiPage extends StatefulWidget {
  const AfirmasiPage({super.key});

  @override
  State<AfirmasiPage> createState() => _AfirmasiPageState();
}

class _AfirmasiPageState extends State<AfirmasiPage> {
  final List<Map<String, dynamic>> kategoriAfirmasi = [
    {
      'label': 'Rasa Syukur',
      'kategori': 'Rasa Syukur',
      'warna': const Color(0xFFB7D99A),
    },
    {
      'label': 'Meredakan\nKecemasan',
      'kategori': 'Meredakan Kecemasan',
      'warna': const Color(0xFFF3C6CF),
    },
    {
      'label': 'Motivasi',
      'kategori': 'Motivasi',
      'warna': const Color(0xFFDCEB9B),
    },
    {
      'label': 'Kesehatan\nMental',
      'kategori': 'Kesehatan Mental',
      'warna': const Color(0xFFAEE3F5),
    },
    {
      'label': 'Cinta Diri',
      'kategori': 'Cinta Diri',
      'warna': const Color(0xFFF6B6BE),
    },
  ];

  final List<String> selectedCategories = [];

  void toggleCategory(String kategori) {
    setState(() {
      if (selectedCategories.contains(kategori)) {
        selectedCategories.remove(kategori);
      } else {
        if (selectedCategories.length >= 3) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maksimal pilih 3 kategori afirmasi'),
            ),
          );
          return;
        }
        selectedCategories.add(kategori);
      }
    });
  }

  void goToDetailPage() {
    if (selectedCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih minimal 1 kategori afirmasi'),
        ),
      );
      return;
    }

    Navigator.push(
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
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/icon/images/heart_mascot.png',
                            width: 52,
                            height: 52,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 12),
                          Image.asset(
                            'assets/icon/images/brain_mascot.png',
                            width: 54,
                            height: 54,
                            fit: BoxFit.contain,
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
                        spacing: 18,
                        runSpacing: 18,
                        alignment: WrapAlignment.center,
                        children: kategoriAfirmasi.map((item) {
                          final String label = item['label'] as String;
                          final String kategori = item['kategori'] as String;
                          final Color warna = item['warna'] as Color;
                          final bool isSelected =
                              selectedCategories.contains(kategori);

                          return _KategoriBubble(
                            title: label,
                            color: warna,
                            isSelected: isSelected,
                            onTap: () => toggleCategory(kategori),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: 255,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: goToDetailPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF92C47E),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                          ),
                          child: Text(
                            'Lanjutkan',
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(color: Colors.white),
                          ),
                        ),
                      ),

                      const SizedBox(height: 260),
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
                  height: 235,
                  fit: BoxFit.fill,
                  alignment: Alignment.bottomCenter,
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

class _KategoriBubble extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _KategoriBubble({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Ink(
          width: 145,
          height: 86,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? const Color(0xFF6E9550) : Colors.transparent,
              width: 4,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF2F2F2F),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}