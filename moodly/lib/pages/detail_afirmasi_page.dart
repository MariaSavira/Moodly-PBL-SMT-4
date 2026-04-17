import 'package:flutter/material.dart';
import '../services/afirmasi_service.dart';

class DetailAfirmasiPage extends StatefulWidget {
  final String kategori;

  const DetailAfirmasiPage({
    super.key,
    required this.kategori,
  });

  @override
  State<DetailAfirmasiPage> createState() => _DetailAfirmasiPageState();
}

class _DetailAfirmasiPageState extends State<DetailAfirmasiPage> {
  late final List<String> daftarAfirmasi;
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    daftarAfirmasi = AfirmasiService.getAfirmasiByKategori(widget.kategori);
  }

  void nextAfirmasi() {
    if (daftarAfirmasi.isEmpty) return;

    setState(() {
      currentIndex = (currentIndex + 1) % daftarAfirmasi.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final afirmasi = daftarAfirmasi.isNotEmpty
        ? daftarAfirmasi[currentIndex]
        : 'Belum ada afirmasi untuk kategori ini.';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/icon/images/bg_afirmasi.png',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: const Color(0xFF8C6A8E),
              );
            },
          ),

          Container(
            color: Colors.black.withOpacity(0.28),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.kategori,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 26),

                  const Text(
                    'afirmasi muncul sesuai kategori yang dipilih',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 80),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          afirmasi,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 20,
                            height: 1.35,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      daftarAfirmasi.isEmpty ? 1 : daftarAfirmasi.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? const Color(0xFFA8D39B)
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 26),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      const Icon(
                        Icons.favorite_border_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                      IconButton(
                        onPressed: nextAfirmasi,
                        icon: const Icon(
                          Icons.keyboard_double_arrow_down_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const Icon(
                        Icons.ios_share_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                      const Icon(
                        Icons.grid_view_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}