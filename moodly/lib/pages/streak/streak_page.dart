import '../../core/services/premium_service.dart';
import 'package:flutter/material.dart';
import 'package:moodly/core/services/reward_service.dart';
import 'reward_page.dart';
import '../../widgets/streak/streak_feedback_popup.dart';
import 'streak_detail_page.dart';
import '../../core/services/streak_service.dart';
import '../setting/moodly_settings_support.dart';
import '../afirmasi/afirmasi.dart';

class StreakPage extends StatelessWidget {
  const StreakPage({super.key});

  static const Color _bg = Color(0xFFF3FADC);
  static const Color _card = Color(0xFFFFFDF9);
  static const Color _green = Color(0xFF84C76A);
  static const Color _greenSoft = Color(0xFFDDF0C7);
  static const Color _greenPastel = Color(0xFFEAF6DA);
  static const Color _pink = Color(0xFFF6BDC4);
  static const Color _pinkSoft = Color(0xFFFFEEF1);
  static const Color _mint = Color(0xFFCDEEE7);
  static const Color _mintSoft = Color(0xFFEFFAF7);
  static const Color _textDark = Color(0xFF222222);
  static const Color _textSoft = Color(0xFF6F7A67);
  
  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'pageTitle': 'Streak',
      'activeStreak': 'Streak aktifmu',
      'pointsAndRewards': 'Poin & Hadiah',
      'dailyMission': 'Misi Hari Ini',
      'dailyStreak': 'Streak Harian',
      'freezeTitle': 'Freeze Streak',
      'rewardLabel': 'Hadiah',
      'exchangePremium': 'Tukar Premium',
      'exchangeGift': 'Tukar Hadiah',
      'noBadge': 'Belum ada badge',
    },
    'en': {
      'pageTitle': 'Streak',
      'activeStreak': 'Your active streak',
      'pointsAndRewards': 'Points & Rewards',
      'dailyMission': 'Today\'s Missions',
      'dailyStreak': 'Daily Streak',
      'freezeTitle': 'Streak Freeze',
      'rewardLabel': 'Rewards',
      'exchangePremium': 'Redeem Premium',
      'exchangeGift': 'Redeem Reward',
      'noBadge': 'No badge yet',
    },
  };

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  String get _lang =>
    MoodlySettingsPrefs.currentLanguageCode == 'en' ? 'en' : 'id';

  String _text(String idText, String enText) {
    return _lang == 'en' ? enText : idText;
  }

  String _daysWord() => _lang == 'en' ? 'days' : 'hari';

  static final GlobalKey _walkStreakKey = GlobalKey();
  static final GlobalKey _walkFreezeKey = GlobalKey();
  static final GlobalKey _walkMissionKey = GlobalKey();
  static final GlobalKey _walkRewardKey = GlobalKey();

  static bool _badgeSyncBusy = false;

  static const List<String> _badgeOrder = [
    'milestone_3',
    'milestone_7',
    'milestone_14',
    'milestone_30',
    'milestone_120',
  ];

  static const Map<String, int> _badgeMilestoneDays = {
    'milestone_3': 3,
    'milestone_7': 7,
    'milestone_14': 14,
    'milestone_30': 30,
    'milestone_120': 120,
  };

  // ===== TEMPAT GANTI PEMETAAN BADGE ASLI DAN PLACEHOLDER =====
  // Ganti path di sini kalau nanti nama asset badge berubah.
  static const Map<String, String> _badgeUnlockedAssets = {
    'milestone_3': 'assets/streak_badges/3_hari.png',
    'milestone_7': 'assets/streak_badges/7_hari.png',
    'milestone_14': 'assets/streak_badges/14_hari.png',
    'milestone_30': 'assets/streak_badges/30_hari.png',
    'milestone_120': 'assets/streak_badges/120_hari.png',
  };

  static const Map<String, String> _badgeLockedAssets = {
    'milestone_3': 'assets/streak_badges/3_hari_qm.png',
    'milestone_7': 'assets/streak_badges/7_hari_qm.png',
    'milestone_14': 'assets/streak_badges/14_hari_qm.png',
    'milestone_30': 'assets/streak_badges/30_hari_qm.png',
    'milestone_120': 'assets/streak_badges/120_hari_qm.png',
  };

  List<BoxShadow> get _softShadow => const [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.10),
          offset: Offset(0, 3),
          blurRadius: 10,
          spreadRadius: 0,
        ),
      ];

  static const List<int> _milestones = [3, 7, 14, 30, 120];

  List<_RewardPreview> get _rewardPreviews => [
        _RewardPreview(
          title: _text('Avatar Anonim', 'Anonymous Avatar'),
          subtitle: _text('Mulai 120 poin', 'From 120 points'),
          icon: Icons.face_rounded,
          accent: const Color(0xFFF8D3D9),
          iconColor: const Color(0xFFE58696),
        ),
        _RewardPreview(
          title: _text('Bingkai Avatar', 'Avatar Frame'),
          subtitle: _text('Mulai 90 poin', 'From 90 points'),
          icon: Icons.auto_awesome_rounded,
          accent: const Color(0xFFE5F3D7),
          iconColor: const Color(0xFF74B55F),
        ),
        _RewardPreview(
          title: _text('Freeze Tambahan', 'Extra Freeze'),
          subtitle: _text('180 poin', '180 points'),
          icon: Icons.favorite_rounded,
          accent: const Color(0xFFDFF3ED),
          iconColor: const Color(0xFF63B8A2),
        ),
        _RewardPreview(
          title: _text('Premium 1 Bulan', '1 Month Premium'),
          subtitle: _text('3200 poin', '3200 points'),
          icon: Icons.workspace_premium_rounded,
          accent: const Color(0xFFF5EAFB),
          iconColor: const Color(0xFF9A76B3),
        ),
      ];

  List<_MissionSection> _buildSections(StreakState state) {
    final moodDailyCompleted = state.moodMissionCompletedCount;
    final diaryCompleted = state.diaryMissionCompletedCount;
    final affirmationCompleted = state.affirmationMissionCompletedCount;

    return [
      _MissionSection(
        title: 'Mood',
        pointsLabel:
            '+${StreakService.moodPoints + StreakService.moodInsightPoints}',
        progressLabel: '$moodDailyCompleted/2',
        accent: const Color(0xFFF6D2D7),
        accentSoft: const Color(0xFFFFF1F4),
        chipColor: const Color(0xFFF3B6BF),
        iconBg: const Color(0xFFFFFAFB),
        icon: Icons.sentiment_satisfied_alt_rounded,
        subtitle: _text(
          'Trigger utama streak harianmu',
          'The main trigger for your daily streak',
        ),
        footerLabel: state.moodDoneToday
            ? (state.moodInsightDoneThisMonth
                ? _text(
                    'Misi mood selesai • insight bulanan sudah terbuka',
                    'Mood mission completed • monthly insight already unlocked',
                  )
                : _text(
                    'Misi mood harian selesai',
                    'Daily mood mission completed',
                  ))
            : _text(
                'Misi mood aktif otomatis',
                'Mood mission is tracked automatically',
              ),
        footerIcon: state.moodDoneToday
            ? Icons.check_circle_rounded
            : Icons.timelapse_rounded,
        action: _MissionAction.mood,
        autoTracked: true,
        tasks: [
          _MissionTask(
            title: _text(
              'Isi mood hari ini (+${StreakService.moodPoints})',
              'Log today\'s mood (+${StreakService.moodPoints})',
            ),
            isDone: state.moodDoneToday,
          ),
          _MissionTask(
            title: _text(
              'Lihat insight bulanan (+${StreakService.moodInsightPoints})',
              'View monthly insight (+${StreakService.moodInsightPoints})',
            ),
            isDone: state.moodInsightDoneThisMonth,
          ),
        ],
      ),
      _MissionSection(
        title: _text('Diary Online', 'Online Diary'),
        pointsLabel:
            '+${StreakService.diaryPoints + StreakService.diaryInteractionPoints}',
        progressLabel: '$diaryCompleted/2',
        accent: const Color(0xFFE8F3D6),
        accentSoft: const Color(0xFFF8FDEB),
        chipColor: const Color(0xFFA9D78D),
        iconBg: const Color(0xFFFFFEFA),
        icon: Icons.eco_rounded,
        subtitle: _text(
          'Luapkan isi hati dengan lebih lega',
          'Let your feelings out more freely',
        ),
        footerLabel: diaryCompleted == 2
            ? _text(
                'Semua misi diary online selesai',
                'All online diary missions are completed',
              )
            : diaryCompleted == 1
                ? _text(
                    '1 dari 2 misi diary online selesai',
                    '1 of 2 online diary missions completed',
                  )
                : _text(
                    'Misi diary online aktif otomatis',
                    'Online diary missions are tracked automatically',
                  ),
        footerIcon: diaryCompleted == 2
            ? Icons.check_circle_rounded
            : Icons.timelapse_rounded,
        action: _MissionAction.diary,
        autoTracked: true,
        tasks: [
          _MissionTask(
            title: _text(
              'Tulis diary (+${StreakService.diaryPoints})',
              'Write a diary (+${StreakService.diaryPoints})',
            ),
            isDone: state.diaryDoneToday,
          ),
          _MissionTask(
            title: _text(
              'Berikan reaksi dan komentar pada diary publik seseorang (+${StreakService.diaryInteractionPoints})',
              'Give a reaction and comment on someone\'s public diary (+${StreakService.diaryInteractionPoints})',
            ),
            isDone: state.publicDiaryInteractionDoneToday,
          ),
        ],
      ),
      _MissionSection(
        title: _text('Afirmasi', 'Affirmation'),
        pointsLabel: '+${StreakService.affirmationPoints}',
        progressLabel: '$affirmationCompleted/2',
        accent: const Color(0xFFD6F0EA),
        accentSoft: const Color(0xFFF0FBF8),
        chipColor: const Color(0xFFA7DDD1),
        iconBg: const Color(0xFFFFFEFA),
        icon: Icons.local_florist_rounded,
        subtitle: _text(
          'Sempatkan jeda untuk menyapa dirimu',
          'Take a moment to gently check in with yourself',
        ),
        footerLabel: affirmationCompleted == 2
            ? _text(
                'Semua misi afirmasi selesai',
                'All affirmation missions are completed',
              )
            : affirmationCompleted == 1
                ? _text(
                    '1 dari 2 misi afirmasi selesai',
                    '1 of 2 affirmation missions completed',
                  )
                : _text(
                    'Misi afirmasi aktif otomatis',
                    'Affirmation mission is tracked automatically',
                  ),
        footerIcon: affirmationCompleted == 2
            ? Icons.check_circle_rounded
            : Icons.timelapse_rounded,
        action: _MissionAction.affirmation,
        autoTracked: true,
        tasks: [
          _MissionTask(
            title: _text(
              'Baca 5 afirmasi hari ini (${state.affirmationReadProgressToday}/5)',
              'Read 5 affirmations today (${state.affirmationReadProgressToday}/5)',
            ),
            isDone: state.affirmationReadDoneToday,
          ),
          _MissionTask(
            title: _text(
              'Bagikan 1 afirmasi',
              'Share 1 affirmation',
            ),
            isDone: state.affirmationSharedToday,
          ),
        ],
      ),
    ];
  }

  int _completedTodayCount(StreakState state) {
    return state.moodMissionCompletedCount +
        state.diaryMissionCompletedCount +
        state.affirmationMissionCompletedCount;
  }

  int _earnedTodayPoints(StreakState state) {
    int total = 0;
    if (state.moodDoneToday) total += StreakService.moodPoints;
    if (state.moodInsightClaimedToday) {
      total += StreakService.moodInsightPoints;
    }
    if (state.diaryDoneToday) total += StreakService.diaryPoints;
    if (state.publicDiaryInteractionClaimedToday) {
      total += StreakService.diaryInteractionPoints;
    }
    if (state.affirmationDoneToday) total += StreakService.affirmationPoints;
    if (state.comboDoneToday) total += _todayWeeklyBonus(state);
    if (state.adBonusClaimedToday) total += StreakService.adBonusPoints;
    return total;
  }

  int _todayWeeklyBonus(StreakState state) {
    final day = _activeWeeklyRewardDay(state);
    return StreakService.weeklyBonusForDay(day);
  }

  int _activeWeeklyRewardDay(StreakState state) {
    final claimedCount = _visibleWeeklyClaimedDays(state).length;

    if (claimedCount <= 0) return 1;
    if (claimedCount >= 7) return 1;

    return claimedCount + 1;
  }

  Set<int> _visibleWeeklyClaimedDays(StreakState state) {
    final claimed = state.weeklyRewardClaimedDays.toSet()
      ..removeWhere((day) => day < 1 || day > 7);
    return claimed;
  }

  bool _comboReady(StreakState state) {
    return state.moodMissionCompletedCount == 2 &&
        state.diaryMissionCompletedCount == 2 &&
        state.affirmationMissionCompletedCount == 2 &&
        !state.comboDoneToday;
  }

  int _nextMilestoneFor(int streak) {
    for (final m in _milestones) {
      if (streak < m) return m;
    }
    return _milestones.last;
  }

  int _currentMilestoneFor(int streak) {
    int current = 0;
    for (final m in _milestones) {
      if (streak >= m) current = m;
    }
    return current;
  }

  String _currentBadgeTitleFor(int streak) {
    if (streak >= 120) {
      return _text('Tumbuh dengan Tenang', 'Growing Calmly');
    }
    if (streak >= 30) {
      return _text(
        'Menjaga Diri dengan Setia',
        'Caring for Yourself Faithfully',
      );
    }
    if (streak >= 14) {
      return _text('Tumbuh Pelan-Pelan', 'Growing Slowly');
    }
    if (streak >= 7) {
      return _text('Teman Diri Sendiri', 'A Friend to Yourself');
    }
    if (streak >= 3) {
      return _text('Mulai Konsisten', 'Starting to Be Consistent');
    }
    return _t(_lang, 'noBadge');
  }

  String _nextBadgeTitleFor(int streak) {
    if (streak < 3) {
      return _text('Mulai Konsisten', 'Starting to Be Consistent');
    }
    if (streak < 7) {
      return _text('Teman Diri Sendiri', 'A Friend to Yourself');
    }
    if (streak < 14) {
      return _text('Tumbuh Pelan-Pelan', 'Growing Slowly');
    }
    if (streak < 30) {
      return _text(
        'Menjaga Diri dengan Setia',
        'Caring for Yourself Faithfully',
      );
    }
    if (streak < 120) {
      return _text('Tumbuh dengan Tenang', 'Growing Calmly');
    }
    return _text('Semua badge terbuka', 'All badges are unlocked');
  }

  String _badgeUnlockSubtitle(String badgeId) {
    switch (badgeId) {
      case 'milestone_3':
        return _text(
          'Tiga hari pertama selalu paling berat. Kamu berhasil lewatin.',
          'The first three days are usually the hardest. You made it through.',
        );
      case 'milestone_7':
        return _text(
          'Satu minggu hadir untuk diri sendiri. Itu bukan hal kecil.',
          'One full week of showing up for yourself. That is not a small thing.',
        );
      case 'milestone_14':
        return _text(
          'Dua minggu konsisten. Moodly bangga sama progresmu.',
          'Two weeks of consistency. Moodly is proud of your progress.',
        );
      case 'milestone_30':
        return _text(
          'Sebulan penuh kamu tetap kembali. Itu kuat banget.',
          'You kept coming back for a full month. That is real strength.',
        );
      case 'milestone_120':
        return _text(
          'Empat bulan konsisten. Ini pencapaian besar yang layak dirayakan.',
          'Four months of consistency. This is a big achievement worth celebrating.',
        );
      default:
        return _text(
          'Badge baru berhasil terbuka. Rayakan langkah kecilmu hari ini.',
          'A new badge has been unlocked. Celebrate your small step today.',
        );
    }
  }

  List<String> _eligibleBadgeIdsFor(int streak) {
    final result = <String>[];
    for (final badgeId in _badgeOrder) {
      final need = _badgeMilestoneDays[badgeId] ?? 999999;
      if (streak >= need) result.add(badgeId);
    }
    return result;
  }

  String? _currentBadgeIdFor(int streak) {
    final eligible = _eligibleBadgeIdsFor(streak);
    return eligible.isEmpty ? null : eligible.last;
  }

  Future<void> _syncUnlockedBadges(BuildContext context, StreakState state) async {
    if (_badgeSyncBusy) return;

    final eligible = _eligibleBadgeIdsFor(state.currentStreak);
    if (eligible.isEmpty) return;

    _badgeSyncBusy = true;
    try {
      final inventory = await RewardService.instance.getInventoryOnce();
      final claimed = Set<String>.from(inventory['claimedBadgeIds'] ?? []);
      final newBadges = eligible.where((e) => !claimed.contains(e)).toList();

      if (newBadges.isEmpty) return;

      await RewardService.instance.unlockBadges(newBadges);

      if (!context.mounted) return;
      _showBadgeUnlockedCelebration(context, newBadges.last);
    } finally {
      _badgeSyncBusy = false;
    }
  }

  Future<void> _handleMissionAction(
    BuildContext context,
    _MissionAction action,
  ) async {
    StreakClaimResult result;

    switch (action) {
      case _MissionAction.mood:
        result = await StreakService.instance.claimMoodCheckIn();
        break;
      case _MissionAction.diary:
        result = await StreakService.instance.claimDiaryBonus();
        break;
      case _MissionAction.affirmation:
        result = await StreakService.instance.claimAffirmationBonus();
        break;
    }

    if (!context.mounted) return;

    if (result.success) {
      IconData icon;
      Color accent;
      String title;

      switch (action) {
        case _MissionAction.mood:
          icon = Icons.local_fire_department_rounded;
          accent = const Color(0xFFE58696);
          title = _text('Mood berhasil dicatat', 'Mood logged successfully');
          break;
        case _MissionAction.diary:
          icon = Icons.eco_rounded;
          accent = const Color(0xFF74B55F);
          title = _text('Bonus diary berhasil', 'Diary bonus claimed');
          break;
        case _MissionAction.affirmation:
          icon = Icons.local_florist_rounded;
          accent = const Color(0xFF63B8A2);
          title = _text('Bonus afirmasi berhasil', 'Affirmation bonus claimed');
          break;
      }

      await showStreakFeedbackPopup(
        context,
        title: title,
        message: result.message,
        icon: icon,
        accent: accent,
        chipLabel: _lang == 'en'
            ? '+${result.pointsAdded} points'
            : '+${result.pointsAdded} poin',
        secondaryChipLabel:
            result.freezeUsed > 0
                ? _text(
                    '-${result.freezeUsed} freeze',
                    '-${result.freezeUsed} freeze',
                  )
                : null,
        buttonLabel: _text('Sip', 'Got it'),
      );
    } else {
      await showStreakFeedbackPopup(
        context,
        title: _text('Belum bisa diklaim', 'Cannot be claimed yet'),
        message: result.message,
        icon: Icons.info_outline_rounded,
        accent: const Color(0xFF9A76B3),
        buttonLabel: _text('Mengerti', 'Understood'),
      );
    }
  }

  Future<void> _handleComboTap(BuildContext context) async {
    final result = await StreakService.instance.claimComboBonus();

    if (!context.mounted) return;

    if (result.success) {
      await showStreakFeedbackPopup(
        context,
        title: _text('Bonus combo berhasil', 'Combo bonus claimed'),
        message: _text(
          'Semua syarat combo hari ini sudah terpenuhi. Bonus poin berhasil masuk.',
          'All combo requirements for today have been completed. Bonus points have been added.',
        ),
        icon: Icons.auto_awesome_rounded,
        accent: const Color(0xFFE58696),
        chipLabel: _lang == 'en'
            ? '+${result.pointsAdded} points'
            : '+${result.pointsAdded} poin',
        secondaryChipLabel: _text('Combo harian', 'Daily combo'),
        buttonLabel: _text('Yay', 'Yay'),
      );
    } else {
      await showStreakFeedbackPopup(
        context,
        title: _text('Combo belum siap', 'Combo is not ready yet'),
        message: _text(
          'Combo belum siap. Selesaikan mood, diary publik, dan afirmasi dulu.',
          'The combo is not ready yet. Complete mood, public diary, and affirmation first.',
        ),
        icon: Icons.auto_awesome_outlined,
        accent: const Color(0xFF9A76B3),
        buttonLabel: _text('Oke', 'Okay'),
      );
    }
  }

  Future<void> _showAdMissionInfo(BuildContext context, StreakState state) async {
    await showStreakFeedbackPopup(
      context,
      title: state.adBonusDoneToday
          ? _text('Bonus iklan sudah diklaim', 'Ad bonus already claimed')
          : _text('Misi iklan bonus', 'Bonus ad mission'),
      message: state.adBonusDoneToday
          ? _text(
              'Hari ini kamu sudah menyelesaikan misi bonus iklan dan mendapatkan +${StreakService.adBonusPoints} poin.',
              'Today you have completed the bonus ad mission and earned +${StreakService.adBonusPoints} points.',
            )
          : _text(
              'Tonton 2 rewarded ads di fitur afirmasi untuk membuka 5 slide tambahan. Setelah 2 iklan pertama hari ini, bonus +${StreakService.adBonusPoints} poin akan masuk otomatis.',
              'Watch 2 rewarded ads in the affirmation feature to unlock 5 additional slides. After the first 2 ads today, the +${StreakService.adBonusPoints} point bonus will be added automatically.',
            ),
      icon: Icons.ondemand_video_rounded,
      accent: const Color(0xFFE29A3A),
      buttonLabel: _text('Oke', 'Okay'),
    );
  }

  Future<void> _handleAdBonusTap(BuildContext context, StreakState state) async {
    if (state.adBonusDoneToday) {
      await _showAdMissionInfo(context, state);
      return;
    }

    if (!context.mounted) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AfirmasiPage(),
      ),
    );
  }

  void _showBadgeUnlockedCelebration(BuildContext context, String badgeId) {
    final asset = _badgeUnlockedAssets[badgeId];
    final title = switch (badgeId) {
      'milestone_3' => _text('Mulai Konsisten', 'Starting to Be Consistent'),
      'milestone_7' => _text('Teman Diri Sendiri', 'A Friend to Yourself'),
      'milestone_14' => _text('Tumbuh Pelan-Pelan', 'Growing Slowly'),
      'milestone_30' => _text(
          'Menjaga Diri dengan Setia',
          'Caring for Yourself Faithfully',
        ),
      'milestone_120' => _text('Tumbuh dengan Tenang', 'Growing Calmly'),
      _ => _text('Badge Baru', 'New Badge'),
    };
    final subtitle = _badgeUnlockSubtitle(badgeId);
    final textTheme = Theme.of(context).textTheme;

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Badge Unlock',
      barrierColor: Colors.black.withOpacity(0.74),
      transitionDuration: const Duration(milliseconds: 260),
      pageBuilder: (_, __, ___) {
        return Material(
          color: Colors.transparent,
          child: SafeArea(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    bottom: 150,
                    child: Container(
                      width: 260,
                      height: 150,
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFFFFF5B8).withOpacity(0.95),
                            const Color(0xFFFFE79E).withOpacity(0.55),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    top: 120,
                    left: 54,
                    child: _BadgeSparkle(
                      icon: Icons.auto_awesome_rounded,
                      size: 24,
                      color: Color(0xFFFFE38A),
                      angle: -0.18,
                    ),
                  ),
                  const Positioned(
                    top: 170,
                    right: 58,
                    child: _BadgeSparkle(
                      icon: Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFFFFC7D2),
                      angle: 0.2,
                    ),
                  ),
                  const Positioned(
                    bottom: 255,
                    left: 66,
                    child: _BadgeSparkle(
                      icon: Icons.star_rounded,
                      size: 16,
                      color: Color(0xFFFFF2B3),
                      angle: 0.0,
                    ),
                  ),
                  const Positioned(
                    bottom: 230,
                    right: 70,
                    child: _BadgeSparkle(
                      icon: Icons.star_rounded,
                      size: 14,
                      color: Color(0xFFFFDDE4),
                      angle: -0.1,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                    decoration: BoxDecoration(
                      color: _card,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: const Color(0xFFFFE8BE),
                        width: 1.3,
                      ),
                      boxShadow: [
                        ..._softShadow,
                        BoxShadow(
                          color: const Color(0xFFFFE7A6).withOpacity(0.22),
                          blurRadius: 28,
                          spreadRadius: 6,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 62,
                          height: 8,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5EEDC),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _text('Milestone badge baru!', 'New milestone badge!'),
                          textAlign: TextAlign.center,
                          style: textTheme.headlineLarge?.copyWith(
                            fontSize: 20,
                            height: 1.28,
                            color: _textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _text(
                            'Kamu berhasil membuka hadiah streak baru',
                            'You have unlocked a new streak reward',
                          ),
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            height: 1.45,
                            color: _textSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFFFFF7C7).withOpacity(0.95),
                                    const Color(0xFFFFE6A8).withOpacity(0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                            if (asset != null)
                              Image.asset(
                                asset,
                                width: 188,
                                fit: BoxFit.contain,
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium?.copyWith(
                            fontSize: 21,
                            color: _textDark,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            height: 1.5,
                            color: _textSoft,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.workspace_premium_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: Text(
                              _text('Lihat semua badge', 'See all badges'),
                              style: textTheme.labelLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack,
        );

        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.88, end: 1).animate(curved),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildProgressBar({
    required double value,
    required Color fillColor,
    Color bgColor = const Color(0xFFE8EEDF),
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(99),
      child: LinearProgressIndicator(
        minHeight: 10,
        value: value.clamp(0.0, 1.0).toDouble(),
        backgroundColor: bgColor,
        valueColor: AlwaysStoppedAnimation<Color>(fillColor),
      ),
    );
  }

  Rect _targetRectFromKey(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) return Rect.zero;
    final box = context.findRenderObject() as RenderBox;
    final offset = box.localToGlobal(Offset.zero);
    return offset & box.size;
  }

  Future<void> _scrollToKey(GlobalKey key) async {
    final context = key.currentContext;
    if (context == null) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOut,
      alignment: 0.16,
    );

    await Future.delayed(const Duration(milliseconds: 180));
  }

  void _showStreakWalkthrough(BuildContext context, StreakState state) {
    final steps = [
      _SpotlightStep(
        keyTarget: _walkStreakKey,
        title: _text('Streak Aktif', 'Active Streak'),
        desc: _text(
          'Angka ini naik saat kamu isi mood harian. Ini pemicu utamanya.',
          'This number goes up when you log your daily mood. It is the main trigger.',
        ),
      ),
      _SpotlightStep(
        keyTarget: _walkFreezeKey,
        title: _text('Freeze Streak', 'Streak Freeze'),
        desc: _text(
          'Freeze melindungi streak saat kamu bolong, sesuai mode proteksi yang kamu pilih.',
          'Freeze protects your streak when you miss a day, based on the protection mode you choose.',
        ),
      ),
      _SpotlightStep(
        keyTarget: _walkMissionKey,
        title: _text('Misi Harian', 'Daily Missions'),
        desc: _text(
          'Mood, diary, afirmasi, dan bonus combo memberimu poin tambahan.',
          'Mood, diary, affirmation, and combo bonuses give you extra points.',
        ),
      ),
      _SpotlightStep(
        keyTarget: _walkRewardKey,
        title: _text('Poin & Hadiah', 'Points & Rewards'),
        desc: _text(
          'Poin bisa ditukar untuk hadiah reguler atau premium.',
          'Points can be redeemed for regular or premium rewards.',
        ),
      ),
    ];

    int currentStep = 0;

    Future<void> goToStep(StateSetter setDialogState, int index) async {
      if (index < 0 || index >= steps.length) return;
      await _scrollToKey(steps[index].keyTarget);
      setDialogState(() {
        currentStep = index;
      });
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Walkthrough Streak',
      barrierColor: Colors.transparent,
      pageBuilder: (_, __, ___) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToKey(steps[currentStep].keyTarget);
            });

            final rect = _targetRectFromKey(steps[currentStep].keyTarget);

            return Material(
              color: Colors.transparent,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SpotlightPainter(
                        holeRect: rect.inflate(8),
                        borderRadius: 24,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 28,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
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
                            steps[currentStep].title,
                            style: Theme.of(context)
                                .textTheme
                                .headlineLarge
                                ?.copyWith(
                                  fontSize: 24,
                                  color: _textDark,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            steps[currentStep].desc,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: _textSoft,
                                  height: 1.5,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: List.generate(
                              steps.length,
                              (index) => Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(
                                    right: index == steps.length - 1 ? 0 : 6,
                                  ),
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: index <= currentStep
                                        ? _green
                                        : const Color(0xFFE5E9DB),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              if (currentStep > 0)
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => goToStep(
                                      setDialogState,
                                      currentStep - 1,
                                    ),
                                    child: Text(_text('Kembali', 'Back')),
                                  ),
                                ),
                              if (currentStep > 0) const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    if (currentStep == steps.length - 1) {
                                      Navigator.pop(context);
                                    } else {
                                      goToStep(setDialogState, currentStep + 1);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _green,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                  ),
                                  child: Text(
                                    currentStep == steps.length - 1
                                        ? _text('Selesai', 'Done')
                                        : _text('Lanjut', 'Next'),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showFreezeInfoSheet(BuildContext context, StreakState state) {
    bool previewEnabled = state.freezeEnabled;
    bool previewAutoUse = state.autoUseFreeze;

    String modalStatusLabel() {
      if (state.moodDoneToday) {
        return _text('Hari ini aman', 'Today is safe');
      }
      if ((previewEnabled || previewAutoUse) && state.freezeOwned > 0) {
        return _text('Freeze siap melindungi', 'Freeze is ready to protect');
      }
      return _text('Besok streak rawan putus', 'Your streak is at risk tomorrow');
    }

    Color modalStatusBg() {
      if (state.moodDoneToday) return _greenPastel;
      if ((previewEnabled || previewAutoUse) && state.freezeOwned > 0) {
        return const Color(0xFFFFF0D9);
      }
      return const Color(0xFFFFE6EA);
    }

    Color modalStatusBorder() {
      if (state.moodDoneToday) return const Color(0xFFB8E0A7);
      if ((previewEnabled || previewAutoUse) && state.freezeOwned > 0) {
        return const Color(0xFFE7B35C);
      }
      return const Color(0xFFE48A98);
    }

    IconData modalStatusIcon() {
      if (state.moodDoneToday) return Icons.check_circle_rounded;
      if ((previewEnabled || previewAutoUse) && state.freezeOwned > 0) {
        return Icons.shield_moon_rounded;
      }
      return Icons.warning_amber_rounded;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final textTheme = Theme.of(context).textTheme;

            return Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: _softShadow,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E7E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _t(_lang, 'freezeTitle'),
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _text(
                        'Freeze melindungi streak-mu saat kamu bolong. Kamu bisa memilih mode proteksi aktif atau pakai otomatis.',
                        'Freeze protects your streak when you miss a day. You can choose active protection mode or automatic use.',
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: _textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: _greenPastel,
                        borderRadius: BorderRadius.circular(20),
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
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  previewEnabled
                                      ? _text(
                                          'Proteksi sedang aktif',
                                          'Protection is active',
                                        )
                                      : _text(
                                          'Proteksi belum aktif',
                                          'Protection is inactive',
                                        ),
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontSize: 13,
                                    color: _textDark,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _text(
                                    'Sisa freeze: ${state.freezeOwned}/${state.freezeMax} hari',
                                    'Remaining freeze: ${state.freezeOwned}/${state.freezeMax} days',
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
                            value: previewEnabled,
                            activeColor: _green,
                            onChanged: (value) async {
                              setModalState(() {
                                previewEnabled = value;
                                if (!value) {
                                  previewAutoUse = false;
                                }
                              });

                              await StreakService.instance.toggleFreeze(value);
                              if (!value) {
                                await StreakService.instance.toggleAutoUseFreeze(
                                  false,
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                      decoration: BoxDecoration(
                        color: _pinkSoft,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        _text(
                          'Starter dapat 1 freeze. Full streak 1 bulan memberi +3 freeze. Premium memberi +2 freeze. Maksimum simpan freeze: ${state.freezeMax} hari.',
                          'Starter gets 1 freeze. A full 1-month streak gives +3 freezes. Premium gives +2 freezes. Maximum stored freezes: ${state.freezeMax} days.',
                        ),
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          height: 1.45,
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final next = !previewAutoUse;
                              setModalState(() {
                                previewAutoUse = next;
                                if (next) {
                                  previewEnabled = true;
                                }
                              });

                              await StreakService.instance.toggleAutoUseFreeze(
                                next,
                              );
                              if (next) {
                                await StreakService.instance.toggleFreeze(true);
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                              decoration: BoxDecoration(
                                color: previewAutoUse
                                    ? const Color(0xFFF4F0FA)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFF9A76B3),
                                  width: 1.3,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    previewAutoUse
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: const Color(0xFF9A76B3),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _text('Pakai Otomatis', 'Use Automatically'),
                                      style: textTheme.bodySmall?.copyWith(
                                        fontSize: 11,
                                        color: _textDark,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                            decoration: BoxDecoration(
                              color: modalStatusBg(),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: modalStatusBorder(),
                                width: 1.3,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  modalStatusIcon(),
                                  color: modalStatusBorder(),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    modalStatusLabel(),
                                    style: textTheme.bodySmall?.copyWith(
                                      fontSize: 11,
                                      color: _textDark,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
      },
    );
  }

  void _showMilestoneSheet(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StreamBuilder<Map<String, dynamic>>(
          stream: RewardService.instance.watchInventory(),
          builder: (context, snapshot) {
            final inventory = snapshot.data ?? {};
            final claimedBadgeIds = Set<String>.from(
              inventory['claimedBadgeIds'] ?? [],
            );
            final currentBadgeId = _currentBadgeIdFor(state.currentStreak);
            final nextMilestone = _nextMilestoneFor(state.currentStreak);
            final nextBadge = _nextBadgeTitleFor(state.currentStreak);
            final progressValue = state.currentStreak >= _milestones.last
                ? 1.0
                : (state.currentStreak / nextMilestone).clamp(0.0, 1.0).toDouble();

            Widget badgeCard(String badgeId) {
              final unlocked = claimedBadgeIds.contains(badgeId);
              final asset = unlocked
                  ? _badgeUnlockedAssets[badgeId]
                  : _badgeLockedAssets[badgeId];

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: unlocked ? _mintSoft : const Color(0xFFF7F7F5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Image.asset(
                  asset!,
                  fit: BoxFit.contain,
                  height: 138,
                ),
              );
            }

            return Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                color: _card,
                borderRadius: BorderRadius.circular(28),
                boxShadow: _softShadow,
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE7E7E1),
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _text('Badge Milestone', 'Milestone Badge'),
                      style: textTheme.headlineLarge?.copyWith(
                        fontSize: 24,
                        color: _textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _text(
                        'Semakin konsisten kamu hadir untuk dirimu sendiri, semakin banyak badge yang bisa dibuka.',
                        'The more consistently you show up for yourself, the more badges you can unlock.',
                      ),
                      style: textTheme.bodyMedium?.copyWith(
                        fontSize: 13,
                        height: 1.5,
                        color: _textSoft,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.92,
                      children: [
                        badgeCard('milestone_3'),
                        badgeCard('milestone_7'),
                        badgeCard('milestone_14'),
                        badgeCard('milestone_30'),
                        badgeCard('milestone_120'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                      decoration: BoxDecoration(
                        color: _greenPastel,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _text('Badge aktif saat ini', 'Current active badge'),
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: _textSoft,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currentBadgeId == null
                                ? _t(_lang, 'noBadge')
                                : _currentBadgeTitleFor(state.currentStreak),
                            style: textTheme.titleMedium?.copyWith(
                              fontSize: 18,
                              color: _textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            state.currentStreak >= _milestones.last
                                ? _text(
                                    'Semua badge sudah terbuka',
                                    'All badges are unlocked',
                                  )
                                : _text(
                                    'Badge berikutnya: $nextBadge',
                                    'Next badge: $nextBadge',
                                  ),
                            style: textTheme.bodyMedium?.copyWith(
                              fontSize: 12,
                              color: _textDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          _buildProgressBar(
                            value: progressValue,
                            fillColor: _green,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.currentStreak >= _milestones.last
                                ? _text(
                                    'Kamu sudah menuntaskan semua milestone badge.',
                                    'You have completed all milestone badges.',
                                  )
                                : _text(
                                    '${(nextMilestone - state.currentStreak).clamp(0, 9999)} hari lagi untuk membuka badge berikutnya',
                                    '${(nextMilestone - state.currentStreak).clamp(0, 9999)} days left to unlock the next badge',
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, StreakState state) {
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
            _t(_lang, 'pageTitle'),
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 28,
              color: _textDark,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => _showStreakWalkthrough(context, state),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.72),
              shape: BoxShape.circle,
              boxShadow: _softShadow,
            ),
            child: const Icon(
              Icons.question_mark_rounded,
              size: 20,
              color: _textDark,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopInfoChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    Color textColor = _textDark,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: iconColor),
            const SizedBox(width: 7),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: textColor,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.open_in_new_rounded,
                size: 14,
                color: textColor.withOpacity(0.72),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _green,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _softShadow,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              label,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    final nextMilestone = _nextMilestoneFor(state.currentStreak);
    final currentMilestone = _currentMilestoneFor(state.currentStreak);
    final milestoneProgress = nextMilestone == 0
        ? 1.0
        : state.currentStreak / nextMilestone;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _t(_lang, 'activeStreak'),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _buildSummaryActionButton(
                context,
                label: _t(_lang, 'rewardLabel'),
                icon: Icons.redeem_rounded,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RewardPage(totalPoints: state.totalPoints),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${state.currentStreak}',
                style: textTheme.headlineLarge?.copyWith(
                  fontSize: 42,
                  height: 1,
                  color: _textDark,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '${_daysWord()} 🔥',
                  style: textTheme.titleMedium?.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              'Kamu sudah konsisten menjaga dirimu dengan baik. Pelan-pelan, tapi kuat.',
              'You have been consistently taking good care of yourself. Slow, but strong.',
            ),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.55,
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildTopInfoChip(
                context,
                icon: Icons.stars_rounded,
                label: _lang == 'en'
                    ? '${state.totalPoints} points'
                    : '${state.totalPoints} poin',
                bgColor: _pinkSoft,
                iconColor: const Color(0xFFE58696),
              ),
              KeyedSubtree(
                key: _walkFreezeKey,
                child: _buildTopInfoChip(
                  context,
                  icon: state.freezeEnabled
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  label: state.freezeEnabled
                      ? _text(
                          'Freeze aktif ${state.freezeOwned}/${state.freezeMax}',
                          'Freeze active ${state.freezeOwned}/${state.freezeMax}',
                        )
                      : _text(
                          'Freeze nonaktif ${state.freezeOwned}/${state.freezeMax}',
                          'Freeze inactive ${state.freezeOwned}/${state.freezeMax}',
                        ),
                  bgColor: _greenPastel,
                  iconColor: _green,
                  onTap: () => _showFreezeInfoSheet(context, state),
                ),
              ),
              _buildTopInfoChip(
                context,
                icon: Icons.workspace_premium_rounded,
                label: _text(
                  'Menuju $nextMilestone hari',
                  '$nextMilestone days to go',
                ),
                bgColor: const Color(0xFFF4F0FA),
                iconColor: const Color(0xFF9A76B3),
                onTap: () => _showMilestoneSheet(context, state),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => StreakDetailPage(
                    currentStreak: state.currentStreak,
                    freezeEnabled: state.freezeEnabled,
                    freezeOwned: state.freezeOwned,
                    freezeMax: state.freezeMax,
                  ),
                ),
              );
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              decoration: BoxDecoration(
                color: _greenPastel,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _text(
                          'Progres ke milestone berikutnya',
                          'Progress to the next milestone',
                        ),
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: _textSoft,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${state.currentStreak}/$nextMilestone ${_daysWord()}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  _buildProgressBar(
                    value: milestoneProgress.clamp(0.0, 1.0).toDouble(),
                    fillColor: _green,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _text(
                      '${(nextMilestone - state.currentStreak).clamp(0, 9999)} hari lagi untuk membuka badge baru',
                      '${(nextMilestone - state.currentStreak).clamp(0, 9999)} days left to unlock a new badge',
                    ),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: _textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    currentMilestone == 0
                        ? _text(
                            'Badge pertamamu akan terbuka di hari ke-3',
                            'Your first badge will unlock on day 3',
                          )
                        : _text(
                            'Badge aktif: ${_currentBadgeTitleFor(state.currentStreak)}',
                            'Active badge: ${_currentBadgeTitleFor(state.currentStreak)}',
                          ),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: _textSoft,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _buildWeeklyRewardsGrid(context, state),
        ],
      ),
    );
  }

  Widget _buildWeeklyRewardsGrid(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    final claimedDays = _visibleWeeklyClaimedDays(state);
    final activeDay = _activeWeeklyRewardDay(state);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
      decoration: BoxDecoration(
        color: _greenPastel,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                _text('Progres Mingguan', 'Weekly Progress'),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: _textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _text('7 hari streak', '7-day streak'),
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: _textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              final day = index + 1;
              final isClaimed = claimedDays.contains(day);
              final isActive = !isClaimed && activeDay == day;
              final rewardLabel = '+${StreakService.weeklyBonusForDay(day)}';

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: Column(
                    children: [
                      Text(
                        'H$day',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 10,
                          color: _textDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: isActive ? 40 : 36,
                        height: isActive ? 40 : 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isClaimed
                              ? _green
                              : (isActive ? _pink : _pink.withOpacity(0.72)),
                          boxShadow: _softShadow,
                          border: isActive
                              ? Border.all(color: Colors.white, width: 2)
                              : null,
                        ),
                        child: Center(
                          child: isClaimed
                              ? const Icon(
                                  Icons.check_rounded,
                                  size: 18,
                                  color: Colors.white,
                                )
                              : Text(
                                  rewardLabel,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontSize: 10,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionInfoChip(
    BuildContext context, {
    required String label,
    required Color bgColor,
    required Color textColor,
    IconData? icon,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: textColor),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboBanner(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    final comboReady = _comboReady(state);

    return GestureDetector(
      onTap: () => _handleComboTap(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFFFF0F3),
              Color(0xFFEFF8E5),
            ],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFFD6DE),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Color(0xFFE58696),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.comboDoneToday
                    ? _text(
                        'Bonus combo hari ini sudah berhasil diklaim 🌷',
                        'Today\'s combo bonus has already been claimed 🌷',
                      )
                    : comboReady
                        ? _text(
                            'Mood, diary, dan afirmasi sudah lengkap. Tekan untuk klaim bonus combo hari ini.',
                            'Mood, diary, and affirmation are complete. Tap to claim today\'s combo bonus.',
                          )
                        : _text(
                            'Selesaikan Mood + Diary + Afirmasi untuk membuka bonus combo hari ini.',
                            'Complete Mood + Diary + Affirmation to unlock today\'s combo bonus.',
                          ),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  height: 1.45,
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdBonusBanner(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    final progress = state.adWatchProgressToday;
    final done = state.adBonusDoneToday;

    return GestureDetector(
      onTap: () => _handleAdBonusTap(context, state),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: done ? const Color(0xFFEAF6DA) : const Color(0xFFFFF4E7),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: done ? const Color(0xFF9FD27D) : const Color(0xFFE7B35C),
            width: 1.1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              done ? Icons.check_circle_rounded : Icons.ondemand_video_rounded,
              color: done ? _green : const Color(0xFFE29A3A),
              size: 18,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                done
                    ? _text(
                        'Misi iklan bonus selesai • +${StreakService.adBonusPoints} poin sudah masuk',
                        'Bonus ad mission completed • +${StreakService.adBonusPoints} points have been added',
                      )
                    : _text(
                        'Misi iklan bonus $progress/${StreakService.adBonusTargetViews} • tonton 2 iklan di afirmasi untuk bonus +${StreakService.adBonusPoints} poin',
                        'Bonus ad mission $progress/${StreakService.adBonusTargetViews} • watch 2 ads in affirmation to get +${StreakService.adBonusPoints} points',
                      ),
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  height: 1.45,
                  color: _textDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissionHeader(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    const totalTasks = 6;
    final completed = _completedTodayCount(state);
    final progress = completed / totalTasks;
    final todayPoints = _earnedTodayPoints(state);

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
          Row(
            children: [
              Expanded(
                child: Text(
                  _t(_lang, 'dailyMission'),
                  style: textTheme.headlineLarge?.copyWith(
                    fontSize: 26,
                    color: _textDark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0EE),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _t(_lang, 'dailyStreak'),
                  style: textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                    color: _textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              'Sedikit langkah hari ini tetap berarti. Lakukan pelan-pelan, satu misi demi satu.',
              'Even a small step today still matters. Take it slowly, one mission at a time.',
            ),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildMissionInfoChip(
                  context,
                  label: _text(
                    '$completed/$totalTasks selesai',
                    '$completed/$totalTasks completed',
                  ),
                  bgColor: _greenPastel,
                  textColor: _textDark,
                  icon: Icons.check_circle_rounded,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMissionInfoChip(
                  context,
                  label: _lang == 'en'
                      ? '+$todayPoints points today'
                      : '+$todayPoints poin hari ini',
                  bgColor: _pinkSoft,
                  textColor: const Color(0xFFE58696),
                  icon: Icons.stars_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Text(
                  _text('Progres harian', 'Daily progress'),
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: _textSoft,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 12,
                  color: _textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildProgressBar(
            value: progress,
            fillColor: _green,
          ),
          const SizedBox(height: 14),
          _buildComboBanner(context, state),
          FutureBuilder<bool>(
            future: PremiumService.instance.hasActivePremium(),
            builder: (context, snapshot) {
              final isPremiumUser = snapshot.data ?? false;

              if (isPremiumUser) {
                return const SizedBox.shrink();
              }

              return Column(
                children: [
                  const SizedBox(height: 12),
                  _buildAdBonusBanner(context, state),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTaskTile(BuildContext context, _MissionTask task) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.90),
        borderRadius: BorderRadius.circular(16),
        boxShadow: _softShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              task.title,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 12,
                color: _textDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            task.isDone
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: task.isDone ? _green : const Color(0xFFD8D8D2),
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(
    BuildContext context,
    _MissionSection section,
    StreakState state,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            right: -22,
            bottom: -18,
            child: Icon(
              section.icon,
              size: 120,
              color: Colors.white.withOpacity(0.16),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: section.chipColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      section.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                        color: _textDark,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Text(
                          section.pointsLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: _green,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          section.progressLabel,
                          style: textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                            color: _textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                section.subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  height: 1.45,
                  color: _textSoft,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                decoration: BoxDecoration(
                  color: section.accentSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: section.accent.withOpacity(0.95),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: section.iconBg,
                        shape: BoxShape.circle,
                        boxShadow: _softShadow,
                      ),
                      child: Icon(
                        section.icon,
                        color: _green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        children: section.tasks
                            .asMap()
                            .entries
                            .map(
                              (entry) => Padding(
                                padding: EdgeInsets.only(
                                  bottom: entry.key == section.tasks.length - 1 ? 0 : 10,
                                ),
                                child: _buildTaskTile(context, entry.value),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.88),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: section.accent.withOpacity(0.95),
                    width: 1.1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      section.footerIcon,
                      size: 18,
                      color: _green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        section.footerLabel,
                        style: textTheme.bodyMedium?.copyWith(
                          fontSize: 12,
                          color: _textDark,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRewardPreviewCard(
    BuildContext context,
    _RewardPreview item,
  ) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 126,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: _softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
              size: 22,
            ),
          ),
          const Spacer(),
          Text(
            item.title,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: _textDark,
              fontWeight: FontWeight.w800,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
        ],
      ),
    );
  }

  Widget _buildBottomActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color bgColor,
    required Color textColor,
    VoidCallback? onTap,
  }) {
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _softShadow,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: textColor),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodyMedium?.copyWith(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardSection(BuildContext context, StreakState state) {
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
            _t(_lang, 'pointsAndRewards'),
            style: textTheme.headlineLarge?.copyWith(
              fontSize: 24,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _text(
              'Poinmu bisa ditukar untuk hadiah kecil yang menyenangkan, atau disimpan untuk hadiah besar.',
              'Your points can be redeemed for small fun rewards, or saved for bigger ones.',
            ),
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              height: 1.5,
              color: _textSoft,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _buildMilestoneTeaserCard(context, state),
          const SizedBox(height: 14),
          SizedBox(
            height: 124,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _rewardPreviews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return _buildRewardPreviewCard(
                  context,
                  _rewardPreviews[index],
                );
              },
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildBottomActionButton(
                  context,
                  label: _t(_lang, 'exchangePremium'),
                  icon: Icons.workspace_premium_rounded,
                  bgColor: _green,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RewardPage(
                          totalPoints: state.totalPoints,
                          openPremiumTab: true,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildBottomActionButton(
                  context,
                  label: _t(_lang, 'exchangeGift'),
                  icon: Icons.redeem_rounded,
                  bgColor: _pinkSoft,
                  textColor: _textDark,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RewardPage(
                          totalPoints: state.totalPoints,
                          openPremiumTab: false,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneTeaserCard(BuildContext context, StreakState state) {
    final textTheme = Theme.of(context).textTheme;
    final currentBadge = _currentBadgeTitleFor(state.currentStreak);
    final nextBadge = _nextBadgeTitleFor(state.currentStreak);

    return GestureDetector(
      onTap: () => _showMilestoneSheet(context, state),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: _mintSoft,
          borderRadius: BorderRadius.circular(20),
          boxShadow: _softShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFD8F2EA),
              ),
              child: const Icon(
                Icons.workspace_premium_rounded,
                color: Color(0xFF63B8A2),
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _text('Badge Milestonemu', 'Your Milestone Badge'),
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: _textSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currentBadge,
                    style: textTheme.bodyMedium?.copyWith(
                      fontSize: 13,
                      color: _textDark,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.currentStreak >= _milestones.last
                        ? _text(
                            'Semua badge sudah terbuka',
                            'All badges are unlocked',
                          )
                        : _text(
                            'Badge berikutnya: $nextBadge',
                            'Next badge: $nextBadge',
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
            const Icon(
              Icons.open_in_new_rounded,
              color: _textDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<StreakState>(
      stream: StreakService.instance.watchState(),
      builder: (context, snapshot) {
        final state = snapshot.data ?? StreakState.initial();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _syncUnlockedBadges(context, state);
        });

        final sections = _buildSections(state);

        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 120,
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
                  top: 460,
                  left: -70,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _pinkSoft.withOpacity(0.45),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -90,
                  right: 20,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _greenSoft.withOpacity(0.25),
                    ),
                  ),
                ),
                CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
                        child: _buildHeader(context, state),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: KeyedSubtree(
                          key: _walkStreakKey,
                          child: _buildSummaryCard(context, state),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 18)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: KeyedSubtree(
                          key: _walkMissionKey,
                          child: _buildMissionHeader(context, state),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                        child: Column(
                          children: sections
                              .asMap()
                              .entries
                              .map(
                                (entry) => Padding(
                                  padding: EdgeInsets.only(
                                    bottom: entry.key == sections.length - 1 ? 0 : 14,
                                  ),
                                  child: _buildMissionCard(
                                    context,
                                    entry.value,
                                    state,
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
                        child: KeyedSubtree(
                          key: _walkRewardKey,
                          child: _buildRewardSection(context, state),
                        ),
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
}

enum _MissionAction { mood, diary, affirmation }

class _MissionTask {
  final String title;
  final bool isDone;

  const _MissionTask({
    required this.title,
    required this.isDone,
  });
}

class _MissionSection {
  final String title;
  final String pointsLabel;
  final String progressLabel;
  final Color accent;
  final Color accentSoft;
  final Color chipColor;
  final Color iconBg;
  final IconData icon;
  final String subtitle;
  final String footerLabel;
  final IconData footerIcon;
  final _MissionAction action;
  final List<_MissionTask> tasks;
  final bool autoTracked;

  const _MissionSection({
    required this.title,
    required this.pointsLabel,
    required this.progressLabel,
    required this.accent,
    required this.accentSoft,
    required this.chipColor,
    required this.iconBg,
    required this.icon,
    required this.subtitle,
    required this.footerLabel,
    required this.footerIcon,
    required this.action,
    required this.tasks,
    required this.autoTracked,
  });
}

class _RewardPreview {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final Color iconColor;

  const _RewardPreview({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.iconColor,
  });
}

class _WeeklyReward {
  final String dayLabel;
  final String pointLabel;
  final bool isToday;

  const _WeeklyReward({
    required this.dayLabel,
    required this.pointLabel,
    this.isToday = false,
  });
}

class _BadgePill extends StatelessWidget {
  final String label;
  final String title;

  const _BadgePill({
    required this.label,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: 132,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF2F5),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: const Color(0xFFE58696),
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: textTheme.bodyMedium?.copyWith(
              fontSize: 12,
              color: const Color(0xFF222222),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SpotlightStep {
  final GlobalKey keyTarget;
  final String title;
  final String desc;

  const _SpotlightStep({
    required this.keyTarget,
    required this.title,
    required this.desc,
  });
}

class _BadgeSparkle extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color color;
  final double angle;

  const _BadgeSparkle({
    required this.icon,
    required this.size,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size + 10,
        height: size + 10,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.06),
        ),
        child: Icon(
          icon,
          size: size,
          color: color,
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  final Rect holeRect;
  final double borderRadius;

  const _SpotlightPainter({
    required this.holeRect,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final fullRect = Offset.zero & size;

    canvas.saveLayer(fullRect, Paint());

    final overlayPaint = Paint()
      ..color = Colors.black.withOpacity(0.68);

    canvas.drawRect(fullRect, overlayPaint);

    final clearPaint = Paint()..blendMode = BlendMode.clear;
    final rrect = RRect.fromRectAndRadius(
      holeRect,
      Radius.circular(borderRadius),
    );

    canvas.drawRRect(rrect, clearPaint);
    canvas.restore();

    final borderPaint = Paint()
      ..color = Colors.white.withOpacity(0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawRRect(rrect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.holeRect != holeRect ||
        oldDelegate.borderRadius != borderRadius;
  }
}

class _WalkthroughStep {
  final String title;
  final String desc;

  const _WalkthroughStep({
    required this.title,
    required this.desc,
  });
}