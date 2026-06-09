import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import 'package:moodly/core/services/streak_service.dart';
import 'package:moodly/pages/afirmasi/afirmasi_favorit_page.dart';
import 'package:moodly/pages/afirmasi/pengaturan_widget_page.dart';
import 'package:moodly/pages/afirmasi/widgets/cute_top_popup.dart';
import 'package:moodly/pages/homepage.dart';
import 'package:moodly/pages/setting/moodly_settings_support.dart';
import 'package:moodly/pages/afirmasi/afirmasi.dart';
import 'package:moodly/services/afirmasi/afirmasi_service.dart';

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

  static const Color _chipBg = Color(0xE8FFFFFF);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _softWhite = Color(0xFFFDFCF8);
  static const Color _moodlyGreen = Color(0xFF99D28F);
  static const Color _moodlyGreenDark = Color(0xFF5E9A4D);
  static const Color _favoritePink = Color(0xFFF6C6D0);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'defaultCategory': 'Afirmasi',
      'emptyQuote': 'Belum ada afirmasi yang tersedia.',
      'lockedSlide': 'Slide terkunci',
      'maxSlidesLocked': 'Tonton 2 iklan untuk membuka 5 slide berikutnya.',
      'maxSlidesLockedWeb':
          'Buka aplikasi di Android/iOS untuk menonton 2 iklan dan membuka 5 slide berikutnya.',
      'progressAds': 'Progress: {current} / {total} iklan',
      'adReady': 'Iklan siap ditonton',
      'adLoading': 'Iklan sedang dimuat...',
      'adNotReady': 'Iklan belum siap',
      'watchAds': 'Tonton iklan',
      'androidOnly': 'Hanya di Android/iOS',
      'getPremium': 'Dapatkan Premium',
      'premiumSoonTitle': 'Premium',
      'premiumSoonBody': 'Halaman premium akan ditambahkan.',
      'webOnlyTitle': 'Tidak tersedia di web',
      'webOnlyBody': 'Iklan reward hanya bisa diuji di Android atau iOS.',
      'allOpenTitle': 'Semua terbuka',
      'allOpenBody': 'Semua slide sudah bisa diakses.',
      'adLoadingTitle': 'Iklan sedang dimuat',
      'adLoadingBody': 'Tunggu sebentar ya, iklannya lagi disiapkan.',
      'adNotReadyTitle': 'Iklan belum siap',
      'adNotReadyBody': 'Coba lagi sebentar ya.',
      'adFailedTitle': 'Iklan gagal',
      'adFailedBody': 'Iklan gagal ditampilkan, coba lagi ya.',
      'slideOpenedTitle': 'Slide terbuka',
      'slideOpenedBody':
          '5 slide berikutnya berhasil dibuka. Jika progress misi iklan streak sudah memenuhi target, bonus poin akan masuk otomatis.',
      'adProgressTitle': 'Progress iklan',
      'adProgressBody': '1 dari 2 iklan selesai ditonton.',
      'favoriteRemovedTitle': 'Favorit dihapus',
      'favoriteRemovedBody': 'Afirmasi dihapus dari daftar favorit.',
      'favoriteSavedTitle': 'Favorit disimpan',
      'favoriteSavedBody': 'Afirmasi berhasil disimpan ke favorit.',
      'downloadFailTitle': 'Gagal',
      'downloadFailBody': 'Gagal mengambil gambar afirmasi.',
      'permissionDeniedTitle': 'Izin ditolak',
      'permissionDeniedBody': 'Akses galeri dibutuhkan untuk mengunduh afirmasi.',
      'downloadSuccessTitle': 'Berhasil diunduh',
      'downloadSuccessBody': 'Afirmasi berhasil disimpan ke galeri.',
      'downloadErrorTitle': 'Gagal mengunduh',
      'downloadGenericTitle': 'Terjadi kesalahan',
      'downloadGenericBody': 'Afirmasi gagal diunduh, coba lagi ya.',
      'shareFailTitle': 'Gagal share',
      'shareFailBody': 'Gagal menyiapkan gambar afirmasi.',
      'shareReadyTitle': 'Siap dibagikan',
      'shareReadyBody': 'Afirmasi sedang dibuka ke menu share.',
      'favoriteEmptyTitle': 'Belum ada favorit',
      'favoriteEmptyBody': 'Simpan afirmasi favoritmu dulu ya.',
      'settingsResetCategory': 'Atur ulang kategori afirmasi',
      'settingsWidget': 'Pengaturan widget',
      'categoryPrefix': 'Kategori',
      'gratitude': 'Rasa Syukur',
      'anxiety': 'Meredakan Kecemasan',
      'motivation': 'Motivasi',
      'mental': 'Kesehatan Mental',
      'selfLove': 'Cinta Diri',
    },
    'en': {
      'defaultCategory': 'Affirmation',
      'emptyQuote': 'No affirmations are available yet.',
      'lockedSlide': 'Locked slide',
      'maxSlidesLocked': 'Watch 2 ads to unlock the next 5 slides.',
      'maxSlidesLockedWeb':
          'Open the app on Android/iOS to watch 2 ads and unlock the next 5 slides.',
      'progressAds': 'Progress: {current} / {total} ads',
      'adReady': 'Ad is ready to watch',
      'adLoading': 'Ad is loading...',
      'adNotReady': 'Ad is not ready yet',
      'watchAds': 'Watch ad',
      'androidOnly': 'Android/iOS only',
      'getPremium': 'Get Premium',
      'premiumSoonTitle': 'Premium',
      'premiumSoonBody': 'The premium page will be added later.',
      'webOnlyTitle': 'Not available on web',
      'webOnlyBody': 'Rewarded ads can only be tested on Android or iOS.',
      'allOpenTitle': 'Everything is unlocked',
      'allOpenBody': 'All slides are already accessible.',
      'adLoadingTitle': 'Ad is loading',
      'adLoadingBody': 'Please wait a moment, the ad is being prepared.',
      'adNotReadyTitle': 'Ad is not ready',
      'adNotReadyBody': 'Please try again in a moment.',
      'adFailedTitle': 'Ad failed',
      'adFailedBody': 'The ad failed to show. Please try again.',
      'slideOpenedTitle': 'Slides unlocked',
      'slideOpenedBody':
          'The next 5 slides have been unlocked. If your streak ad mission already meets the target, the bonus points will be added automatically.',
      'adProgressTitle': 'Ad progress',
      'adProgressBody': '1 out of 2 ads has been watched.',
      'favoriteRemovedTitle': 'Removed from favorites',
      'favoriteRemovedBody': 'The affirmation has been removed from favorites.',
      'favoriteSavedTitle': 'Saved to favorites',
      'favoriteSavedBody': 'The affirmation has been saved to favorites.',
      'downloadFailTitle': 'Failed',
      'downloadFailBody': 'Failed to capture the affirmation image.',
      'permissionDeniedTitle': 'Permission denied',
      'permissionDeniedBody': 'Gallery access is required to download affirmations.',
      'downloadSuccessTitle': 'Downloaded',
      'downloadSuccessBody': 'The affirmation has been saved to your gallery.',
      'downloadErrorTitle': 'Download failed',
      'downloadGenericTitle': 'Something went wrong',
      'downloadGenericBody': 'The affirmation could not be downloaded. Please try again.',
      'shareFailTitle': 'Share failed',
      'shareFailBody': 'Failed to prepare the affirmation image.',
      'shareReadyTitle': 'Ready to share',
      'shareReadyBody': 'The affirmation is being opened in the share menu.',
      'favoriteEmptyTitle': 'No favorites yet',
      'favoriteEmptyBody': 'Save your favorite affirmations first.',
      'settingsResetCategory': 'Reset affirmation categories',
      'settingsWidget': 'Widget settings',
      'categoryPrefix': 'Category',
      'gratitude': 'Gratitude',
      'anxiety': 'Ease Anxiety',
      'motivation': 'Motivation',
      'mental': 'Mental Health',
      'selfLove': 'Self Love',
    },
  };

  final List<String> _backgroundImages = [
    'assets/icon/images/bg_afirmasi_1.jpg',
    'assets/icon/images/bg_afirmasi_2.jpg',
    'assets/icon/images/bg_afirmasi_3.jpg',
    'assets/icon/images/bg_afirmasi_4.jpg',
    'assets/icon/images/bg_afirmasi_5.jpg',
  ];

  bool isPremiumUser = false;
  bool _isLoading = true;
  bool _isRewardedAdReady = false;
  bool _isAdLoading = false;

  int _rewardedBlocksUnlocked = 0;
  int _watchedAdsCount = 0;
  int _currentIndex = 0;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;
  String? _lastRewardedAdError;

  RewardedAd? _rewardedAd;
  List<Map<String, String>> _afirmasiList = [];

  final String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  bool get _canUseMobileAds => !kIsWeb;

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _initializePage();
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _pageController.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  String _template(String key, Map<String, String> vars) {
    var text = _t(key);
    vars.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  String _localizedCategoryLabel(String raw) {
    switch (AfirmasiService.canonicalCategoryKey(raw)) {
      case 'Rasa Syukur':
        return _t('gratitude');
      case 'Meredakan Kecemasan':
        return _t('anxiety');
      case 'Motivasi':
        return _t('motivation');
      case 'Kesehatan Mental':
        return _t('mental');
      case 'Cinta Diri':
        return _t('selfLove');
      default:
        return _languageCode == 'en'
            ? AfirmasiService.localizedCategoryLabel(raw, languageCode: 'en')
            : AfirmasiService.localizedCategoryLabel(raw, languageCode: 'id');
    }
  }

  Future<void> _initializePage() async {
    if (_canUseMobileAds) {
      try {
        await MobileAds.instance.initialize();
        debugPrint('MobileAds initialized');
      } catch (e) {
        debugPrint('MobileAds initialize error: $e');
      }
    }

    await _loadPremiumStatus();
    await AfirmasiService.loadFavoritesFromLocal();
    await _loadAfirmasi();

    if (_canUseMobileAds) {
      _loadRewardedAd(force: true);
    }
  }

  void _onLanguageChanged() {
    final nextLanguage = MoodlySettingsPrefs.currentLanguageCode;
    if (nextLanguage == _languageCode) return;

    _languageCode = nextLanguage;

    if (!mounted) return;
    setState(() {});
    _loadAfirmasi();
  }

  Future<void> _loadPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      isPremiumUser = prefs.getBool('isPremium') ?? false;
    });
  }

  void _goBackToHomepage() {
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const Homepage()),
      (route) => false,
    );
  }

  Future<void> _loadAfirmasi() async {
    setState(() {
      _isLoading = true;
    });

    final data = await AfirmasiService.getAfirmasiByCategories(
      widget.selectedCategories,
      languageCode: _languageCode,
    );

    data.shuffle(Random());

    if (!mounted) return;

    final previousIndex = _currentIndex;

    setState(() {
      _afirmasiList = data.isNotEmpty
          ? List<Map<String, String>>.from(data)
          : [
              {
                'id': '',
                'kategori_key': 'Afirmasi',
                'kategori': _t('defaultCategory'),
                'teks': _t('emptyQuote'),
                'teks_id': _copy['id']!['emptyQuote']!,
                'teks_en': _copy['en']!['emptyQuote']!,
              }
            ];
      _currentIndex = previousIndex.clamp(0, _pageViewItemCount == 0 ? 0 : _pageViewItemCount - 1);
      _isLoading = false;
    });

    await _sendCurrentAfirmasiToWidget();
    await _registerCurrentAfirmasiRead();
  }

  Future<void> _sendCurrentAfirmasiToWidget() async {
    if (_isLockPage(_currentIndex)) return;

    final currentItem = _currentItem;
    final currentWallpaper = _backgroundForIndex(_currentIndex);

    await HomeWidget.saveWidgetData<String>(
      'previewCategory',
      currentItem['kategori'] ?? _t('defaultCategory'),
    );

    await HomeWidget.saveWidgetData<String>(
      'previewQuote',
      currentItem['teks'] ?? _t('emptyQuote'),
    );

    await HomeWidget.saveWidgetData<String>(
      'selectedWallpaper',
      currentWallpaper,
    );

    await HomeWidget.saveWidgetData<String>('languageCode', _languageCode);

    await HomeWidget.updateWidget(
      androidName: 'MoodlyWidgetProvider',
    );
  }

  Future<void> _registerCurrentAfirmasiRead() async {
    if (_afirmasiList.isEmpty) return;
    if (_isLockPage(_currentIndex)) return;

    final affirmationId = (_currentItem['id'] ?? '').trim();
    if (affirmationId.isEmpty) return;

    await StreakService.instance.registerAffirmationRead(
      affirmationId: affirmationId,
    );
  }

  Future<void> _registerCurrentAfirmasiShare() async {
    await StreakService.instance.registerAffirmationShare();
  }

  void _loadRewardedAd({bool force = false}) {
    if (!_canUseMobileAds) {
      _rewardedAd?.dispose();
      _rewardedAd = null;
      if (mounted) {
        setState(() {
          _isRewardedAdReady = false;
          _isAdLoading = false;
          _lastRewardedAdError = _t('webOnlyBody');
        });
      }
      return;
    }

    if (_isAdLoading) return;
    if (!force && _rewardedAd != null) return;

    if (mounted) {
      setState(() {
        _isAdLoading = true;
        _lastRewardedAdError = null;
      });
    }

    RewardedAd.load(
      adUnitId: rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          debugPrint('RewardedAd loaded successfully');
          _rewardedAd?.dispose();

          if (!mounted) {
            ad.dispose();
            return;
          }

          setState(() {
            _rewardedAd = ad;
            _isRewardedAdReady = true;
            _isAdLoading = false;
            _lastRewardedAdError = null;
          });
        },
        onAdFailedToLoad: (error) {
          debugPrint(
            'RewardedAd failed to load: ${error.code} | ${error.message}',
          );

          _rewardedAd?.dispose();
          _rewardedAd = null;

          if (!mounted) return;

          setState(() {
            _isRewardedAdReady = false;
            _isAdLoading = false;
            _lastRewardedAdError = '[${error.code}] ${error.message}';
          });

          Future.delayed(const Duration(seconds: 8), () {
            if (mounted && _rewardedAd == null && !_isAdLoading) {
              _loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  Map<String, String> get _currentItem {
    if (_afirmasiList.isEmpty) {
      return {
        'id': '',
        'kategori_key': 'Afirmasi',
        'kategori': _t('defaultCategory'),
        'teks': _t('emptyQuote'),
        'teks_id': _copy['id']!['emptyQuote']!,
        'teks_en': _copy['en']!['emptyQuote']!,
      };
    }

    if (_currentIndex < 0 || _currentIndex >= _afirmasiList.length) {
      return _afirmasiList.first;
    }

    return _afirmasiList[_currentIndex];
  }

  String _backgroundForIndex(int index) {
    if (_backgroundImages.isEmpty) {
      return 'assets/icon/images/bg_afirmasi_1.jpg';
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
      title: _t('lockedSlide'),
      message: _t('maxSlidesLocked'),
      type: CutePopupType.warning,
    );
  }

  Widget _buildLockButton({
    required String title,
    required VoidCallback onTap,
    required bool primary,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return SizedBox(
      width: 210,
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: primary ? _moodlyGreen : _softWhite,
          foregroundColor: primary ? Colors.white : _textDark,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          title,
          style: (primary ? textTheme.labelLarge : textTheme.bodySmall)
              ?.copyWith(
            color: primary ? Colors.white : _textDark,
          ),
        ),
      ),
    );
  }

  Future<void> _watchRewardedAd() async {
    if (!_canUseMobileAds) {
      showCuteTopPopup(
        context,
        title: _t('webOnlyTitle'),
        message: _t('webOnlyBody'),
        type: CutePopupType.info,
      );
      return;
    }

    if (_remainingLockedSlides <= 0) {
      showCuteTopPopup(
        context,
        title: _t('allOpenTitle'),
        message: _t('allOpenBody'),
        type: CutePopupType.success,
      );
      return;
    }

    if (_isAdLoading) {
      showCuteTopPopup(
        context,
        title: _t('adLoadingTitle'),
        message: _t('adLoadingBody'),
        type: CutePopupType.info,
      );
      return;
    }

    final ad = _rewardedAd;

    if (!_isRewardedAdReady || ad == null) {
      _loadRewardedAd(force: true);

      showCuteTopPopup(
        context,
        title: _t('adNotReadyTitle'),
        message: _lastRewardedAdError == null
            ? _t('adNotReadyBody')
            : '${_t('adNotReadyBody')} ${_lastRewardedAdError!}',
        type: CutePopupType.info,
      );
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();

        if (!mounted) return;

        setState(() {
          _rewardedAd = null;
          _isRewardedAdReady = false;
        });

        _loadRewardedAd(force: true);
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint(
          'RewardedAd failed to show: ${error.code} | ${error.message}',
        );

        ad.dispose();

        if (!mounted) return;

        setState(() {
          _rewardedAd = null;
          _isRewardedAdReady = false;
          _lastRewardedAdError = '[show:${error.code}] ${error.message}';
        });

        _loadRewardedAd(force: true);

        showCuteTopPopup(
          context,
          title: _t('adFailedTitle'),
          message: _t('adFailedBody'),
          type: CutePopupType.error,
        );
      },
    );

    setState(() {
      _rewardedAd = null;
      _isRewardedAdReady = false;
    });

    ad.show(
      onUserEarnedReward: (ad, reward) async {
        if (!mounted) return;

        setState(() {
          _watchedAdsCount += 1;
          if (_watchedAdsCount >= adsNeededPerBlock) {
            _watchedAdsCount = 0;
            _rewardedBlocksUnlocked += 1;
          }
        });

        await StreakService.instance.registerRewardedAdWatch();

        if (!mounted) return;

        if (_watchedAdsCount == 0) {
          showCuteTopPopup(
            context,
            title: _t('slideOpenedTitle'),
            message: _t('slideOpenedBody'),
            type: CutePopupType.success,
          );

          if (!_isLockPage(_currentIndex)) {
            await _sendCurrentAfirmasiToWidget();
          }
        } else {
          showCuteTopPopup(
            context,
            title: _t('adProgressTitle'),
            message: _t('adProgressBody'),
            type: CutePopupType.info,
          );
        }
      },
    );
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
      title: wasFavorite
          ? _t('favoriteRemovedTitle')
          : _t('favoriteSavedTitle'),
      message:
          wasFavorite ? _t('favoriteRemovedBody') : _t('favoriteSavedBody'),
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
        title: _t('downloadFailTitle'),
        message: _t('downloadFailBody'),
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
          title: _t('permissionDeniedTitle'),
          message: _t('permissionDeniedBody'),
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
        title: _t('downloadSuccessTitle'),
        message: _t('downloadSuccessBody'),
        type: CutePopupType.success,
      );
    } on GalException catch (e) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('downloadErrorTitle'),
        message: e.type.message,
        type: CutePopupType.error,
      );
    } catch (_) {
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: _t('downloadGenericTitle'),
        message: _t('downloadGenericBody'),
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
        title: _t('shareFailTitle'),
        message: _t('shareFailBody'),
        type: CutePopupType.error,
      );
      return;
    }

    final currentItem = _currentItem;
    final shareText =
        '${currentItem['teks'] ?? ''}\n\n${_t('categoryPrefix')}: ${currentItem['kategori'] ?? '-'}';

    showCuteTopPopup(
      context,
      title: _t('shareReadyTitle'),
      message: _t('shareReadyBody'),
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

    await _registerCurrentAfirmasiShare();
  }

  Future<void> _showFavoriteList() async {
    final favoritItems = AfirmasiService.getFavoritItems(
      languageCode: _languageCode,
    );

    if (favoritItems.isEmpty) {
      showCuteTopPopup(
        context,
        title: _t('favoriteEmptyTitle'),
        message: _t('favoriteEmptyBody'),
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
    final pageContext = context;

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
                top: 72,
                right: 20,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    width: 260,
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
                          title: _t('settingsResetCategory'),
                          onTap: () async {
                            Navigator.of(pageContext).pop();

                            await AfirmasiPage.clearSavedCategories();

                            if (!mounted) return;

                            Navigator.pushReplacement(
                              pageContext,
                              MaterialPageRoute(
                                builder: (_) => const AfirmasiPage(forcePicker: true),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 8),
                        _popupItem(
                          icon: Icons.widgets_outlined,
                          title: _t('settingsWidget'),
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
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.82),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
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
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 13.5,
                  color: const Color(0xFF3B343F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedOverlay() {
    final textTheme = Theme.of(context).textTheme;
    final adReadyText = _isRewardedAdReady
        ? _t('adReady')
        : (_isAdLoading ? _t('adLoading') : _t('adNotReady'));

    return Container(
      color: Colors.black.withOpacity(0.42),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 22),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.16),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: Colors.white.withOpacity(0.18)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE6B84E).withOpacity(0.95),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _canUseMobileAds
                      ? _t('maxSlidesLocked')
                      : _t('maxSlidesLockedWeb'),
                  textAlign: TextAlign.center,
                  style: textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  _template(
                    'progressAds',
                    {
                      'current': '$_watchedAdsCount',
                      'total': '$adsNeededPerBlock',
                    },
                  ),
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  adReadyText,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 20),
                _buildLockButton(
                  title: _canUseMobileAds ? _t('watchAds') : _t('androidOnly'),
                  onTap: _watchRewardedAd,
                  primary: true,
                ),
                const SizedBox(height: 10),
                _buildLockButton(
                  title: _t('getPremium'),
                  onTap: () {
                    showCuteTopPopup(
                      context,
                      title: _t('premiumSoonTitle'),
                      message: _t('premiumSoonBody'),
                      type: CutePopupType.warning,
                    );
                  },
                  primary: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    final totalVisible =
        _pageViewItemCount > freeSlideLimit ? freeSlideLimit : _pageViewItemCount;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        totalVisible,
        (index) {
          final activeIndex =
              _currentIndex >= totalVisible ? totalVisible - 1 : _currentIndex;

          final bool isActive = index == activeIndex;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: isActive ? 18 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              color: isActive
                  ? const Color(0xFFA6D68A)
                  : Colors.white.withOpacity(0.72),
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
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(active ? 0.94 : 0.88),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 24,
          color: active ? _favoritePink : const Color(0xFF3F4340),
        ),
      ),
    );
  }

  Widget _buildTopBar(String currentCategory) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          _circleTopButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: _goBackToHomepage,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: _chipBg,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  currentCategory,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textTheme.bodySmall?.copyWith(
                    color: _textDark,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _circleTopButton(
            icon: Icons.settings_outlined,
            onTap: _showSettingsMenu,
          ),
        ],
      ),
    );
  }

  Widget _circleTopButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: _chipBg,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: _textDark,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildQuotePage(Map<String, String> item, String backgroundPath) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(
            backgroundPath,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            errorBuilder: (context, error, stackTrace) {
              return Container(color: const Color(0xFF8C6A8E));
            },
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.10),
                  Colors.black.withOpacity(0.16),
                  Colors.black.withOpacity(0.22),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 110, 28, 145),
          child: Column(
            children: [
              const Spacer(),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 28, 24, 28),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                    width: 1.2,
                  ),
                ),
                child: Text(
                  item['teks'] ?? '',
                  textAlign: TextAlign.center,
                  style: textTheme.headlineLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 28,
                    height: 1.38,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionDock() {
    return Container(
      margin: const EdgeInsets.fromLTRB(22, 0, 22, 28),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildBottomButton(
            icon: _isCurrentFavorite
                ? Icons.favorite_rounded
                : Icons.favorite_border_rounded,
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
            icon: Icons.bookmark_border_rounded,
            onTap: _showFavoriteList,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _currentItem;
    final isCurrentLockPage = _isLockPage(_currentIndex);
    final currentCategory = isCurrentLockPage
        ? _t('lockedSlide')
        : currentItem['kategori'] ?? _t('defaultCategory');

    return WillPopScope(
      onWillPop: () async {
        _goBackToHomepage();
        return false;
      },
      child: Scaffold(
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
                      Image.asset(
                        _backgroundForIndex(_currentIndex),
                        fit: BoxFit.cover,
                        gaplessPlayback: true,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.10),
                      ),
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

                            await _sendCurrentAfirmasiToWidget();
                            await _registerCurrentAfirmasiRead();
                          },
                          itemBuilder: (context, index) {
                            final isLockPage = _isLockPage(index);
                            final backgroundPath = _backgroundForIndex(index);

                            if (isLockPage) {
                              return Stack(
                                fit: StackFit.expand,
                                children: [
                                  Positioned.fill(
                                    child: Image.asset(
                                      backgroundPath,
                                      fit: BoxFit.cover,
                                      gaplessPlayback: true,
                                      errorBuilder: (context, error, stackTrace) {
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
                              );
                            }

                            final item = _afirmasiList[index];
                            return _buildQuotePage(item, backgroundPath);
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
                  _buildTopBar(currentCategory),
                  const Spacer(),
                  if (!_isLoading)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: _buildDots(),
                    ),
                  _buildActionDock(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
