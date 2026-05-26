import 'package:flutter/material.dart';

class StreakDetailPage extends StatelessWidget {
  final int currentStreak;
  final bool freezeEnabled;
  final int freezeOwned;
  final int freezeMax;

  const StreakDetailPage({
    super.key,
    required this.currentStreak,
    required this.freezeEnabled,
    required this.freezeOwned,
    required this.freezeMax,
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

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Detail Streak',
      'activeStreak': 'Streak aktif',
      'freezeTitle': 'Freeze Streak',
      'badgeTitle': 'Milestone Badge',
      'todayHistory': 'Riwayat Hari Ini',
      'notUnlocked': 'Belum terbuka',
      'days': 'hari',
    },
    'en': {
      'header': 'Streak Detail',
      'activeStreak': 'Active streak',
      'freezeTitle': 'Streak Freeze',
      'badgeTitle': 'Milestone Badge',
      'todayHistory': 'Today\'s History',
      'notUnlocked': 'Locked',
      'days': 'days',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  List<_DayProgress> get _days => const [
        _DayProgress(label: 'Sen', isDone: true),
        _DayProgress(label: 'Sel', isDone: true),
        _DayProgress(label: 'Rab', isDone: true),
        _DayProgress(label: 'Kam', isDone: false, isFreezeUsed: true),
        _DayProgress(label: 'Jum', isDone: true),
        _DayProgress(label: 'Sab', isDone: true),
        _DayProgress(label: 'Min', isToday: true),
      ];

  List<_HistoryItem> get _history => const [
        _HistoryItem(
          title: 'Mood hari ini selesai',
          subtitle: '+10 poin',
          icon: Icons.sentiment_satisfied_alt_rounded,
          accent: Color(0xFFF8D3D9),
          iconColor: Color(0xFFE58696),
        ),
        _HistoryItem(
          title: 'Bonus combo harian',
          subtitle: '+5 poin',
          icon: Icons.auto_awesome_rounded,
          accent: Color(0xFFFFEEF1),
          iconColor: Color(0xFFE58696),
        ),
        _HistoryItem(
          title: 'Afirmasi dibaca',
          subtitle: '+5 poin',
          icon: Icons.local_florist_rounded,
          accent: Color(0xFFDFF3ED),
          iconColor: Color(0xFF63B8A2),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
              top: 180,
              right: -70,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _greenSoft.withOpacity(0.28),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -70,
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _pinkSoft.withOpacity(0.35),
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
                    child: _buildHeroCard(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildWeekProgressCard(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildFreezeCard(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: _buildBadgeCard(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                    child: _buildHistoryCard(context),
                  ),
                ),
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
              color: Colors.white.withOpacity(0.72),
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
            'Detail Streak',
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFFFE4E8),
            ),
            child: const Icon(
              Icons.local_fire_department_rounded,
              size: 34,
              color: Color(0xFFE58696),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Streak aktif',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentStreak hari',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 34,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Kamu sedang menjaga ritme yang baik. Tidak sempurna, tapi konsisten.',
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

  Widget _buildWeekProgressCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progress Minggu Ini',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Lihat ritme harianmu selama 7 hari terakhir.',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              height: 1.45,
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _days.map((day) => _buildDayDot(context, day)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDayDot(BuildContext context, _DayProgress day) {
    final textTheme = Theme.of(context).textTheme;

    Color fill;
    IconData icon;

    if (day.isToday) {
      fill = _pink;
      icon = Icons.more_horiz_rounded;
    } else if (day.isFreezeUsed) {
      fill = const Color(0xFFDFF3ED);
      icon = Icons.favorite_rounded;
    } else if (day.isDone) {
      fill = _green;
      icon = Icons.check_rounded;
    } else {
      fill = const Color(0xFFE7E7E1);
      icon = Icons.close_rounded;
    }

    return Column(
      children: [
        Container(
          width: day.isToday ? 46 : 40,
          height: day.isToday ? 46 : 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: fill,
            boxShadow: _softShadow,
            border: day.isToday
                ? Border.all(color: Colors.white, width: 2)
                : null,
          ),
          child: Icon(
            icon,
            size: 18,
            color: day.isToday ? Colors.white : _textDark,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          day.label,
          style: textTheme.bodySmall?.copyWith(
            fontSize: 11,
            color: _textDark,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildFreezeCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Freeze Streak',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
            decoration: BoxDecoration(
              color: _greenSoft,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                  ),
                  child: const Icon(
                    Icons.favorite_rounded,
                    color: _green,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Proteksi aktif',
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sisa $freezeOwned dari $freezeMax freeze',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: _textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: true,
                  activeColor: _green,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            freezeEnabled ? 'Proteksi aktif' : 'Proteksi tidak aktif',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              height: 1.45,
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Milestone Badge',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MiniBadge(label: '3 hari', title: 'Mulai Konsisten', unlocked: currentStreak >= 3),
              _MiniBadge(label: '7 hari', title: 'Teman Diri Sendiri', unlocked: currentStreak >= 7),
              _MiniBadge(label: '14 hari', title: 'Tumbuh Pelan-Pelan', unlocked: currentStreak >= 14),
              _MiniBadge(label: '30 hari', title: 'Menjaga Diri dengan Setia', unlocked: currentStreak >= 30),
              _MiniBadge(label: '120 hari', title: 'Tumbuh dengan Tenang', unlocked: currentStreak >= 120),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Riwayat Hari Ini',
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ..._history.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == _history.last ? 0 : 10,
              ),
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: item.accent,
                    width: 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: item.accent,
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item.title,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.subtitle,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: _green,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayProgress {
  final String label;
  final bool isDone;
  final bool isFreezeUsed;
  final bool isToday;

  const _DayProgress({
    required this.label,
    this.isDone = false,
    this.isFreezeUsed = false,
    this.isToday = false,
  });
}

class _HistoryItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color iconColor;

  const _HistoryItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.iconColor,
  });
}

class _MiniBadge extends StatelessWidget {
  final String label;
  final String title;
  final bool unlocked;

  const _MiniBadge({
    required this.label,
    required this.title,
    required this.unlocked,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 145,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: unlocked ? const Color(0xFFFFF0F4) : const Color(0xFFF1F1F1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: unlocked ? const Color(0xFFF3B6BF) : const Color(0xFFD9D9D9),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: unlocked ? const Color(0xFFE58696) : const Color(0xFF9C9C9C),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: unlocked ? const Color(0xFFFFD8DF) : const Color(0xFFE0E0E0),
            ),
            child: Icon(
              unlocked ? Icons.workspace_premium_rounded : Icons.question_mark_rounded,
              color: unlocked ? const Color(0xFFE58696) : const Color(0xFF9C9C9C),
              size: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            unlocked ? title : 'Belum terbuka',
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: unlocked ? const Color(0xFF2A2A2A) : const Color(0xFF9C9C9C),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}