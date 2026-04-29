import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:moodly/pages/afirmasi/afirmasi_favorit_page.dart';
import 'package:moodly/pages/afirmasi/pengaturan_widget_page.dart';
import 'package:moodly/pages/afirmasi/widgets/cute_top_popup.dart';
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

  static const int freeSlideLimit = 5;
  static const int slidesPerRewardBlock = 5;
  static const int adsNeededPerBlock = 2;

  bool isPremiumUser = false;
  int _rewardedBlocksUnlocked = 0;
  int _watchedAdsCount = 0;

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

  int get _unlockedSlidesCount {
    final unlocked =
        freeSlideLimit + (_rewardedBlocksUnlocked * slidesPerRewardBlock);
    return unlocked > _afirmasiList.length ? _afirmasiList.length : unlocked;
  }

  int get _remainingLockedSlides {
    final remaining = _afirmasiList.length - _unlockedSlidesCount;
    return remaining < 0 ? 0 : remaining;
  }

  bool get _isCurrentFavorite =>
      !_isLockedSlide(_currentIndex) &&
      AfirmasiService.isFavorite(_afirmasiList[_currentIndex]);

  bool _isLockedSlide(int index) {
    if (isPremiumUser) return false;
    if (index < freeSlideLimit) return false;
    return index >= _unlockedSlidesCount;
  }

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

  void _showLockedFeaturePopup() {
    showCuteTopPopup(
      context,
      title: 'Slide terkunci',
      message: 'Tonton 2 iklan untuk membuka 5 slide berikutnya',
      type: CutePopupType.warning,
    );
  }

  void _simulateWatchAd() {
    if (_remainingLockedSlides <= 0) {
      showCuteTopPopup(
        context,
        title: 'Semua terbuka',
        message: 'Semua slide sudah bisa diakses',
        type: CutePopupType.success,
      );
      return;
    }

    setState(() {
      _watchedAdsCount += 1;

      if (_watchedAdsCount >= adsNeededPerBlock) {
        _watchedAdsCount = 0;
        _rewardedBlocksUnlocked += 1;
      }
    });

    if (_watchedAdsCount == 0) {
      showCuteTopPopup(
        context,
        title: 'Slide terbuka',
        message: '5 slide berikutnya berhasil dibuka',
        type: CutePopupType.success,
      );
    } else {
      showCuteTopPopup(
        context,
        title: 'Progress iklan',
        message: '1 dari 2 iklan selesai ditonton',
        type: CutePopupType.info,
      );
    }
  }

  void _toggleFavorite() {
    if (_isLockedSlide(_currentIndex)) {
      _showLockedFeaturePopup();
      return;
    }

    final currentItem = _afirmasiList[_currentIndex];
    final wasFavorite = AfirmasiService.isFavorite(currentItem);

    setState(() {
      AfirmasiService.toggleFavorite(currentItem);
    });

    showCuteTopPopup(
      context,
      title: wasFavorite ? 'Favorit dihapus' : 'Favorit disimpan',
      message: wasFavorite
          ? 'Afirmasi dihapus dari daftar favorit'
          : 'Afirmasi berhasil disimpan ke favorit',
      type: wasFavorite ? CutePopupType.info : CutePopupType.success,
    );
  }

  Future<void> _downloadAfirmasi() async {
    if (_isLockedSlide(_currentIndex)) {
      _showLockedFeaturePopup();
      return;
    }

    final imageBytes = await _captureAfirmasiImage();

    if (imageBytes == null) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Gagal',
        message: 'Gagal mengambil gambar afirmasi',
        type: CutePopupType.error,
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
        showCuteTopPopup(
          context,
          title: 'Izin ditolak',
          message: 'Akses galeri dibutuhkan untuk mengunduh afirmasi',
          type: CutePopupType.warning,
        );
        return;
      }

      await Gal.putImageBytes(
        imageBytes,
        name: 'afirmasi_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Berhasil diunduh',
        message: 'Afirmasi berhasil disimpan ke galeri',
        type: CutePopupType.success,
      );
    } on GalException catch (e) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Gagal mengunduh',
        message: e.type.message,
        type: CutePopupType.error,
      );
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Terjadi kesalahan',
        message: 'Afirmasi gagal diunduh, coba lagi ya',
        type: CutePopupType.error,
      );
    }
  }

  Future<void> _shareAfirmasi() async {
    if (_isLockedSlide(_currentIndex)) {
      _showLockedFeaturePopup();
      return;
    }

    final imageBytes = await _captureAfirmasiImage();

    if (imageBytes == null) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Gagal share',
        message: 'Gagal menyiapkan gambar afirmasi',
        type: CutePopupType.error,
      );
      return;
    }

    final currentItem = _afirmasiList[_currentIndex];
    final shareText =
        '${currentItem['teks'] ?? ''}\n\nKategori: ${currentItem['kategori'] ?? '-'}';

    showCuteTopPopup(
      context,
      title: 'Siap dibagikan',
      message: 'Afirmasi sedang dibuka ke menu share',
      type: CutePopupType.info,
    );

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
      showCuteTopPopup(
        context,
        title: 'Belum ada favorit',
        message: 'Simpan afirmasi favoritmu dulu ya',
        type: CutePopupType.info,
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
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Settings',
      barrierColor: Colors.black.withOpacity(0.12),
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, animation, secondaryAnimation) {
        return SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 70,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 250,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F6F7),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _popupItem(
                          icon: Icons.refresh_rounded,
                          title: 'Atur ulang kategori afirmasi',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                        const SizedBox(height: 8),
                        _popupItem(
                          icon: Icons.widgets_outlined,
                          title: 'Pengaturan widget',
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const PengaturanWidgetPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );

        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.1, -0.1),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _popupItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEFE8F1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 20,
                color: const Color(0xFF5F5565),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF3B343F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    final remainingAds = adsNeededPerBlock - _watchedAdsCount;

    return Container(
      color: Colors.black.withOpacity(0.35),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8B34B),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Tonton 2 iklan untuk membuka 5 slide berikutnya.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      height: 1.4,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Progress: $_watchedAdsCount / $adsNeededPerBlock iklan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: 170,
                height: 36,
                child: ElevatedButton(
                  onPressed: _simulateWatchAd,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDEDED),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    remainingAds == 2 ? 'tonton iklan' : 'tonton iklan lagi',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 170,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {
                    showCuteTopPopup(
                      context,
                      title: 'Premium',
                      message: 'Halaman premium akan ditambahkan',
                      type: CutePopupType.warning,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEDEDED),
                    foregroundColor: Colors.black87,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Dapatkan Premium'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    final totalVisible = _afirmasiList.length > freeSlideLimit
        ? freeSlideLimit
        : _afirmasiList.length;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalVisible,
        (index) {
          final activeIndex =
              _currentIndex >= totalVisible ? totalVisible - 1 : _currentIndex;

          final bool isActive = index == activeIndex;

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
      body: Stack(
        children: [
          Positioned.fill(
            child: Screenshot(
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
                  PageView.builder(
                    controller: _pageController,
                    itemCount: _afirmasiList.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final item = _afirmasiList[index];
                      final isLocked = _isLockedSlide(index);

                      return Stack(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32),
                            child: Center(
                              child: Opacity(
                                opacity: isLocked ? 0.35 : 1,
                                child: Text(
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
                              ),
                            ),
                          ),
                          if (isLocked) _buildLockedOverlay(),
                        ],
                      );
                    },
                  ),
                ],
              ),
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
                const Spacer(),
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
    );
  }
}