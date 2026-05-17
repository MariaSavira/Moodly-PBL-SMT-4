import 'package:flutter/material.dart';
import '../../core/services/reward_service.dart';
import '../../widgets/streak/streak_feedback_popup.dart';

class RewardPage extends StatefulWidget {
  
  final int totalPoints;

  const RewardPage({
    super.key,
    required this.totalPoints,
  });

  static const Color _bg = Color(0xFFF3FADC);
  static const Color _card = Color(0xFFFFFDF9);
  static const Color _green = Color(0xFF84C76A);
  static const Color _greenSoft = Color(0xFFEAF6DA);
  static const Color _pink = Color(0xFFF6BDC4);
  static const Color _pinkSoft = Color(0xFFFFEEF1);
  static const Color _mintSoft = Color(0xFFEFFAF7);
  static const Color _textDark = Color(0xFF222222);
  static const Color _textSoft = Color(0xFF6F7A67);

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
          title: 'Avatar Oren Imut',
          subtitle: 'Avatar anonim baru',
          price: 120,
          category: 'Avatar',
          icon: Icons.face_rounded,
          accent: Color(0xFFF8D3D9),
          iconColor: Color(0xFFE58696),
        ),
        _RewardItem(
          title: 'Avatar Matcha Calm',
          subtitle: 'Avatar anonim baru',
          price: 160,
          category: 'Avatar',
          icon: Icons.face_retouching_natural_rounded,
          accent: Color(0xFFE5F3D7),
          iconColor: Color(0xFF74B55F),
        ),
        _RewardItem(
          title: 'Frame Bloom',
          subtitle: 'Dekor avatar lembut',
          price: 90,
          category: 'Frame',
          icon: Icons.auto_awesome_rounded,
          accent: Color(0xFFFFEEF1),
          iconColor: Color(0xFFE58696),
        ),
        _RewardItem(
          title: 'Frame Meadow',
          subtitle: 'Dekor avatar hijau',
          price: 110,
          category: 'Frame',
          icon: Icons.filter_vintage_rounded,
          accent: Color(0xFFEAF6DA),
          iconColor: Color(0xFF74B55F),
        ),
        _RewardItem(
          title: 'Freeze +1 Hari',
          subtitle: 'Tambah proteksi streak',
          price: 180,
          category: 'Freeze',
          icon: Icons.favorite_rounded,
          accent: Color(0xFFDFF3ED),
          iconColor: Color(0xFF63B8A2),
        ),
        _RewardItem(
          title: 'Premium 1 Bulan',
          subtitle: 'Hadiah besar dari poinmu',
          price: 3200,
          category: 'Premium',
          icon: Icons.workspace_premium_rounded,
          accent: Color(0xFFF5EAFB),
          iconColor: Color(0xFF9A76B3),
          isHighlight: true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final grouped = <String, List<_RewardItem>>{};
    for (final item in _items) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }

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
            CustomScrollView(
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
                    child: _buildRewardCategoryChips(context),
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
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
              ],
            ),
          ],
        ),
      ),
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
            'Reward',
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
                  '$totalPoints poin',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 30,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Gunakan poinmu untuk reward kecil yang menyenangkan, atau simpan untuk hadiah besar.',
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

  Widget _buildRewardCategoryChips(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    Widget chip(String label, Color bg, Color fg) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 12,
            color: fg,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        chip('Reward Reguler', _greenSoft, _textDark),
        chip('Reward Premium', _pinkSoft, _textDark),
      ],
    );
  }

  void _showRewardSuccessPopup(BuildContext context, _RewardItem item) {
    showStreakFeedbackPopup(
      context,
      title: 'Reward berhasil ditukar',
      message:
          'Reward pilihanmu berhasil diklaim. Nikmati hadiah kecil ini untuk menemani perjalananmu.',
      icon: item.icon,
      accent: item.iconColor,
      chipLabel: '-${item.price} poin',
      secondaryChipLabel: item.title,
      buttonLabel: 'Sip',
    );
  }

  void _showNotEnoughPointsPopup(BuildContext context, _RewardItem item) {
    final shortage = item.price - totalPoints;

    showStreakFeedbackPopup(
      context,
      title: 'Poinmu belum cukup',
      message:
          'Kamu masih butuh sedikit lagi untuk menukar reward ini. Santai, lanjutkan streak-mu pelan-pelan.',
      icon: Icons.lock_rounded,
      accent: const Color(0xFFE58696),
      chipLabel: 'Kurang $shortage poin',
      secondaryChipLabel: item.title,
      buttonLabel: 'Mengerti',
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_RewardItem> items,
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
          ...items.map((item) => Padding(
                padding: EdgeInsets.only(
                  bottom: item == items.last ? 0 : 12,
                ),
                child: _buildRewardItemCard(context, item),
              )),
        ],
      ),
    );
  }

  Widget _buildRewardItemCard(BuildContext context, _RewardItem item) {
  final textTheme = Theme.of(context).textTheme;
  final canAfford = totalPoints >= item.price;

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
          onTap: () {
            if (canAfford) {
              _showRewardSuccessPopup(context, item);
            } else {
              _showNotEnoughPointsPopup(context, item);
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: canAfford ? _green : const Color(0xFFEAEAE4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              canAfford ? 'Beli' : 'Kurang',
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: canAfford ? Colors.white : _textSoft,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    ),
  );
  
}
}
class _RewardPageState extends State<RewardPage> {
  enum _RewardSectionTab { reguler, premium }
  _RewardSectionTab _selectedTab = _RewardSectionTab.reguler;
  final TextEditingController _giftUserIdController = TextEditingController();

  @override
  void dispose() {
    _giftUserIdController.dispose();
    super.dispose();
  }
class _RewardItem {
  final String title;
  final String subtitle;
  final int price;
  final String category;
  final IconData icon;
  final Color accent;
  final Color iconColor;
  final bool isHighlight;

  const _RewardItem({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.category,
    required this.icon,
    required this.accent,
    required this.iconColor,
    this.isHighlight = false,
  });
}