import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/models/premium_access_model.dart';
import '../../core/services/premium_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'premium_catalog.dart';

const String _prefLanguageKey = 'moodly_settings_language_code';

Future<Object?> openMoodlyPremiumPage(
  BuildContext context, {
  PremiumEntrySource source = PremiumEntrySource.home,
}) {
  return Navigator.push<Object?>(
    context,
    MaterialPageRoute(
      builder: (_) => MoodlyPremiumPage(source: source),
    ),
  );
}

class MoodlyPremiumPage extends StatefulWidget {
  final PremiumEntrySource source;

  const MoodlyPremiumPage({
    super.key,
    this.source = PremiumEntrySource.home,
  });

  @override
  State<MoodlyPremiumPage> createState() => _MoodlyPremiumPageState();
}

class _MoodlyPremiumPageState extends State<MoodlyPremiumPage> {
  late final PageController _pageController;

  int _currentPage = 1;
  int _selectedBillingIndex = 0;
  String _languageCode = 'id';
  bool _isActivatingPremium = false;
  bool _isLoadingAccess = true;
  PremiumAccessModel _access = PremiumAccessModel.empty();

  static const Color _bg = Color(0xFFF6FAEE);
  static const Color _card = Color(0xFFFFFEFB);
  static const Color _green = Color(0xFF86C96D);
  static const Color _greenDark = Color(0xFF5E9D4D);
  static const Color _greenSoft = Color(0xFFDDF1D2);
  static const Color _greenTint = Color(0xFFEFF8E8);
  static const Color _pink = Color(0xFFF5C8D3);
  static const Color _pinkSoft = Color(0xFFFFEFF4);
  static const Color _pinkDark = Color(0xFFD86E8B);
  static const Color _peach = Color(0xFFFFE7D8);
  static const Color _orange = Color(0xFFFFB56A);
  static const Color _orangeDark = Color(0xFFE98D4B);
  static const Color _textDark = Color(0xFF1E1E1E);
  static const Color _textSoft = Color(0xFF667163);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'title': 'Paket Premium',
      'freemium': 'Freemium',
      'premium': 'Premium',
      'studentPremium': 'Student Premium',
      'currentActive': 'Paket aktif saat ini',
      'recommended': 'Paling worth it',
      'comingSoon': 'Segera hadir',
      'comparisonTitle': 'Perbandingan dengan Freemium',
      'freeColumn': 'Freemium',
      'planColumn': 'Paket ini',
      'keepFree': 'Tetap di Freemium',
      'choosePlan': 'Pilih paket ini',
      'continueLater': 'Pembayaran nanti saja',
      'paymentSoonTitle': 'Pembayaran belum dibuka',
      'paymentSoonDesc':
          'Tampilan premium sudah siap. Alur pembayaran akan kita sambungkan di tahap berikutnya.',
      'studentSoonTitle': 'Student Premium segera hadir',
      'studentSoonDesc':
          'Gunakan email kampus untuk verifikasi. Alur aktivasi mahasiswa akan dibuka setelahnya.',
      'studentCta': 'Gunakan email kampus',
      'monthly': '1 bulan',
      'sixMonths': '6 bulan',
      'yearly': '1 tahun',
      'save': 'Hemat',
      'off': 'off',
      'allUsersSafeTitle': 'Bantuan penting tetap untuk semua user',
      'allUsersSafeDesc':
          'Moodly Premium memperkaya pengalaman, bukan membatasi akses dukungan dasar.',
      'companionNote':
          'Moodly tetap jadi ruang pendamping, bukan pengganti bantuan profesional.',
      'entryHomeTitle': 'Upgrade pengalaman Moodly-mu',
      'entryHomeDesc':
          'Buka insight lebih dalam, afirmasi lebih banyak, dan benefit streak yang lebih kaya.',
      'entryChatTitle': 'Filter gender adalah benefit premium',
      'entryChatDesc':
          'Freemium tetap bisa masuk ruang curhat. Premium membuka filter yang lebih spesifik.',
      'entryMoodTitle': 'Analisa mood kapan saja',
      'entryMoodDesc':
          'Gunakan Premium agar bisa melihat Analisa Mood kapan pun!',
      'freeTagline':
          'Akses dasar yang hangat dan cukup untuk journaling pelan-pelan.',
      'premiumTagline':
          'Lebih lengkap, lebih personal, dan lebih nyaman untuk dipakai rutin.',
      'studentTagline':
          'Moodly hadir bagi para mahasiswa, nikmati akses gratis melalui verifikasi email kampus.',
      'freeHero1': 'Mood, diary, dan statistik dasar',
      'freeHero2': 'Afirmasi standar setiap hari',
      'freeHero3': 'Tetap bisa ikut streak dan poin',
      'premiumHero1': 'Buka analisa mood kapan saja',
      'premiumHero2': 'Filter gender di chat anonim',
      'premiumHero3': 'Freeze streak ekstra + bonus poin',
      'premiumHero4': 'Buka lebih banyak afirmasi',
      'studentHero1': 'Benefit premium gratis untuk mahasiswa',
      'studentHero2': 'Verifikasi pakai email kampus',
      'studentHero3': 'Fokus untuk support belajar dan self-care',
      'studentHero4': 'Aktivasi akan segera hadir',
      'billedAt': 'Total pembayaran',
      'normalPrice': 'Harga normal',
      'studentFoot': 'Student Premium akan segera hadir.',
      'freeFooter':
          'Freemium tetap bisa menjaga harimu dengan baik. Premium hanya bikin pengalaman lebih kaya.',
      'premiumFooter':
          'Paket premium cocok kalau kamu ingin insight lebih detail dan akses lebih fleksibel.',
      'badgePopular': 'Favorit',
      'badgeStudent': 'Mahasiswa',
      'premiumOnTitle': 'Premium berhasil diaktifkan',
      'premiumOnBody':
          'Premium testing aktif untuk paket yang kamu pilih.',
      'premiumActiveButton': 'Paketmu aktif',
      'premiumActiveInfo': 'Akses premium kamu sedang aktif.',
      'activeUntil': 'Aktif sampai',
      'loadingPlan': 'Memuat status paket...',
    },
    'en': {
      'title': 'Premium Plans',
      'freemium': 'Freemium',
      'premium': 'Premium',
      'studentPremium': 'Student Premium',
      'currentActive': 'Currently active',
      'recommended': 'Best value',
      'comingSoon': 'Coming soon',
      'comparisonTitle': 'Compared with Freemium',
      'freeColumn': 'Freemium',
      'planColumn': 'This plan',
      'keepFree': 'Stay on Freemium',
      'choosePlan': 'Choose this plan',
      'continueLater': 'Payment later',
      'paymentSoonTitle': 'Payment is not connected yet',
      'paymentSoonDesc':
          'The premium UI is ready. We will connect the payment flow in the next stage.',
      'studentSoonTitle': 'Student Premium is coming soon',
      'studentSoonDesc':
          'Use your campus email for verification. The student activation flow will open later.',
      'studentCta': 'Use campus email',
      'monthly': '1 month',
      'sixMonths': '6 months',
      'yearly': '1 year',
      'save': 'Save',
      'off': 'off',
      'allUsersSafeTitle': 'Important support stays available to all users',
      'allUsersSafeDesc':
          'Moodly Premium enriches the experience. It does not block essential support.',
      'companionNote':
          'Moodly remains a companion space, not a replacement for professional care.',
      'entryHomeTitle': 'Upgrade your Moodly experience',
      'entryHomeDesc':
          'Unlock deeper insight, more affirmations, and richer streak benefits.',
      'entryChatTitle': 'Gender filter is a premium perk',
      'entryChatDesc':
          'Freemium can still access the anonymous chat. Premium unlocks more specific filtering.',
      'entryMoodTitle': 'Open mood analysis anytime',
      'entryMoodDesc':
          'Use Premium to open your Mood Analysis anytime.',
      'freeTagline':
          'Warm basic access for gentle journaling and daily emotional check-ins.',
      'premiumTagline':
          'More complete, more personal, and more comfortable for routine use.',
      'studentTagline':
          'Moodly is here for students, enjoy free access through campus email verification.',
      'freeHero1': 'Basic mood, diary, and statistics',
      'freeHero2': 'Standard daily affirmations',
      'freeHero3': 'Still join streaks and points',
      'premiumHero1': 'Open mood analysis anytime',
      'premiumHero2': 'Gender filter in anonymous chat',
      'premiumHero3': 'Extra streak freeze + point bonus',
      'premiumHero4': 'See more affirmations',
      'studentHero1': 'Student version of premium benefits',
      'studentHero2': 'Campus email verification',
      'studentHero3': 'Built around study support and self-care',
      'studentHero4': 'Activation is still coming soon',
      'billedAt': 'Billing total',
      'normalPrice': 'Normal price',
      'studentFoot': 'Student Premium is coming soon.',
      'freeFooter':
          'Freemium can still support your day well. Premium simply makes the experience richer.',
      'premiumFooter':
          'Premium is ideal if you want deeper insight and more flexible access.',
      'badgePopular': 'Popular',
      'badgeStudent': 'Student',
      'premiumOnTitle': 'Premium activated',
      'premiumOnBody': 'Testing premium is now active for your selected plan.',
      'premiumActiveButton': 'Your plan is active',
      'premiumActiveInfo': 'Your premium access is currently active.',
      'activeUntil': 'Active until',
      'loadingPlan': 'Loading plan status...',
    },
  };

  @override
  void initState() {
    super.initState();
    _currentPage = _resolveInitialPage(widget.source);
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.92,
    );
    _hydrate();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _hydrate() async {
    await _loadLanguage();
    await _loadPremiumAccess();
  }

  int _resolveInitialPage(PremiumEntrySource source) {
    switch (source) {
      case PremiumEntrySource.chatGender:
      case PremiumEntrySource.moodAnalysisLocked:
      case PremiumEntrySource.home:
        return 1;
    }
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefLanguageKey);

    if (!mounted) return;
    setState(() {
      _languageCode = saved == 'en' ? 'en' : 'id';
    });
  }

  Future<void> _loadPremiumAccess() async {
    try {
      await PremiumService.instance.refreshPremiumStatus();
      final access = await PremiumService.instance.getAccess();

      if (!mounted) return;
      setState(() {
        _access = access;
        _isLoadingAccess = false;

        if (access.hasPremiumAccess) {
          if (access.tier == PremiumTier.student) {
            _currentPage = 2;
          } else {
            _currentPage = 1;
          }
          _pageController.jumpToPage(_currentPage);
        }
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoadingAccess = false;
        _access = PremiumAccessModel.empty();
      });
    }
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  PremiumBillingOption get _selectedBilling =>
      kPremiumBillingOptions[_selectedBillingIndex];

  bool get _isCurrentFreemium => !_access.hasPremiumAccess;
  bool get _isCurrentPremium =>
      _access.hasPremiumAccess && _access.tier == PremiumTier.premium;
  bool get _isCurrentStudent =>
      _access.hasPremiumAccess && _access.tier == PremiumTier.student;

  TextStyle _headlineStyle(BuildContext context, {Color? color, double? size}) {
    return (Theme.of(context).textTheme.headlineLarge ??
            const TextStyle(fontSize: 24, fontWeight: FontWeight.w600))
        .copyWith(
      color: color ?? _textDark,
      fontSize: size,
      fontWeight: FontWeight.w700,
    );
  }

  TextStyle _titleStyle(BuildContext context, {Color? color, double? size}) {
    return (Theme.of(context).textTheme.titleMedium ??
            const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
        .copyWith(
      color: color ?? _textDark,
      fontSize: size,
      fontWeight: FontWeight.w700,
    );
  }

  TextStyle _bodyStyle(BuildContext context, {Color? color, double? size}) {
    return (Theme.of(context).textTheme.bodyMedium ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
        .copyWith(
      color: color ?? _textSoft,
      fontSize: size,
      height: 1.5,
      fontWeight: FontWeight.w600,
    );
  }

  TextStyle _bodySmallStyle(BuildContext context,
      {Color? color, double? size, FontWeight? weight}) {
    return (Theme.of(context).textTheme.bodySmall ??
            const TextStyle(fontSize: 12, fontWeight: FontWeight.w600))
        .copyWith(
      color: color ?? _textDark,
      fontSize: size,
      height: 1.4,
      fontWeight: weight ?? FontWeight.w700,
    );
  }

  TextStyle _labelStyle(BuildContext context, {Color? color, double? size}) {
    return (Theme.of(context).textTheme.labelLarge ??
            const TextStyle(fontSize: 14, fontWeight: FontWeight.w600))
        .copyWith(
      color: color,
      fontSize: size,
      fontWeight: FontWeight.w700,
    );
  }

  void _showPremiumSoonPopup() {
    showCuteTopPopup(
      context,
      title: _t('paymentSoonTitle'),
      message: _t('paymentSoonDesc'),
      type: CutePopupType.info,
      duration: const Duration(seconds: 3),
    );
  }

  void _showStudentSoonPopup() {
    showCuteTopPopup(
      context,
      title: _t('studentSoonTitle'),
      message: _t('studentSoonDesc'),
      type: CutePopupType.warning,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _activatePremiumForTesting() async {
    if (_isActivatingPremium || _isCurrentPremium) return;

    setState(() {
      _isActivatingPremium = true;
    });

    try {
      await PremiumService.instance.activatePremium(
        months: _selectedBilling.months,
        planId: _selectedBilling.id,
        source: 'manual_testing',
      );

      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: _t('premiumOnTitle'),
        message: _t('premiumOnBody'),
        type: CutePopupType.success,
        duration: const Duration(seconds: 3),
      );

      await _loadPremiumAccess();

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;

      showCuteTopPopup(
        context,
        title: _languageCode == 'en' ? 'Activation failed' : 'Aktivasi gagal',
        message: _languageCode == 'en'
            ? 'Premium testing could not be activated.'
            : 'Premium testing belum berhasil diaktifkan.',
        type: CutePopupType.error,
        duration: const Duration(seconds: 3),
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isActivatingPremium = false;
      });
    }
  }

  String _entryTitle() {
    switch (widget.source) {
      case PremiumEntrySource.chatGender:
        return _t('entryChatTitle');
      case PremiumEntrySource.moodAnalysisLocked:
        return _t('entryMoodTitle');
      case PremiumEntrySource.home:
        return _t('entryHomeTitle');
    }
  }

  String _entryDescription() {
    switch (widget.source) {
      case PremiumEntrySource.chatGender:
        return _t('entryChatDesc');
      case PremiumEntrySource.moodAnalysisLocked:
        return _t('entryMoodDesc');
      case PremiumEntrySource.home:
        return _t('entryHomeDesc');
    }
  }

  String _formatDate(DateTime value) {
    final monthNamesId = [
      'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun', 'Jul', 'Agu', 'Sep', 'Okt',
      'Nov', 'Des'
    ];
    final monthNamesEn = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct',
      'Nov', 'Dec'
    ];
    final months = _languageCode == 'en' ? monthNamesEn : monthNamesId;
    return '${value.day} ${months[value.month - 1]} ${value.year}';
  }

  String _currentPlanLabel(_PlanKind kind) {
    switch (kind) {
      case _PlanKind.freemium:
        return _isCurrentFreemium ? _t('currentActive') : _t('freemium');
      case _PlanKind.premium:
        return _isCurrentPremium ? _t('currentActive') : _t('premium');
      case _PlanKind.student:
        return _isCurrentStudent ? _t('currentActive') : _t('studentPremium');
    }
  }

  double _sliderHeight(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final raw = screenHeight * 0.72;
    if (raw < 600) return 600;
    if (raw > 760) return 760;
    return raw;
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: _bg,
        statusBarBrightness: Brightness.light,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarDividerColor: _bg,
      ),
      child: Scaffold(
        backgroundColor: _bg,
        body: Stack(
          children: [
            const Positioned.fill(child: _PremiumBackground()),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(18, 14, 18, 24 + safeBottom),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildEntryBanner(),
                    const SizedBox(height: 18),
                    if (_isLoadingAccess)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _t('loadingPlan'),
                          style: _bodyStyle(context),
                        ),
                      ),
                    _buildSlider(),
                    const SizedBox(height: 14),
                    _buildPageDots(),
                    const SizedBox(height: 20),
                    _buildAlwaysAvailableCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        _RoundButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _t('title'),
            style: _headlineStyle(context, size: 26),
          ),
        ),
      ],
    );
  }

  Widget _buildEntryBanner() {
    IconData icon;
    List<Color> colors;

    switch (widget.source) {
      case PremiumEntrySource.chatGender:
        icon = Icons.diversity_3_rounded;
        colors = const [Color(0xFFFFE7EE), Color(0xFFFFF6F8)];
        break;
      case PremiumEntrySource.moodAnalysisLocked:
        icon = Icons.insights_rounded;
        colors = const [Color(0xFFE5F7DB), Color(0xFFF7FCEE)];
        break;
      case PremiumEntrySource.home:
        icon = Icons.workspace_premium_rounded;
        colors = const [Color(0xFFFFECD7), Color(0xFFFFF7EE)];
        break;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(126, 141, 110, 0.12),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _greenDark,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _entryTitle(),
                  style: _titleStyle(context, size: 18),
                ),
                const SizedBox(height: 5),
                Text(
                  _entryDescription(),
                  style: _bodyStyle(context, size: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider() {
    return SizedBox(
      height: _sliderHeight(context),
      child: PageView(
        controller: _pageController,
        onPageChanged: (value) {
          setState(() {
            _currentPage = value;
          });
        },
        children: [
          _buildFreemiumSlide(),
          _buildPremiumSlide(),
          _buildStudentSlide(),
        ],
      ),
    );
  }

  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        final active = _currentPage == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? _greenDark : const Color(0xFFC9D9BE),
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }

  Widget _buildFreemiumSlide() {
    return _PlanSlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHero(
            title: _t('freemium'),
            tagline: _t('freeTagline'),
            accentA: _greenSoft,
            accentB: _pinkSoft,
            badgeText: _isCurrentFreemium ? _t('currentActive') : _t('freemium'),
            badgeColor: _green,
            emoji: '🌿',
          ),
          const SizedBox(height: 16),
          _buildMiniBenefits([
            _t('freeHero1'),
            _t('freeHero2'),
            _t('freeHero3'),
          ], accent: _green),
          const SizedBox(height: 18),
          _buildFeatureComparisonCard(_PlanKind.freemium),
          const SizedBox(height: 16),
          _buildBottomNote(
            text: _t('freeFooter'),
            background: _greenTint,
            icon: Icons.favorite_outline_rounded,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: _t('keepFree'),
            background: _greenSoft,
            foreground: _textDark,
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumSlide() {
    final isCurrentPlan = _isCurrentPremium;

    return _PlanSlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHero(
            title: _t('premium'),
            tagline: _t('premiumTagline'),
            accentA: const Color(0xFFFFE2D2),
            accentB: const Color(0xFFFFF1E7),
            badgeText: isCurrentPlan ? _t('currentActive') : _t('recommended'),
            badgeColor: isCurrentPlan ? _green : _orange,
            emoji: '👑',
          ),
          if (isCurrentPlan && _access.expiresAt != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: _greenTint,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t('premiumActiveInfo'),
                    style: _bodySmallStyle(context, color: _greenDark),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_t('activeUntil')}: ${_formatDate(_access.expiresAt!)}',
                    style: _bodyStyle(context, color: _greenDark, size: 12),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          _buildBillingSelector(),
          const SizedBox(height: 16),
          _buildPremiumPriceCard(),
          const SizedBox(height: 16),
          _buildMiniBenefits([
            _t('premiumHero1'),
            _t('premiumHero2'),
            _t('premiumHero3'),
            _t('premiumHero4'),
          ], accent: _pinkDark),
          const SizedBox(height: 18),
          _buildFeatureComparisonCard(_PlanKind.premium),
          const SizedBox(height: 16),
          _buildBottomNote(
            text: _t('premiumFooter'),
            background: _pinkSoft,
            icon: Icons.auto_awesome_rounded,
            iconColor: _pinkDark,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: isCurrentPlan
                ? _t('premiumActiveButton')
                : _isActivatingPremium
                    ? (_languageCode == 'en'
                        ? 'Activating...'
                        : 'Mengaktifkan...')
                    : _t('choosePlan'),
            background: isCurrentPlan ? _green : _orange,
            foreground: Colors.white,
            onTap: isCurrentPlan
                ? _showPremiumSoonPopup
                : (_isActivatingPremium ? () {} : _activatePremiumForTesting),
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: _showPremiumSoonPopup,
              child: Text(
                _t('continueLater'),
                style: _bodySmallStyle(context, color: _textSoft),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentSlide() {
    return _PlanSlideShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTopHero(
            title: _t('studentPremium'),
            tagline: _t('studentTagline'),
            accentA: const Color(0xFFE5F7DD),
            accentB: const Color(0xFFFFEEF4),
            badgeText: _isCurrentStudent ? _t('currentActive') : _t('badgeStudent'),
            badgeColor: _pink,
            emoji: '🎓',
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: const Color(0xFFF2D8B7),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: _peach,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        _t('comingSoon'),
                        style: _bodySmallStyle(
                          context,
                          color: _orangeDark,
                          size: 11,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.school_rounded,
                      size: 18,
                      color: _greenDark,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _t('studentCta'),
                  style: _headlineStyle(context, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  _t('studentFoot'),
                  style: _bodyStyle(context, size: 13),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildMiniBenefits([
            _t('studentHero1'),
            _t('studentHero2'),
            _t('studentHero3'),
            _t('studentHero4'),
          ], accent: _greenDark),
          const SizedBox(height: 18),
          _buildFeatureComparisonCard(_PlanKind.student),
          const SizedBox(height: 16),
          _buildBottomNote(
            text: _t('studentFoot'),
            background: const Color(0xFFF1F8EB),
            icon: Icons.email_outlined,
            iconColor: _greenDark,
          ),
          const SizedBox(height: 16),
          _buildActionButton(
            label: _t('studentCta'),
            background: _green,
            foreground: Colors.white,
            onTap: _showStudentSoonPopup,
          ),
        ],
      ),
    );
  }

  Widget _buildTopHero({
    required String title,
    required String tagline,
    required Color accentA,
    required Color accentB,
    required String badgeText,
    required Color badgeColor,
    required String emoji,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accentA, accentB],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(155, 168, 140, 0.14),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 6,
            top: 0,
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 42),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  badgeText,
                  style: _bodySmallStyle(
                    context,
                    color: Colors.white,
                    size: 11,
                    weight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                title,
                style: _headlineStyle(context, size: 28),
              ),
              const SizedBox(height: 8),
              Text(
                tagline,
                style: _bodyStyle(context, size: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSelector() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(kPremiumBillingOptions.length, (index) {
        final option = kPremiumBillingOptions[index];
        final selected = index == _selectedBillingIndex;

        String label;
        if (option.months == 1) {
          label = _t('monthly');
        } else if (option.months == 6) {
          label = _t('sixMonths');
        } else {
          label = _t('yearly');
        }

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedBillingIndex = index;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            decoration: BoxDecoration(
              color: selected ? _orange : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? _orange : const Color(0xFFE7E2D7),
                width: 1.2,
              ),
              boxShadow: selected
                  ? const [
                      BoxShadow(
                        color: Color.fromRGBO(255, 181, 106, 0.26),
                        blurRadius: 18,
                        offset: Offset(0, 8),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: _titleStyle(
                    context,
                    size: 15,
                    color: selected ? Colors.white : _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(option.totalPrice),
                  style: _bodySmallStyle(
                    context,
                    size: 12,
                    color: selected ? Colors.white : _textSoft,
                  ),
                ),
                if (option.discountPercent > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: selected
                          ? Colors.white.withOpacity(0.22)
                          : _pinkSoft,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${option.discountPercent}% ${_t('off')}',
                      style: _bodySmallStyle(
                        context,
                        size: 11,
                        color: selected ? Colors.white : _pinkDark,
                        weight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPremiumPriceCard() {
    final option = _selectedBilling;

    String durationLabel;
    if (option.months == 1) {
      durationLabel = _t('monthly');
    } else if (option.months == 6) {
      durationLabel = _t('sixMonths');
    } else {
      durationLabel = _t('yearly');
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(132, 147, 118, 0.10),
            blurRadius: 20,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_t('premium')} • $durationLabel',
            style: _titleStyle(context, size: 18),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  formatRupiah(option.totalPrice),
                  style: _headlineStyle(
                    context,
                    size: 30,
                    color: _orangeDark,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (option.discountPercent > 0)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    formatRupiah(option.normalPrice),
                    style: _bodyStyle(
                      context,
                      size: 13,
                      color: _textSoft,
                    ).copyWith(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          _priceMetaRow(_t('billedAt'), formatRupiah(option.totalPrice)),
          const SizedBox(height: 8),
          _priceMetaRow(_t('normalPrice'), formatRupiah(option.normalPrice)),
          if (option.discountPercent > 0) ...[
            const SizedBox(height: 8),
            _priceMetaRow(
              '${_t('save')} ${option.discountPercent}%',
              formatRupiah(option.savedAmount),
              highlight: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceMetaRow(String left, String right, {bool highlight = false}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            left,
            style: _bodyStyle(
              context,
              size: 13,
              color: highlight ? _greenDark : _textSoft,
            ).copyWith(
              fontWeight: highlight ? FontWeight.w800 : FontWeight.w600,
            ),
          ),
        ),
        Text(
          right,
          style: _bodySmallStyle(
            context,
            size: 13,
            color: highlight ? _greenDark : _textDark,
            weight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniBenefits(List<String> items, {required Color accent}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(132, 147, 118, 0.08),
            blurRadius: 18,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_rounded,
                        size: 16,
                        color: accent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: _bodySmallStyle(
                          context,
                          size: 13,
                          color: _textDark,
                          weight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildFeatureComparisonCard(_PlanKind kind) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(132, 147, 118, 0.10),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _t('comparisonTitle'),
            style: _titleStyle(context, size: 18),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FBF3),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _t('freeColumn'),
                    style: _bodySmallStyle(
                      context,
                      size: 12,
                      color: _greenDark,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
                Expanded(
                  child: Text(
                    _currentPlanLabel(kind),
                    textAlign: TextAlign.right,
                    style: _bodySmallStyle(
                      context,
                      size: 12,
                      color: _pinkDark,
                      weight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ...kPremiumFeatureRows.map((row) => _buildCompareRow(row, kind)),
        ],
      ),
    );
  }

  Widget _buildCompareRow(PremiumFeatureRow row, _PlanKind kind) {
    String rightText;
    switch (kind) {
      case _PlanKind.freemium:
        rightText = row.freeText(_languageCode);
        break;
      case _PlanKind.premium:
        rightText = row.premiumText(_languageCode);
        break;
      case _PlanKind.student:
        rightText = row.studentText(_languageCode);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFF0EEE8),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                row.emoji,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  row.title(_languageCode),
                  style: _titleStyle(context, size: 14),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          LayoutBuilder(
            builder: (context, constraints) {
              final stackVertically = constraints.maxWidth < 330;

              if (stackVertically) {
                return Column(
                  children: [
                    _compareCell(
                      title: _t('freeColumn'),
                      text: row.freeText(_languageCode),
                      background: _greenTint,
                      iconColor: _greenDark,
                    ),
                    const SizedBox(height: 10),
                    _compareCell(
                      title: _currentPlanLabel(kind),
                      text: rightText,
                      background: kind == _PlanKind.freemium
                          ? _greenTint
                          : kind == _PlanKind.premium
                              ? _pinkSoft
                              : _peach,
                      iconColor: kind == _PlanKind.freemium
                          ? _greenDark
                          : kind == _PlanKind.premium
                              ? _pinkDark
                              : _orangeDark,
                    ),
                  ],
                );
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _compareCell(
                      title: _t('freeColumn'),
                      text: row.freeText(_languageCode),
                      background: _greenTint,
                      iconColor: _greenDark,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _compareCell(
                      title: _currentPlanLabel(kind),
                      text: rightText,
                      background: kind == _PlanKind.freemium
                          ? _greenTint
                          : kind == _PlanKind.premium
                              ? _pinkSoft
                              : _peach,
                      iconColor: kind == _PlanKind.freemium
                          ? _greenDark
                          : kind == _PlanKind.premium
                              ? _pinkDark
                              : _orangeDark,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _compareCell({
    required String title,
    required String text,
    required Color background,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: _bodySmallStyle(
              context,
              size: 11,
              color: iconColor,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: iconColor,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: _bodyStyle(
                    context,
                    size: 12,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNote({
    required String text,
    required Color background,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: _bodyStyle(context, size: 12.5, color: _textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
        ),
        child: Text(
          label,
          style: _labelStyle(context, color: foreground, size: 14),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildAlwaysAvailableCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFE8F7DE), Color(0xFFFFF6F9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withOpacity(0.9),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            size: 30,
            color: _greenDark,
          ),
          const SizedBox(height: 10),
          Text(
            _t('allUsersSafeTitle'),
            textAlign: TextAlign.center,
            style: _titleStyle(context, size: 17),
          ),
          const SizedBox(height: 8),
          Text(
            _t('allUsersSafeDesc'),
            textAlign: TextAlign.center,
            style: _bodyStyle(context, size: 13),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _t('companionNote'),
              textAlign: TextAlign.center,
              style: _bodySmallStyle(
                context,
                size: 12,
                color: _textDark,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _PlanKind {
  freemium,
  premium,
  student,
}

class _PlanSlideShell extends StatelessWidget {
  final Widget child;

  const _PlanSlideShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.78),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: Colors.white.withOpacity(0.96),
            width: 1.2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(126, 141, 110, 0.12),
              blurRadius: 28,
              offset: Offset(0, 14),
            ),
          ],
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: child,
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(
            icon,
            color: const Color(0xFF1F1F1F),
            size: 20,
          ),
        ),
      ),
    );
  }
}

class _PremiumBackground extends StatelessWidget {
  const _PremiumBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          left: -60,
          top: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEFF3).withOpacity(0.90),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -70,
          top: 120,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              color: const Color(0xFFE9F7DE).withOpacity(0.95),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          left: -40,
          bottom: 140,
          child: Container(
            width: 190,
            height: 190,
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E8).withOpacity(0.95),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: -20,
          bottom: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F8E9).withOpacity(0.95),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}