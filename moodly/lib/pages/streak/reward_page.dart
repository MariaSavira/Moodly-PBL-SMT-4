import 'package:flutter/material.dart';
import '../../core/services/reward_service.dart';
import '../../widgets/streak/streak_feedback_popup.dart';

enum _RewardSectionTab { reguler, premium }

class RewardPage extends StatefulWidget {
  final int totalPoints;

  const RewardPage({
    super.key,
    required this.totalPoints,
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

  _RewardSectionTab _selectedTab = _RewardSectionTab.reguler;
  final TextEditingController _giftUserIdController = TextEditingController();

  late int _currentPoints;

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
  }

  @override
  void dispose() {
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

      await showStreakFeedbackPopup(
        context,
        title: 'Hadiah berhasil ditukar',
        message: result.message,
        icon: item.icon,
        accent: item.iconColor,
        chipLabel: '-${item.price} poin',
        secondaryChipLabel: item.title,
        buttonLabel: 'Sip',
      );
    } else {
      await showStreakFeedbackPopup(
        context,
        title: 'Penukaran gagal',
        message: result.message,
        icon: Icons.info_outline_rounded,
        accent: const Color(0xFFE58696),
        buttonLabel: 'Mengerti',
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
                  'Hadiahkan Premium',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 24,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Masukkan User ID teman yang ingin kamu beri premium 1 bulan.',
                  style: textTheme.bodyMedium?.copyWith(
                    color: _textSoft,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _giftUserIdController,
                  decoration: InputDecoration(
                    hintText: 'Masukkan User ID',
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
                    child: const Text('Lanjutkan'),
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
            'Hadiah',
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
                  'Total poinmu',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$_currentPoints poin',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 30,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan poinmu untuk hadiah kecil yang menyenangkan, atau simpan untuk hadiah besar.',
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
            label: 'Hadiah Reguler',
            active: _selectedTab == _RewardSectionTab.reguler,
            activeBg: _greenSoft,
            onTap: () => setState(() => _selectedTab = _RewardSectionTab.reguler),
          ),
          const SizedBox(width: 8),
          tab(
            label: 'Hadiah Premium',
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
      buttonLabel = 'Dimiliki';
      buttonColor = const Color(0xFFEAEAE4);
      buttonTextColor = _textSoft;
    } else if (canAfford) {
      buttonLabel = 'Tukar';
      buttonColor = _green;
      buttonTextColor = Colors.white;
    } else {
      buttonLabel = 'Kurang';
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
                  item.title,
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 14,
                    color: _textDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${item.price} poin',
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
                            title: entry.key,
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