import 'package:flutter/material.dart';

import '../setting/moodly_settings_support.dart';

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
  static const Color _textDark = Color(0xFF222222);
  static const Color _textSoft = Color(0xFF6F7A67);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Detail Streak',
      'activeStreak': 'Streak aktif',
      'heroBody':
          'Kamu sedang menjaga ritme yang baik. Tidak sempurna, tapi konsisten.',
      'weekProgress': 'Progress Minggu Ini',
      'weekProgressBody': 'Lihat ritme harianmu selama 7 hari terakhir.',
      'freezeTitle': 'Freeze Streak',
      'freezeActive': 'Proteksi aktif',
      'freezeInactive': 'Proteksi tidak aktif',
      'freezeRemaining': 'Sisa {owned} dari {max} freeze',
      'badgeTitle': 'Milestone Badge',
      'todayHistory': 'Riwayat Hari Ini',
      'days': 'hari',
      'notUnlocked': 'Belum terbuka',
      'historyMood': 'Mood hari ini selesai',
      'historyCombo': 'Bonus combo harian',
      'historyAffirmation': 'Afirmasi dibaca',
    },
    'en': {
      'header': 'Streak Detail',
      'activeStreak': 'Active streak',
      'heroBody':
          'You are maintaining a good rhythm. Not perfect, but consistent.',
      'weekProgress': 'This Week\'s Progress',
      'weekProgressBody': 'See your daily rhythm over the last 7 days.',
      'freezeTitle': 'Streak Freeze',
      'freezeActive': 'Protection active',
      'freezeInactive': 'Protection inactive',
      'freezeRemaining': '{owned} of {max} freezes left',
      'badgeTitle': 'Milestone Badge',
      'todayHistory': 'Today\'s History',
      'days': 'days',
      'notUnlocked': 'Locked',
      'historyMood': 'Today\'s mood completed',
      'historyCombo': 'Daily combo bonus',
      'historyAffirmation': 'Affirmation read',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  String _template(
    String languageCode,
    String key,
    Map<String, String> vars,
  ) {
    var text = _t(languageCode, key);
    vars.forEach((k, v) {
      text = text.replaceAll('{$k}', v);
    });
    return text;
  }

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  List<_DayProgress> _days(String languageCode) => [
        _DayProgress(label: _dayLabel(languageCode, 0), isDone: true),
        _DayProgress(label: _dayLabel(languageCode, 1), isDone: true),
        _DayProgress(label: _dayLabel(languageCode, 2), isDone: true),
        _DayProgress(
          label: _dayLabel(languageCode, 3),
          isDone: false,
          isFreezeUsed: true,
        ),
        _DayProgress(label: _dayLabel(languageCode, 4), isDone: true),
        _DayProgress(label: _dayLabel(languageCode, 5), isDone: true),
        _DayProgress(label: _dayLabel(languageCode, 6), isToday: true),
      ];

  List<_HistoryItem> _history(String languageCode) => [
        _HistoryItem(
          title: _t(languageCode, 'historyMood'),
          subtitle:
              languageCode == 'en' ? '+10 points' : '+10 poin',
          icon: Icons.sentiment_satisfied_alt_rounded,
          accent: const Color(0xFFF8D3D9),
          iconColor: const Color(0xFFE58696),
        ),
        _HistoryItem(
          title: _t(languageCode, 'historyCombo'),
          subtitle:
              languageCode == 'en' ? '+5 points' : '+5 poin',
          icon: Icons.auto_awesome_rounded,
          accent: const Color(0xFFFFEEF1),
          iconColor: const Color(0xFFE58696),
        ),
        _HistoryItem(
          title: _t(languageCode, 'historyAffirmation'),
          subtitle:
              languageCode == 'en' ? '+5 points' : '+5 poin',
          icon: Icons.local_florist_rounded,
          accent: const Color(0xFFDFF3ED),
          iconColor: const Color(0xFF63B8A2),
        ),
      ];

  String _dayLabel(String languageCode, int index) {
    const id = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
    const en = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return languageCode == 'en' ? en[index] : id[index];
  }

  String _badgeTitle(String languageCode, int day) {
    switch (day) {
      case 3:
        return languageCode == 'en'
            ? 'Starting to Be Consistent'
            : 'Mulai Konsisten';
      case 7:
        return languageCode == 'en'
            ? 'A Friend to Yourself'
            : 'Teman Diri Sendiri';
      case 14:
        return languageCode == 'en'
            ? 'Growing Slowly'
            : 'Tumbuh Pelan-Pelan';
      case 30:
        return languageCode == 'en'
            ? 'Caring for Yourself Faithfully'
            : 'Menjaga Diri dengan Setia';
      case 120:
        return languageCode == 'en'
            ? 'Growing Calmly'
            : 'Tumbuh dengan Tenang';
      default:
        return _t(languageCode, 'notUnlocked');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: MoodlySettingsPrefs.languageNotifier,
      builder: (context, languageCode, _) {
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
                        child: _buildHeader(context, languageCode),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildHeroCard(context, languageCode),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildWeekProgressCard(context, languageCode),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildFreezeCard(context, languageCode),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: _buildBadgeCard(context, languageCode),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 28),
                        child: _buildHistoryCard(context, languageCode),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, String languageCode) {
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
            _t(languageCode, 'header'),
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context, String languageCode) {
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
                  _t(languageCode, 'activeStreak'),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currentStreak ${_t(languageCode, 'days')}',
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 34,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _t(languageCode, 'heroBody'),
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

  Widget _buildWeekProgressCard(BuildContext context, String languageCode) {
    final textTheme = Theme.of(context).textTheme;
    final days = _days(languageCode);

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
            _t(languageCode, 'weekProgress'),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _t(languageCode, 'weekProgressBody'),
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
            children: days.map((day) => _buildDayDot(context, day)).toList(),
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

  Widget _buildFreezeCard(BuildContext context, String languageCode) {
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
            _t(languageCode, 'freezeTitle'),
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
                        _t(languageCode, 'freezeActive'),
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _template(
                          languageCode,
                          'freezeRemaining',
                          {
                            'owned': '$freezeOwned',
                            'max': '$freezeMax',
                          },
                        ),
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
                  value: freezeEnabled,
                  activeColor: _green,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            freezeEnabled
                ? _t(languageCode, 'freezeActive')
                : _t(languageCode, 'freezeInactive'),
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

  Widget _buildBadgeCard(BuildContext context, String languageCode) {
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
            _t(languageCode, 'badgeTitle'),
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
              _MiniBadge(
                label: '3 ${_t(languageCode, 'days')}',
                title: _badgeTitle(languageCode, 3),
                unlocked: currentStreak >= 3,
                lockedLabel: _t(languageCode, 'notUnlocked'),
              ),
              _MiniBadge(
                label: '7 ${_t(languageCode, 'days')}',
                title: _badgeTitle(languageCode, 7),
                unlocked: currentStreak >= 7,
                lockedLabel: _t(languageCode, 'notUnlocked'),
              ),
              _MiniBadge(
                label: '14 ${_t(languageCode, 'days')}',
                title: _badgeTitle(languageCode, 14),
                unlocked: currentStreak >= 14,
                lockedLabel: _t(languageCode, 'notUnlocked'),
              ),
              _MiniBadge(
                label: '30 ${_t(languageCode, 'days')}',
                title: _badgeTitle(languageCode, 30),
                unlocked: currentStreak >= 30,
                lockedLabel: _t(languageCode, 'notUnlocked'),
              ),
              _MiniBadge(
                label: '120 ${_t(languageCode, 'days')}',
                title: _badgeTitle(languageCode, 120),
                unlocked: currentStreak >= 120,
                lockedLabel: _t(languageCode, 'notUnlocked'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(BuildContext context, String languageCode) {
    final textTheme = Theme.of(context).textTheme;
    final history = _history(languageCode);

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
            _t(languageCode, 'todayHistory'),
            style: textTheme.titleMedium?.copyWith(
              fontSize: 18,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...history.map(
            (item) => Padding(
              padding: EdgeInsets.only(
                bottom: item == history.last ? 0 : 10,
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
  final String lockedLabel;

  const _MiniBadge({
    required this.label,
    required this.title,
    required this.unlocked,
    required this.lockedLabel,
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
          color: unlocked
              ? const Color(0xFFF5C6D0)
              : const Color(0xFFE1E1E1),
          width: 1.1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: const Color(0xFF6F7A67),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unlocked ? title : lockedLabel,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: const Color(0xFF222222),
              fontWeight: FontWeight.w800,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}