import 'package:flutter/material.dart';
import '../../core/services/reward_service.dart';
import '../../widgets/streak/streak_feedback_popup.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../setting/moodly_settings_support.dart';

enum _RewardSectionTab { reguler, premium }

class RewardPage extends StatefulWidget {
  final int totalPoints;
  final bool openPremiumTab;

  const RewardPage({
    super.key,
    required this.totalPoints,
    this.openPremiumTab = false,
  });

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  static const Color _bg = Color(0xFFF3FADC);
  static const Color _card = Color(0xFFFFFDF9);
  static const Color _green = Color(0xFF84C76A);
  static const Color _greenSoft = Color(0xFFEAF6DA);
  static const Color _pink = Color(0xFFF6BDC4);
  static const Color _pinkSoft = Color(0xFFFFEEF1);
  static const Color _mintSoft = Color(0xFFEFFAF7);
  static const Color _textDark = Color(0xFF222222);
  static const Color _textSoft = Color(0xFF6F7A67);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Hadiah',
      'regularReward': 'Hadiah Reguler',
      'premiumReward': 'Hadiah Premium',
      'points': 'poin',
      'redeemSuccess': 'Hadiah berhasil ditukar',
      'redeemFailed': 'Penukaran gagal',
      'giftPremium': 'Hadiahkan Premium',
      'understood': 'Mengerti',
      'ok': 'Sip',
      'redeemPremiumSelfSuccess': 'Premium 1 bulan berhasil diaktifkan untuk akunmu.',
      'redeemPremiumGiftSuccess': 'Premium 1 bulan berhasil dikirim ke user tujuan.',
      'redeemPremiumPartial':
          'Poin sudah diproses, tapi aktivasi premium belum sempurna. Cek ulang data user atau service premium.',
    },
    'en': {
      'header': 'Rewards',
      'regularReward': 'Regular Rewards',
      'premiumReward': 'Premium Rewards',
      'points': 'points',
      'redeemSuccess': 'Reward redeemed successfully',
      'redeemFailed': 'Redemption failed',
      'giftPremium': 'Gift Premium',
      'understood': 'Understood',
      'ok': 'Got it',
      'redeemPremiumSelfSuccess': '1 month premium has been activated for your account.',
      'redeemPremiumGiftSuccess': '1 month premium has been sent to the selected user.',
      'redeemPremiumPartial':
      'The points were processed, but premium activation did not finish properly. Please recheck the user data or premium service.',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  _RewardSectionTab _selectedTab = _RewardSectionTab.reguler;
  final TextEditingController _giftUserIdController = TextEditingController();

  late int _currentPoints;

  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  String _ui(String key) => _t(_languageCode, key);

  String _text(String idText, String enText) {
    return _languageCode == 'en' ? enText : idText;
  }

  String _pointsText(int value) => '$value ${_ui('points')}';

  String _itemTitle(_RewardItem item) {
    switch (item.id) {
      case 'avatar_oren_imut':
        return _text('Avatar Oren Imut', 'Cute Orange Avatar');
      case 'avatar_matcha_calm':
        return _text('Avatar Matcha Calm', 'Matcha Calm Avatar');
      case 'frame_bloom':
        return _text('Bingkai Bloom', 'Bloom Frame');
      case 'frame_meadow':
        return _text('Bingkai Meadow', 'Meadow Frame');
      case 'freeze_plus_1':
        return _text('Freeze +1 Hari', 'Freeze +1 Day');
      case 'premium_self_1_month':
        return _text('Premium 1 Bulan', '1 Month Premium');
      case 'premium_gift_1_month':
        return _text('Hadiahkan Premium', 'Gift Premium');
      default:
        return item.title;
    }
  }

  String _itemSubtitle(_RewardItem item) {
    switch (item.id) {
      case 'avatar_oren_imut':
        return _text('Avatar anonim baru', 'New anonymous avatar');
      case 'avatar_matcha_calm':
        return _text('Avatar anonim baru', 'New anonymous avatar');
      case 'frame_bloom':
        return _text('Dekor avatar lembut', 'Soft avatar decoration');
      case 'frame_meadow':
        return _text('Dekor avatar hijau', 'Green avatar decoration');
      case 'freeze_plus_1':
        return _text('Tambah proteksi streak', 'Add streak protection');
      case 'premium_self_1_month':
        return _text(
          'Aktifkan premium untuk dirimu',
          'Activate premium for your account',
        );
      case 'premium_gift_1_month':
        return _text(
          'Kirim premium 1 bulan via User ID',
          'Send 1 month premium via User ID',
        );
      default:
        return item.subtitle;
    }
  }

  String _actionLabel({
    required bool alreadyOwned,
    required bool canAfford,
  }) {
    if (alreadyOwned) {
      return _text('Dimiliki', 'Owned');
    }
    if (canAfford) {
      return _text('Tukar', 'Redeem');
    }
    return _text('Kurang', 'Not enough');
  }

  String _sectionTitle(String raw) {
    switch (raw) {
      case 'Avatar':
        return _text('Avatar', 'Avatar');
      case 'Bingkai':
        return _text('Bingkai', 'Frame');
      case 'Freeze':
        return 'Freeze';
      case 'Premium':
        return 'Premium';
      default:
        return raw;
    }
  }

  String _localizedRedeemMessage({
    required _RewardItem item,
    required bool success,
    required String rawMessage,
  }) {
    if (_languageCode != 'en') return rawMessage;

    if (success) {
      switch (item.kind) {
        case RewardKind.avatar:
        case RewardKind.frame:
        case RewardKind.freeze:
          return '${_itemTitle(item)} redeemed successfully.';
        case RewardKind.premiumSelf:
          return _ui('redeemPremiumSelfSuccess');
        case RewardKind.premiumGift:
          return _ui('redeemPremiumGiftSuccess');
      }
    }

    final lower = rawMessage.toLowerCase();

    if (lower.contains('tidak cukup') || lower.contains('poin kamu kurang')) {
      return 'Your points are not enough for this reward.';
    }
    if (lower.contains('sudah dimiliki')) {
      return 'You already own this reward.';
    }
    if (lower.contains('user id') &&
        (lower.contains('tidak ditemukan') || lower.contains('invalid'))) {
      return 'The destination User ID was not found.';
    }
    if (lower.contains('aktivasi premium') &&
        (lower.contains('belum') || lower.contains('tidak sempurna'))) {
      return _ui('redeemPremiumPartial');
    }
    if (lower.contains('gagal')) {
      return 'Reward redemption failed. Please try again.';
    }

    return rawMessage;
  }

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  List<_RewardItem> get _items => const [
        _RewardItem(
          id: 'avatar_oren_imut',
          title: 'Avatar Oren Imut',
          subtitle: 'Avatar anonim baru',
          price: 120,
          category: 'Avatar',
          kind: RewardKind.avatar,
          tab: _RewardSectionTab.reguler,
          icon: Icons.face_rounded,
          accent: Color(0xFFF8D3D9),
          iconColor: Color(0xFFE58696),
        ),
        _RewardItem(
          id: 'avatar_matcha_calm',
          title: 'Avatar Matcha Calm',
          subtitle: 'Avatar anonim baru',
          price: 160,
          category: 'Avatar',
          kind: RewardKind.avatar,
          tab: _RewardSectionTab.reguler,
          icon: Icons.face_retouching_natural_rounded,
          accent: Color(0xFFE5F3D7),
          iconColor: Color(0xFF74B55F),
        ),
        _RewardItem(
          id: 'frame_bloom',
          title: 'Bingkai Bloom',
          subtitle: 'Dekor avatar lembut',
          price: 90,
          category: 'Bingkai',
          kind: RewardKind.frame,
          tab: _RewardSectionTab.reguler,
          icon: Icons.auto_awesome_rounded,
          accent: Color(0xFFFFEEF1),
          iconColor: Color(0xFFE58696),
        ),
        _RewardItem(
          id: 'frame_meadow',
          title: 'Bingkai Meadow',
          subtitle: 'Dekor avatar hijau',
          price: 110,
          category: 'Bingkai',
          kind: RewardKind.frame,
          tab: _RewardSectionTab.reguler,
          icon: Icons.filter_vintage_rounded,
          accent: Color(0xFFEAF6DA),
          iconColor: Color(0xFF74B55F),
        ),
        _RewardItem(
          id: 'freeze_plus_1',
          title: 'Freeze +1 Hari',
          subtitle: 'Tambah proteksi streak',
          price: 180,
          category: 'Freeze',
          kind: RewardKind.freeze,
          tab: _RewardSectionTab.reguler,
          icon: Icons.favorite_rounded,
          accent: Color(0xFFDFF3ED),
          iconColor: Color(0xFF63B8A2),
        ),
        _RewardItem(
          id: 'premium_self_1_month',
          title: 'Premium 1 Bulan',
          subtitle: 'Aktifkan premium untuk dirimu',
          price: 3200,
          category: 'Premium',
          kind: RewardKind.premiumSelf,
          tab: _RewardSectionTab.premium,
          icon: Icons.workspace_premium_rounded,
          accent: Color(0xFFF5EAFB),
          iconColor: Color(0xFF9A76B3),
          isHighlight: true,
        ),
        _RewardItem(
          id: 'premium_gift_1_month',
          title: 'Hadiahkan Premium',
          subtitle: 'Kirim premium 1 bulan via User ID',
          price: 3200,
          category: 'Premium',
          kind: RewardKind.premiumGift,
          tab: _RewardSectionTab.premium,
          icon: Icons.card_giftcard_rounded,
          accent: Color(0xFFFFF0D9),
          iconColor: Color(0xFFE29A3A),
          isHighlight: true,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _currentPoints = widget.totalPoints;
    _selectedTab = widget.openPremiumTab
        ? _RewardSectionTab.premium
        : _RewardSectionTab.reguler;
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    _giftUserIdController.dispose();
    super.dispose();
  }

  Future<void> _redeemItem(
    BuildContext context,
    _RewardItem item, {
    required bool alreadyOwned,
  }) async {
    if (alreadyOwned) return;

    String? giftedUid;
    if (item.kind == RewardKind.premiumGift) {
      giftedUid = await _showGiftPremiumSheet(context);
      if (giftedUid == null || giftedUid.trim().isEmpty) return;
    }

    final result = await RewardService.instance.redeemItem(
      itemId: item.id,
      kind: item.kind,
      price: item.price,
      giftedUserId: giftedUid,
    );

    if (!context.mounted) return;

    if (result.success) {
      setState(() {
        _currentPoints = (_currentPoints - item.price).clamp(0, 9999999);
      });

      showCuteTopPopup(
        context,
        title: _ui('redeemSuccess'),
        message: _localizedRedeemMessage(
          item: item,
          success: true,
          rawMessage: result.message,
        ),
        type: CutePopupType.success,
      );
    } else {
      showCuteTopPopup(
        context,
        title: _ui('redeemFailed'),
        message: _localizedRedeemMessage(
          item: item,
          success: false,
          rawMessage: result.message,
        ),
        type: CutePopupType.error,
      );
    }
  }

  Future<String?> _showGiftPremiumSheet(BuildContext context) async {
    _giftUserIdController.clear();

    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return Padding(
          padding: EdgeInsets.only(
            left: 14,
            right: 14,
            bottom: MediaQuery.of(context).viewInsets.bottom + 14,
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(28),
              boxShadow: _softShadow,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _ui('giftPremium'),
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _text(
                    'Masukkan User ID teman yang ingin kamu beri premium 1 bulan.',
                    'Enter the User ID of the friend you want to gift 1 month premium to.',
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    color: _textSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _giftUserIdController,
                  decoration: InputDecoration(
                    hintText: _text('Masukkan User ID', 'Enter User ID'),
                    filled: true,
                    fillColor: _greenSoft.withOpacity(0.45),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      _giftUserIdController.text.trim(),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _green,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(_text('Lanjutkan', 'Continue')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.70),
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _textDark,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            _ui('header'),
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFD8DF),
            ),
            child: const Icon(
              Icons.stars_rounded,
              size: 28,
              color: Color(0xFFE58696),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _text('Total poinmu', 'Your total points'),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _pointsText(_currentPoints),
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 30,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _text(
                    'Gunakan poinmu untuk hadiah kecil yang menyenangkan, atau simpan untuk hadiah besar.',
                    'Use your points for small fun rewards, or save them for bigger ones.',
                  ),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    height: 1.45,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardTabs(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget tab({
      required String label,
      required bool active,
      required VoidCallback onTap,
      required Color activeBg,
    }) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: active ? activeBg : _card,
              borderRadius: BorderRadius.circular(18),
              boxShadow: active ? _softShadow : null,
            ),
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 13,
                color: _textDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F5E4),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          tab(
            label: _ui('regularReward'),
            active: _selectedTab == _RewardSectionTab.reguler,
            activeBg: _greenSoft,
            onTap: () => setState(() => _selectedTab = _RewardSectionTab.reguler),
          ),
          const SizedBox(width: 8),
          tab(
            label: _ui('premiumReward'),
            active: _selectedTab == _RewardSectionTab.premium,
            activeBg: _pinkSoft,
            onTap: () => setState(() => _selectedTab = _RewardSectionTab.premium),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_RewardItem> items,
    required Map<String, dynamic> inventory,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index == items.length - 1 ? 0 : 12),
              child: _buildRewardItemCard(context, item, inventory),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRewardItemCard(
    BuildContext context,
    _RewardItem item,
    Map<String, dynamic> inventory,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final canAfford = _currentPoints >= item.price;

    final ownedAvatarIds = List<String>.from(inventory['ownedAvatarIds'] ?? []);
    final ownedFrameIds = List<String>.from(inventory['ownedFrameIds'] ?? []);

    final bool alreadyOwned = switch (item.kind) {
      RewardKind.avatar => ownedAvatarIds.contains(item.id),
      RewardKind.frame => ownedFrameIds.contains(item.id),
      _ => false,
    };

    final String buttonLabel;
    final Color buttonColor;
    final Color buttonTextColor;

    if (alreadyOwned) {
      buttonLabel = _actionLabel(alreadyOwned: true, canAfford: canAfford);
      buttonColor = const Color(0xFFEAEAE4);
      buttonTextColor = _textSoft;
    } else if (canAfford) {
      buttonLabel = _actionLabel(alreadyOwned: false, canAfford: true);
      buttonColor = _green;
      buttonTextColor = Colors.white;
    } else {
      buttonLabel = _actionLabel(alreadyOwned: false, canAfford: false);
      buttonColor = const Color(0xFFEAEAE4);
      buttonTextColor = _textSoft;
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: item.isHighlight ? _greenSoft : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: item.accent.withOpacity(0.95),
          width: 1.1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: item.accent,
            ),
            child: Icon(
              item.icon,
              color: item.iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _itemTitle(item),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _itemSubtitle(item),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _pointsText(item.price),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: canAfford ? _green : const Color(0xFFC0818C),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: alreadyOwned || !canAfford
                ? null
                : () => _redeemItem(
                      context,
                      item,
                      alreadyOwned: alreadyOwned,
                    ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                buttonLabel,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: buttonTextColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 140,
              right: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _greenSoft.withOpacity(0.35),
                ),
              ),
            ),
            Positioned(
              bottom: -70,
              left: -60,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pinkSoft.withOpacity(0.40),
                ),
              ),
            ),
            StreamBuilder<Map<String, dynamic>>(
              stream: RewardService.instance.watchInventory(),
              builder: (context, snapshot) {
                final inventory = snapshot.data ?? {};

                final visibleItems =
                    _items.where((item) => item.tab == _selectedTab).toList();

                final grouped = <String, List<_RewardItem>>{};
                for (final item in visibleItems) {
                  grouped.putIfAbsent(item.category, () => []).add(item);
                }

                return CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                        child: _buildHeader(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildPointsCard(context),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                        child: _buildRewardTabs(context),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    ...grouped.entries.map(
                      (entry) => SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
                          child: _buildSection(
                            context,
                            title: _sectionTitle(entry.key),
                            items: entry.value,
                            inventory: inventory,
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RewardItem {
  final String id;
  final String title;
  final String subtitle;
  final int price;
  final String category;
  final RewardKind kind;
  final _RewardSectionTab tab;
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final bool isHighlight;

  const _RewardItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.kind,
    required this.tab,
    required this.icon,
    required this.accent,
    required this.iconColor,
    this.isHighlight = false,
  });
}