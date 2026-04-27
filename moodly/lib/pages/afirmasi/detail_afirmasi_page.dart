import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:moodly/pages/afirmasi/afirmasi_favorit_page.dart';
import 'package:moodly/pages/afirmasi/pengaturan_widget_page.dart';
import 'package:moodly/services/afirmasi/afirmasi_service.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class DetailAfirmasiPage extends StatefulWidget {
  final List<String> selectedCategories;

  const DetailAfirmasiPage({
    super.key,
    required this.selectedCategories,
  });

  @override
  State<DetailAfirmasiPage> createState() => _DetailAfirmasiPageState();
}

class _DetailAfirmasiPageState extends State<DetailAfirmasiPage> {
  final PageController _pageController = PageController();
  final ScreenshotController _screenshotController = ScreenshotController();

  final List<String> _backgroundImages = [
    'assets/icon/images/bg_afirmasi_1.jpg',
    'assets/icon/images/bg_afirmasi_2.jpg',
    'assets/icon/images/bg_afirmasi_3.jpg',
    'assets/icon/images/bg_afirmasi_4.jpg',
    'assets/icon/images/bg_afirmasi_5.jpg',
  ];

  List<Map<String, String>> _afirmasiList = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadAfirmasi();
  }

  void _loadAfirmasi() {
    final data =
        AfirmasiService.getAfirmasiByCategories(widget.selectedCategories);

    data.shuffle(Random());

    setState(() {
      _afirmasiList = data.isNotEmpty
          ? List<Map<String, String>>.from(data)
          : [
              {
                'kategori': 'Afirmasi',
                'teks': 'Belum ada afirmasi yang tersedia.',
              }
            ];
    });
  }

  String get _currentBackground {
    if (_backgroundImages.isEmpty) {
      return 'assets/icon/images/bg_afirmasi.jpg';
    }
    return _backgroundImages[_currentIndex % _backgroundImages.length];
  }

  bool get _isCurrentFavorite =>
      AfirmasiService.isFavorite(_afirmasiList[_currentIndex]);

  Future<Uint8List?> _captureAfirmasiImage() async {
    try {
      return await _screenshotController.capture(
        delay: const Duration(milliseconds: 100),
        pixelRatio: 2.5,
      );
    } catch (_) {
      return null;
    }
  }

  void _toggleFavorite() {
    final currentItem = _afirmasiList[_currentIndex];
    final wasFavorite = AfirmasiService.isFavorite(currentItem);

    setState(() {
      AfirmasiService.toggleFavorite(currentItem);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasFavorite
              ? 'Afirmasi dihapus dari favorit'
              : 'Afirmasi disimpan ke favorit',
        ),
      ),
    );
  }

  Future<void> _downloadAfirmasi() async {
    final imageBytes = await _captureAfirmasiImage();

    if (imageBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengambil gambar afirmasi'),
        ),
      );
      return;
    }

    try {
      final hasAccess = await Gal.hasAccess();
      if (!hasAccess) {
        await Gal.requestAccess();
      }

      final hasAccessAfterRequest = await Gal.hasAccess();
      if (!hasAccessAfterRequest) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin akses galeri ditolak'),
          ),
        );
        return;
      }

      await Gal.putImageBytes(
        imageBytes,
        name: 'afirmasi_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Afirmasi berhasil diunduh'),
        ),
      );
    } on GalException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengunduh: ${e.type.message}'),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan saat mengunduh'),
        ),
      );
    }
  }

  Future<void> _shareAfirmasi() async {
    final imageBytes = await _captureAfirmasiImage();

    if (imageBytes == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menyiapkan gambar afirmasi'),
        ),
      );
      return;
    }

    final currentItem = _afirmasiList[_currentIndex];
    final shareText =
        '${currentItem['teks'] ?? ''}\n\nKategori: ${currentItem['kategori'] ?? '-'}';

    await Share.shareXFiles(
      [
        XFile.fromData(
          imageBytes,
          mimeType: 'image/png',
          name: 'afirmasi.png',
        ),
      ],
      text: shareText,
    );
  }

  Future<void> _showFavoriteList() async {
    final favoritItems = AfirmasiService.getFavoritItems();

    if (favoritItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Belum ada afirmasi favorit'),
        ),
      );
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AfirmasiFavoritPage(),
      ),
    );

    setState(() {});
  }

  void _showSettingsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF8F6F2),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.refresh),
                  title: const Text('Atur ulang kategori afirmasi'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: const Text('Pengaturan widget'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      this.context,
                      MaterialPageRoute(
                        builder: (_) => const PengaturanWidgetPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDots() {
    final int dotCount = _afirmasiList.length > 3 ? 3 : _afirmasiList.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        dotCount,
        (index) {
          final bool isActive = index == (_currentIndex % dotCount);
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFFA6D68A) : Colors.white70,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBottomButton({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 38,
        color: active ? const Color(0xFFFFC0CB) : Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _afirmasiList[_currentIndex];
    final currentCategory = currentItem['kategori'] ?? 'Afirmasi';

    return Scaffold(
      body: Screenshot(
        controller: _screenshotController,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                _currentBackground,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: const Color(0xFF8C6A8E),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.10),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: IntrinsicWidth(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                constraints: const BoxConstraints(
                                  minHeight: 32,
                                ),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: const Color(0x80FFFFFF),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Text(
                                  currentCategory,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.black87,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _showSettingsMenu,
                          icon: const Icon(
                            Icons.settings_outlined,
                            color: Colors.white,
                            size: 38,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _afirmasiList.length,
                      onPageChanged: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        final item = _afirmasiList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                item['teks'] ?? '',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: _buildDots(),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 32, 28),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildBottomButton(
                          icon: _isCurrentFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          onTap: _toggleFavorite,
                          active: _isCurrentFavorite,
                        ),
                        _buildBottomButton(
                          icon: Icons.system_update_alt_rounded,
                          onTap: _downloadAfirmasi,
                        ),
                        _buildBottomButton(
                          icon: Icons.ios_share_outlined,
                          onTap: _shareAfirmasi,
                        ),
                        _buildBottomButton(
                          icon: Icons.bookmark_border,
                          onTap: _showFavoriteList,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}