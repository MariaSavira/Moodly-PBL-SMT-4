import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
      'label': 'Meredakan\nkecemasan',
      'kategori': 'Meredakan Kecemasan',
      'warna': const Color(0xFFFFE0E2),
    },
    {
      'label': 'Motivasi',
      'kategori': 'Motivasi',
      'warna': const Color(0xFFD9ED84),
    },
    {
      'label': 'Kesehatan\nMental',
      'kategori': 'Kesehatan Mental',
      'warna': const Color(0xFF9DDBF7),
    },
    {
      'label': 'Cinta Diri',
      'kategori': 'Cinta Diri',
      'warna': const Color(0xFFF5B2BC),
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
                            width: 54,
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'assets/icon/images/brain_mascot.png',
                            width: 54,
                            height: 54,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 234,
                        child: Text(
                          'Tentukan Afirmasi',
                          textAlign: TextAlign.center,
                         style: GoogleFonts.fredoka(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          height: 22 / 24,
                          color: Colors.black,
                        ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: 234,
                        child: Text(
                          'Apa yang paling anda butuhkan\nsaat ini?',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.fredoka(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 22 / 14,
                          color: Colors.black,
                        ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Wrap(
                        spacing: 52,
                        runSpacing: 56,
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
                      const SizedBox(height: 56),
                      Center(
                        child: InnerShadow(
                          shadows: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                              offset: Offset(0, 1),
                              blurRadius: 5,
                            ),
                          ],
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: goToDetailPage,
                              child: Ink(
                                width: 257,
                                height: 30,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF99D28F),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Center(
                                  child: Text(
                                    'Lanjutkan',
                                    style: GoogleFonts.openSans(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      height: 22 / 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
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

  Color _textColor(String title) {
    if (title == 'Rasa Syukur') {
      return const Color(0xFF295C2C);
    }
    if (title == 'Meredakan\nkecemasan') {
      return const Color(0xFFC97C86);
    }
    if (title == 'Motivasi') {
      return const Color(0xFF666624);
    }
    if (title == 'Kesehatan\nMental') {
      return const Color(0xFF0D9EB8);
    }
    if (title == 'Cinta Diri') {
      return const Color(0xFF631B1C);
    }
    return const Color(0xFF2F2F2F);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Ink(
          width: 123,
          height: 51,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF6E9550) : Colors.transparent,
              width: 3,
            ),
          ),
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.openSans(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                height: 22 / 14,
                color: _textColor(title),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class InnerShadow extends StatelessWidget {
  final Widget child;
  final List<BoxShadow> shadows;

  const InnerShadow({
    super.key,
    required this.child,
    this.shadows = const [],
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _InnerShadowPainter(shadows),
      child: child,
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final List<BoxShadow> shadows;

  _InnerShadowPainter(this.shadows);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    for (final shadow in shadows) {
      final paint = Paint()
        ..color = shadow.color
        ..blendMode = BlendMode.srcATop
        ..maskFilter = MaskFilter.blur(
          BlurStyle.normal,
          shadow.blurRadius,
        );

      final outerRect = Rect.fromLTWH(
        rect.left - 20,
        rect.top - 20,
        rect.width + 40,
        rect.height + 40,
      );

      final outerRRect = RRect.fromRectAndRadius(
        outerRect,
        const Radius.circular(16),
      );

      final innerRRect = RRect.fromRectAndRadius(
        rect.shift(shadow.offset),
        const Radius.circular(16),
      );

      final path = Path()
        ..fillType = PathFillType.evenOdd
        ..addRRect(outerRRect)
        ..addRRect(innerRRect);

      canvas.save();
      canvas.clipRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(16)),
      );
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}