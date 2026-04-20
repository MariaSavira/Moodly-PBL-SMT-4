import 'package:flutter/material.dart';
import '../../services/afirmasi/afirmasi_service.dart';

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

  final Set<String> favoritAfirmasi = {};

  @override
  void initState() {
    super.initState();
    daftarAfirmasi = AfirmasiService.getAfirmasiByKategori(widget.kategori);
  }

  String get afirmasiAktif {
    if (daftarAfirmasi.isEmpty) {
      return 'Belum ada afirmasi untuk kategori ini.';
    }
    return daftarAfirmasi[currentIndex];
  }

  bool get isFavorite => favoritAfirmasi.contains(afirmasiAktif);

  void nextAfirmasi() {
    if (daftarAfirmasi.isEmpty) return;

    setState(() {
      currentIndex = (currentIndex + 1) % daftarAfirmasi.length;
    });
  }

  void toggleFavorite() {
    setState(() {
      if (favoritAfirmasi.contains(afirmasiAktif)) {
        favoritAfirmasi.remove(afirmasiAktif);
        _showMessage('Afirmasi dihapus dari favorit');
      } else {
        favoritAfirmasi.add(afirmasiAktif);
        _showMessage('Afirmasi disimpan ke favorit');
      }
    });
  }

  void downloadAfirmasi() {
    _showMessage('Fitur unduh belum dihubungkan');
  }

  void shareAfirmasi() {
    _showMessage('Fitur share belum dihubungkan');
  }

  void openWidgetFeature() {
    _showMessage('Pengaturan widget belum dihubungkan');
  }

  void resetKategoriAfirmasi() {
    Navigator.pop(context);
  }

  void openFavoritPage() {
    if (favoritAfirmasi.isEmpty) {
      _showMessage('Belum ada afirmasi favorit');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final favoritList = favoritAfirmasi.toList();

        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Afirmasi Favorit',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.black87,
                    ),
              ),
              const SizedBox(height: 16),
              ...favoritList.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    '• $item',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black87,
                        ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void onMenuSelected(String value) {
    if (value == 'reset_kategori') {
      resetKategoriAfirmasi();
    } else if (value == 'widget_setting') {
      openWidgetFeature();
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final afirmasi = afirmasiAktif;

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
                              style: Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: Colors.black87,
                                  ),
                            ),
                          ),
                        ),
                      ),
                      PopupMenuButton<String>(
                        onSelected: onMenuSelected,
                        color: Colors.white,
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                        itemBuilder: (context) => [
                          PopupMenuItem<String>(
                            value: 'reset_kategori',
                            child: Text(
                              'Atur ulang kategori afirmasi',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          PopupMenuItem<String>(
                            value: 'widget_setting',
                            child: Text(
                              'Pengaturan widget',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 80),

                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: Text(
                          afirmasi,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
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
                      IconButton(
                        onPressed: toggleFavorite,
                        icon: Icon(
                          isFavorite
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: downloadAfirmasi,
                        icon: const Icon(
                          Icons.download_outlined,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                      IconButton(
                        onPressed: shareAfirmasi,
                        icon: const Icon(
                          Icons.ios_share_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      IconButton(
                        onPressed: openFavoritPage,
                        icon: const Icon(
                          Icons.bookmark_border_rounded,
                          color: Colors.white,
                          size: 28,
                        ),
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