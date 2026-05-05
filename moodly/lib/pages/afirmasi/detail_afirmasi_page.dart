import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
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
  bool _isLoading = true;

  int _rewardedBlocksUnlocked = 0;
  int _watchedAdsCount = 0;
  int _currentIndex = 0;

  RewardedAd? _rewardedAd;
  bool _isRewardedAdReady = false;

  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';

  final List<String> _backgroundImages = [
    'assets/icon/images/bg_afirmasi_1.jpg',
    'assets/icon/images/bg_afirmasi_2.jpg',
    'assets/icon/images/bg_afirmasi_3.jpg',
    'assets/icon/images/bg_afirmasi_4.jpg',
    'assets/icon/images/bg_afirmasi_5.jpg',
  ];

  List<Map<String, String>> _afirmasiList = [];

  @override
  void initState() {
    super.initState();
    _initializePage();
    _loadRewardedAd();
  }

  Future<void> _initializePage() async {
    await AfirmasiService.loadFavoritesFromLocal();
    await _loadAfirmasi();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  Future<void> _loadAfirmasi() async {
    setState(() {
      _isLoading = true;
    });

    final data = await AfirmasiService.getAfirmasiByCategories(
      widget.selectedCategories,
    );

    data.shuffle(Random());

    if (!mounted) return;

    setState(() {
      _afirmasiList = data.isNotEmpty
          ? List<Map<String, String>>.from(data)
          : [
              {
                'id': '',
                'kategori': 'Afirmasi',
                'teks': 'Belum ada afirmasi yang tersedia.',
              }
            ];
      _currentIndex = 0;
      _isLoading = false;
    });

    await _sendCurrentAfirmasiToWidget();
  }

  Future<void> _sendCurrentAfirmasiToWidget() async {
    if (_isLockPage(_currentIndex)) return;

    final currentItem = _currentItem;

    await HomeWidget.saveWidgetData<String>(
      'previewCategory',
      currentItem['kategori'] ?? 'Afirmasi',
    );

    await HomeWidget.saveWidgetData<String>(
      'previewQuote',
      currentItem['teks'] ?? '',
    );

    await HomeWidget.updateWidget(
      androidName: 'MoodlyWidgetProvider',
    );
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
        },
        onAdFailedToLoad: (error) {
          _rewardedAd = null;
          _isRewardedAdReady = false;
        },
      ),
    );
  }

  Map<String, String> get _currentItem {
    if (_afirmasiList.isEmpty) {
      return {
        'id': '',
        'kategori': 'Afirmasi',
        'teks': 'Belum ada afirmasi yang tersedia.',
      };
    }

    if (_currentIndex < 0 || _currentIndex >= _afirmasiList.length) {
      return _afirmasiList.first;
    }

    return _afirmasiList[_currentIndex];
  }

  String _backgroundForIndex(int index) {
    if (_backgroundImages.isEmpty) {
      return 'assets/icon/images/bg_afirmasi.jpg';
    }

    return _backgroundImages[index % _backgroundImages.length];
  }

  int get _unlockedSlidesCount {
    if (isPremiumUser) return _afirmasiList.length;

    final unlocked =
        freeSlideLimit + (_rewardedBlocksUnlocked * slidesPerRewardBlock);

    return unlocked > _afirmasiList.length ? _afirmasiList.length : unlocked;
  }

  int get _remainingLockedSlides {
    final remaining = _afirmasiList.length - _unlockedSlidesCount;
    return remaining < 0 ? 0 : remaining;
  }

  int get _pageViewItemCount {
    if (_afirmasiList.isEmpty) return 0;
    if (isPremiumUser) return _afirmasiList.length;

    final hasLockPage = _remainingLockedSlides > 0;
    return hasLockPage ? _unlockedSlidesCount + 1 : _unlockedSlidesCount;
  }

  bool _isLockPage(int index) {
    if (isPremiumUser) return false;
    return _remainingLockedSlides > 0 && index == _unlockedSlidesCount;
  }

  bool _isLockedSlide(int index) {
    if (isPremiumUser) return false;
    return _isLockPage(index);
  }

  bool get _isCurrentFavorite =>
      !_isLockedSlide(_currentIndex) &&
      _afirmasiList.isNotEmpty &&
      AfirmasiService.isFavorite(_currentItem);

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

  Widget _buildLockButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 180,
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFEDEDED),
          foregroundColor: Colors.black87,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.openSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  void _watchRewardedAd() {
    if (_remainingLockedSlides <= 0) {
      showCuteTopPopup(
        context,
        title: 'Semua terbuka',
        message: 'Semua slide sudah bisa diakses',
        type: CutePopupType.success,
      );
      return;
    }

    if (!_isRewardedAdReady || _rewardedAd == null) {
      showCuteTopPopup(
        context,
        title: 'Iklan belum siap',
        message: 'Coba lagi sebentar ya',
        type: CutePopupType.info,
      );

      _loadRewardedAd();
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        _loadRewardedAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _rewardedAd = null;
        _isRewardedAdReady = false;
        _loadRewardedAd();

        if (!mounted) return;
        showCuteTopPopup(
          context,
          title: 'Iklan gagal',
          message: 'Iklan gagal ditampilkan, coba lagi ya',
          type: CutePopupType.error,
        );
      },
    );

    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        if (!mounted) return;

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

          if (!_isLockPage(_currentIndex)) {
            _sendCurrentAfirmasiToWidget();
          }
        } else {
          showCuteTopPopup(
            context,
            title: 'Progress iklan',
            message: '1 dari 2 iklan selesai ditonton',
            type: CutePopupType.info,
          );
        }
      },
    );

    _rewardedAd = null;
    _isRewardedAdReady = false;
  }

  Future<void> _toggleFavorite() async {
    if (_afirmasiList.isEmpty) return;

    if (_isLockedSlide(_currentIndex)) {
      _showLockedFeaturePopup();
      return;
    }

    final currentItem = _currentItem;
    final wasFavorite = AfirmasiService.isFavorite(currentItem);

    await AfirmasiService.toggleFavorite(currentItem);

    if (!mounted) return;

    setState(() {});

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
    if (_afirmasiList.isEmpty) return;

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
    if (_afirmasiList.isEmpty) return;

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

    final currentItem = _currentItem;
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

    if (!mounted) return;
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
    return Container(
      color: Colors.black.withOpacity(0.45),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6B84E).withOpacity(0.95),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Tonton 2 iklan untuk membuka 5 slide berikutnya.',
                textAlign: TextAlign.center,
                style: GoogleFonts.fredoka(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Progress: $_watchedAdsCount / $adsNeededPerBlock iklan',
                textAlign: TextAlign.center,
                style: GoogleFonts.openSans(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(height: 22),
              _buildLockButton(
                title: 'tonton iklan',
                onTap: _watchRewardedAd,
              ),
              const SizedBox(height: 12),
              _buildLockButton(
                title: 'Dapatkan Premium',
                onTap: () {
                  showCuteTopPopup(
                    context,
                    title: 'Premium',
                    message: 'Halaman premium akan ditambahkan',
                    type: CutePopupType.warning,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    final totalVisible = _pageViewItemCount > freeSlideLimit
        ? freeSlideLimit
        : _pageViewItemCount;

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
    final currentItem = _currentItem;
    final isCurrentLockPage = _isLockPage(_currentIndex);
    final currentCategory =
        isCurrentLockPage ? 'Slide terkunci' : currentItem['kategori'] ?? 'Afirmasi';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Screenshot(
              controller: _screenshotController,
              child: Container(
                color: Colors.black,
                child: Stack(
  fit: StackFit.expand,
  children: [
    // ✅ BACKGROUND GLOBAL
    Image.asset(
      _backgroundForIndex(_currentIndex),
      fit: BoxFit.cover,
      gaplessPlayback: true,
    ),

    // ✅ overlay tipis
    Container(
      color: Colors.black.withOpacity(0.10),
    ),

    // ✅ konten utama
    if (_isLoading)
      const SizedBox.shrink()
    else
      PageView.builder(
        controller: _pageController,
        itemCount: _pageViewItemCount,
        onPageChanged: (index) async {
          setState(() {
            _currentIndex = index;
          });

          if (!_isLockPage(index)) {
            await _sendCurrentAfirmasiToWidget();
          }
        },
                        itemBuilder: (context, index) {
                          final isLockPage = _isLockPage(index);
                          final backgroundPath = _backgroundForIndex(index);

                          if (isLockPage) {
                            return Container(
                              color: Colors.black,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      backgroundPath,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return Container(
                                          color: const Color(0xFF8C6A8E),
                                        );
                                      },
                                    ),
                                  ),
                                  Positioned.fill(
                                    child: _buildLockedOverlay(),
                                  ),
                                ],
                              ),
                            );
                          }

                          final item = _afirmasiList[index];

                          return Container(
                            color: Colors.black,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Positioned.fill(
                                  child: Image.asset(
                                    backgroundPath,
                                    fit: BoxFit.cover,
                                    gaplessPlayback: true,
                                    errorBuilder:
                                        (context, error, stackTrace) {
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32,
                                  ),
                                  child: Center(
                                    child: Text(
                                      item['teks'] ?? '',
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.fredoka(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 28,
                                        height: 1.35,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                  ],
                ),
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
                if (!_isLoading)
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