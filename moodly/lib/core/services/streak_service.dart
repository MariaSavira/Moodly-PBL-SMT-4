
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StreakState {
  final int currentStreak;
  final int longestStreak;
  final int totalPoints;

  final bool freezeEnabled;
  final int freezeOwned;
  final int freezeMax;

  final DateTime? lastMoodCheckInAt;
  final DateTime? lastMoodInsightClaimAt;
  final DateTime? lastDiaryClaimAt;
  final DateTime? lastPublicDiaryReactionAt;
  final DateTime? lastPublicDiaryCommentAt;
  final DateTime? lastPublicDiaryInteractionClaimAt;
  final DateTime? lastAffirmationClaimAt;
  final DateTime? lastAffirmationReadAt;
  final DateTime? lastAffirmationShareAt;
  final int affirmationReadCountToday;
  final List<String> affirmationReadIdsToday;
  final DateTime? lastComboClaimAt;
  final DateTime? lastAdMissionWatchAt;
  final int adMissionWatchCountToday;
  final DateTime? lastAdMissionClaimAt;
  final DateTime? lastRewardedAdWatchAt;
  final int rewardedAdWatchCountToday;
  final DateTime? lastAdBonusClaimAt;

  final bool autoUseFreeze;

  final DateTime? lastStateReviewAt;
  final String? lastMonthlyFreezeRefillKey;

  final List<int> weeklyRewardClaimedDays;
  final bool starterFreezeGranted;

  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.freezeEnabled,
    required this.freezeOwned,
    required this.freezeMax,
    required this.lastMoodCheckInAt,
    required this.lastMoodInsightClaimAt,
    required this.lastDiaryClaimAt,
    required this.lastPublicDiaryReactionAt,
    required this.lastPublicDiaryCommentAt,
    required this.lastPublicDiaryInteractionClaimAt,
    required this.lastAffirmationClaimAt,
    required this.lastAffirmationReadAt,
    required this.lastAffirmationShareAt,
    required this.affirmationReadCountToday,
    required this.affirmationReadIdsToday,
    required this.lastComboClaimAt,
    required this.lastRewardedAdWatchAt,
    required this.rewardedAdWatchCountToday,
    required this.lastAdBonusClaimAt,
    required this.lastAdMissionWatchAt,
    required this.adMissionWatchCountToday,
    required this.lastAdMissionClaimAt,
    required this.autoUseFreeze,
    required this.lastStateReviewAt,
    required this.lastMonthlyFreezeRefillKey,
    required this.weeklyRewardClaimedDays,
    required this.starterFreezeGranted,
  });

  factory StreakState.initial() {
    return const StreakState(
      currentStreak: 0,
      longestStreak: 0,
      totalPoints: 0,
      freezeEnabled: false,
      freezeOwned: 1,
      freezeMax: 10,
      lastMoodCheckInAt: null,
      lastMoodInsightClaimAt: null,
      lastDiaryClaimAt: null,
      lastPublicDiaryReactionAt: null,
      lastPublicDiaryCommentAt: null,
      lastPublicDiaryInteractionClaimAt: null,
      lastAffirmationClaimAt: null,
      lastAffirmationReadAt: null,
      lastAffirmationShareAt: null,
      affirmationReadCountToday: 0,
      affirmationReadIdsToday: <String>[],
      lastComboClaimAt: null,
      lastRewardedAdWatchAt: null,
      rewardedAdWatchCountToday: 0,
      lastAdBonusClaimAt: null,
      lastAdMissionWatchAt: null,
      adMissionWatchCountToday: 0,
      lastAdMissionClaimAt: null,
      autoUseFreeze: false,
      lastStateReviewAt: null,
      lastMonthlyFreezeRefillKey: null,
      weeklyRewardClaimedDays: <int>[],
      starterFreezeGranted: true,
    );
  }

  factory StreakState.fromMap(Map<String, dynamic> map) {
    DateTime? parseTs(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    List<int> parseDayList(dynamic value) {
      if (value is! Iterable) return <int>[];

      final result = value
          .map((e) => int.tryParse(e.toString()) ?? 0)
          .where((e) => e >= 1 && e <= 7)
          .toSet()
          .toList()
        ..sort();

      return result;
    }

    List<String> parseStringList(dynamic value) {
      if (value is! Iterable) return <String>[];
      return value
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList();
    }

    return StreakState(
      currentStreak: (map['currentStreak'] ?? 0) as int,
      longestStreak: (map['longestStreak'] ?? 0) as int,
      totalPoints: (map['totalPoints'] ?? 0) as int,
      freezeEnabled: (map['freezeEnabled'] ?? false) as bool,
      freezeOwned: (map['freezeOwned'] ?? 1) as int,
      freezeMax: (map['freezeMax'] ?? 10) as int,
      lastMoodCheckInAt: parseTs(map['lastMoodCheckInAt']),
      lastMoodInsightClaimAt: parseTs(map['lastMoodInsightClaimAt']),
      lastDiaryClaimAt: parseTs(map['lastDiaryClaimAt']),
      lastPublicDiaryReactionAt: parseTs(map['lastPublicDiaryReactionAt']),
      lastPublicDiaryCommentAt: parseTs(map['lastPublicDiaryCommentAt']),
      lastPublicDiaryInteractionClaimAt:
          parseTs(map['lastPublicDiaryInteractionClaimAt']),
      lastAffirmationClaimAt: parseTs(map['lastAffirmationClaimAt']),
      lastAffirmationReadAt: parseTs(map['lastAffirmationReadAt']),
      lastAffirmationShareAt: parseTs(map['lastAffirmationShareAt']),
      affirmationReadCountToday: (map['affirmationReadCountToday'] ?? 0) as int,
      affirmationReadIdsToday:
          parseStringList(map['affirmationReadIdsToday']),
      lastComboClaimAt: parseTs(map['lastComboClaimAt']),
      lastRewardedAdWatchAt: parseTs(map['lastRewardedAdWatchAt']),
      rewardedAdWatchCountToday: (map['rewardedAdWatchCountToday'] ?? 0) as int,
      lastAdBonusClaimAt: parseTs(map['lastAdBonusClaimAt']),
      lastAdMissionWatchAt: parseTs(map['lastAdMissionWatchAt']),
      adMissionWatchCountToday: (map['adMissionWatchCountToday'] ?? 0) as int,
      lastAdMissionClaimAt: parseTs(map['lastAdMissionClaimAt']),
      autoUseFreeze: (map['autoUseFreeze'] ?? false) as bool,
      lastStateReviewAt: parseTs(map['lastStateReviewAt']),
      lastMonthlyFreezeRefillKey:
          map['lastMonthlyFreezeRefillKey'] as String?,
      weeklyRewardClaimedDays: parseDayList(map['weeklyRewardClaimedDays']),
      starterFreezeGranted: (map['starterFreezeGranted'] ?? false) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    Timestamp? toTs(DateTime? value) =>
        value == null ? null : Timestamp.fromDate(value);

    return {
      'currentStreak': currentStreak,
      'longestStreak': longestStreak,
      'totalPoints': totalPoints,
      'freezeEnabled': freezeEnabled,
      'freezeOwned': freezeOwned,
      'freezeMax': freezeMax,
      'lastMoodCheckInAt': toTs(lastMoodCheckInAt),
      'lastMoodInsightClaimAt': toTs(lastMoodInsightClaimAt),
      'lastDiaryClaimAt': toTs(lastDiaryClaimAt),
      'lastPublicDiaryReactionAt': toTs(lastPublicDiaryReactionAt),
      'lastPublicDiaryCommentAt': toTs(lastPublicDiaryCommentAt),
      'lastPublicDiaryInteractionClaimAt':
          toTs(lastPublicDiaryInteractionClaimAt),
      'lastAffirmationClaimAt': toTs(lastAffirmationClaimAt),
      'lastAffirmationReadAt': toTs(lastAffirmationReadAt),
      'lastAffirmationShareAt': toTs(lastAffirmationShareAt),
      'affirmationReadCountToday': affirmationReadCountToday,
      'affirmationReadIdsToday': affirmationReadIdsToday,
      'lastComboClaimAt': toTs(lastComboClaimAt),
      'lastRewardedAdWatchAt': toTs(lastRewardedAdWatchAt),
      'rewardedAdWatchCountToday': rewardedAdWatchCountToday,
      'lastAdBonusClaimAt': toTs(lastAdBonusClaimAt),
      'lastAdMissionWatchAt': toTs(lastAdMissionWatchAt),
      'adMissionWatchCountToday': adMissionWatchCountToday,
      'lastAdMissionClaimAt': toTs(lastAdMissionClaimAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'autoUseFreeze': autoUseFreeze,
      'lastStateReviewAt': toTs(lastStateReviewAt),
      'lastMonthlyFreezeRefillKey': lastMonthlyFreezeRefillKey,
      'weeklyRewardClaimedDays': weeklyRewardClaimedDays,
      'starterFreezeGranted': starterFreezeGranted,
    };
  }

  StreakState copyWith({
    int? currentStreak,
    int? longestStreak,
    int? totalPoints,
    bool? freezeEnabled,
    int? freezeOwned,
    int? freezeMax,
    DateTime? lastMoodCheckInAt,
    DateTime? lastMoodInsightClaimAt,
    DateTime? lastDiaryClaimAt,
    DateTime? lastPublicDiaryReactionAt,
    DateTime? lastPublicDiaryCommentAt,
    DateTime? lastPublicDiaryInteractionClaimAt,
    DateTime? lastAffirmationClaimAt,
    DateTime? lastAffirmationReadAt,
    DateTime? lastAffirmationShareAt,
    int? affirmationReadCountToday,
    List<String>? affirmationReadIdsToday,
    DateTime? lastComboClaimAt,
    DateTime? lastRewardedAdWatchAt,
    int? rewardedAdWatchCountToday,
    DateTime? lastAdBonusClaimAt,
    DateTime? lastAdMissionWatchAt,
    int? adMissionWatchCountToday,
    DateTime? lastAdMissionClaimAt,
    bool keepLastMoodCheckInAt = true,
    bool keepLastMoodInsightClaimAt = true,
    bool keepLastDiaryClaimAt = true,
    bool keepLastPublicDiaryReactionAt = true,
    bool keepLastPublicDiaryCommentAt = true,
    bool keepLastPublicDiaryInteractionClaimAt = true,
    bool keepLastAffirmationClaimAt = true,
    bool keepLastAffirmationReadAt = true,
    bool keepLastAffirmationShareAt = true,
    bool keepAffirmationReadIdsToday = true,
    bool keepLastComboClaimAt = true,
    bool keepLastRewardedAdWatchAt = true,
    bool keepLastAdBonusClaimAt = true,
    bool keepLastAdMissionWatchAt = true,
    bool keepLastAdMissionClaimAt = true,
    bool? autoUseFreeze,
    DateTime? lastStateReviewAt,
    String? lastMonthlyFreezeRefillKey,
    bool keepLastStateReviewAt = true,
    bool keepLastMonthlyFreezeRefillKey = true,
    List<int>? weeklyRewardClaimedDays,
    bool? starterFreezeGranted,
  }) {
    return StreakState(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      totalPoints: totalPoints ?? this.totalPoints,
      freezeEnabled: freezeEnabled ?? this.freezeEnabled,
      freezeOwned: freezeOwned ?? this.freezeOwned,
      freezeMax: freezeMax ?? this.freezeMax,
      lastMoodCheckInAt: keepLastMoodCheckInAt
          ? (lastMoodCheckInAt ?? this.lastMoodCheckInAt)
          : lastMoodCheckInAt,
      lastMoodInsightClaimAt: keepLastMoodInsightClaimAt
          ? (lastMoodInsightClaimAt ?? this.lastMoodInsightClaimAt)
          : lastMoodInsightClaimAt,
      lastDiaryClaimAt: keepLastDiaryClaimAt
          ? (lastDiaryClaimAt ?? this.lastDiaryClaimAt)
          : lastDiaryClaimAt,
      lastPublicDiaryReactionAt: keepLastPublicDiaryReactionAt
          ? (lastPublicDiaryReactionAt ?? this.lastPublicDiaryReactionAt)
          : lastPublicDiaryReactionAt,
      lastPublicDiaryCommentAt: keepLastPublicDiaryCommentAt
          ? (lastPublicDiaryCommentAt ?? this.lastPublicDiaryCommentAt)
          : lastPublicDiaryCommentAt,
      lastPublicDiaryInteractionClaimAt:
          keepLastPublicDiaryInteractionClaimAt
              ? (lastPublicDiaryInteractionClaimAt ??
                  this.lastPublicDiaryInteractionClaimAt)
              : lastPublicDiaryInteractionClaimAt,
      lastAffirmationClaimAt: keepLastAffirmationClaimAt
          ? (lastAffirmationClaimAt ?? this.lastAffirmationClaimAt)
          : lastAffirmationClaimAt,
      lastAffirmationReadAt: keepLastAffirmationReadAt
          ? (lastAffirmationReadAt ?? this.lastAffirmationReadAt)
          : lastAffirmationReadAt,
      lastAffirmationShareAt: keepLastAffirmationShareAt
          ? (lastAffirmationShareAt ?? this.lastAffirmationShareAt)
          : lastAffirmationShareAt,
      affirmationReadCountToday:
          affirmationReadCountToday ?? this.affirmationReadCountToday,
      affirmationReadIdsToday: keepAffirmationReadIdsToday
          ? (affirmationReadIdsToday ?? this.affirmationReadIdsToday)
          : (affirmationReadIdsToday ?? const <String>[]),
      lastComboClaimAt: keepLastComboClaimAt
          ? (lastComboClaimAt ?? this.lastComboClaimAt)
          : lastComboClaimAt,
      lastRewardedAdWatchAt: keepLastRewardedAdWatchAt
          ? (lastRewardedAdWatchAt ?? this.lastRewardedAdWatchAt)
          : lastRewardedAdWatchAt,
      rewardedAdWatchCountToday:
          rewardedAdWatchCountToday ?? this.rewardedAdWatchCountToday,
      lastAdBonusClaimAt: keepLastAdBonusClaimAt
          ? (lastAdBonusClaimAt ?? this.lastAdBonusClaimAt)
          : lastAdBonusClaimAt,
      lastAdMissionWatchAt: keepLastAdMissionWatchAt
          ? (lastAdMissionWatchAt ?? this.lastAdMissionWatchAt)
          : lastAdMissionWatchAt,
      adMissionWatchCountToday:
          adMissionWatchCountToday ?? this.adMissionWatchCountToday,
      lastAdMissionClaimAt: keepLastAdMissionClaimAt
          ? (lastAdMissionClaimAt ?? this.lastAdMissionClaimAt)
          : lastAdMissionClaimAt,
      autoUseFreeze: autoUseFreeze ?? this.autoUseFreeze,
      lastStateReviewAt: keepLastStateReviewAt
          ? (lastStateReviewAt ?? this.lastStateReviewAt)
          : lastStateReviewAt,
      lastMonthlyFreezeRefillKey: keepLastMonthlyFreezeRefillKey
          ? (lastMonthlyFreezeRefillKey ?? this.lastMonthlyFreezeRefillKey)
          : lastMonthlyFreezeRefillKey,
      weeklyRewardClaimedDays:
          weeklyRewardClaimedDays ?? this.weeklyRewardClaimedDays,
      starterFreezeGranted: starterFreezeGranted ?? this.starterFreezeGranted,
    );
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month;
  }

  bool _wasFullMissionCompletedOnDate(StreakState state, DateTime day) {
    final moodDone = _isSameDay(state.lastMoodCheckInAt, day);
    final moodInsightDone = _isSameMonth(state.lastMoodInsightClaimAt, day);
    final diaryDone = _isSameDay(state.lastDiaryClaimAt, day);
    final publicDiaryDone =
        _isSameDay(state.lastPublicDiaryInteractionClaimAt, day);

    final affirmationReadDone =
        _isSameDay(state.lastAffirmationReadAt, day) &&
        state.affirmationReadCountToday >= 5;

    final affirmationSharedDone =
        _isSameDay(state.lastAffirmationShareAt, day);

    return moodDone &&
        moodInsightDone &&
        diaryDone &&
        publicDiaryDone &&
        affirmationReadDone &&
        affirmationSharedDone;
  }

  bool get moodDoneToday => _isSameDay(lastMoodCheckInAt, DateTime.now());
  bool get moodInsightDoneThisMonth =>
      _isSameMonth(lastMoodInsightClaimAt, DateTime.now());
  bool get moodInsightClaimedToday =>
      _isSameDay(lastMoodInsightClaimAt, DateTime.now());

  bool get diaryDoneToday => _isSameDay(lastDiaryClaimAt, DateTime.now());
  bool get publicDiaryReactionDoneToday =>
      _isSameDay(lastPublicDiaryReactionAt, DateTime.now());
  bool get publicDiaryCommentDoneToday =>
      _isSameDay(lastPublicDiaryCommentAt, DateTime.now());
  bool get publicDiaryInteractionDoneToday =>
      _isSameDay(lastPublicDiaryInteractionClaimAt, DateTime.now());
  bool get publicDiaryInteractionClaimedToday =>
      _isSameDay(lastPublicDiaryInteractionClaimAt, DateTime.now());

  bool get affirmationDoneToday =>
      _isSameDay(lastAffirmationClaimAt, DateTime.now());

  int get adWatchProgressToday =>
      _isSameDay(lastRewardedAdWatchAt, DateTime.now())
          ? rewardedAdWatchCountToday.clamp(0, 2)
          : 0;

  bool get affirmationReadDoneToday => affirmationReadProgressToday >= 5;

  int get affirmationMissionCompletedCount {
    int count = 0;
    if (affirmationReadDoneToday) count++;
    if (affirmationSharedToday) count++;
    return count;
  }

  bool get adBonusDoneToday =>
      _isSameDay(lastAdBonusClaimAt, DateTime.now());

  bool get adBonusClaimedToday =>
      _isSameDay(lastAdBonusClaimAt, DateTime.now());
  bool get affirmationSharedToday =>
      _isSameDay(lastAffirmationShareAt, DateTime.now());
  int get affirmationReadProgressToday =>
      _isSameDay(lastAffirmationReadAt, DateTime.now())
          ? affirmationReadCountToday.clamp(0, 5)
          : 0;
  int get adMissionWatchProgressToday =>
      _isSameDay(lastAdMissionWatchAt, DateTime.now())
          ? adMissionWatchCountToday.clamp(0, 2)
          : 0;
  bool get adMissionDoneToday =>
      _isSameDay(lastAdMissionClaimAt, DateTime.now());
  bool get adMissionClaimedToday =>
      _isSameDay(lastAdMissionClaimAt, DateTime.now());
  bool get comboDoneToday => _isSameDay(lastComboClaimAt, DateTime.now());

  int get moodMissionCompletedCount {
    int count = 0;
    if (moodDoneToday) count++;
    if (moodInsightDoneThisMonth) count++;
    return count;
  }

  int get diaryMissionCompletedCount {
    int count = 0;
    if (diaryDoneToday) count++;
    if (publicDiaryInteractionDoneToday) count++;
    return count;
  }

  int get completedPrimaryCount {
    int count = 0;
    if (moodDoneToday) count++;
    if (diaryDoneToday) count++;
    if (affirmationDoneToday) count++;
    return count;
  }
}

class StreakClaimResult {
  final StreakState state;
  final bool success;
  final String message;
  final int pointsAdded;
  final int freezeUsed;

  const StreakClaimResult({
    required this.state,
    required this.success,
    required this.message,
    this.pointsAdded = 0,
    this.freezeUsed = 0,
  });
}

class StreakService {
  StreakService._();

  static final StreakService instance = StreakService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  static const int moodPoints = 10;
  static const int moodInsightPoints = 15;

  // total Diary section = 25
  static const int diaryPoints = 10;
  static const int diaryInteractionPoints = 15;

  // total Affirmation section = 25
  static const int affirmationPoints = 25;
  static const int adMissionPoints = 30;
  static const int comboPoints = 0;
  static const int adBonusPoints = 30;
  static const int adBonusTargetViews = 2;

  static const List<int> weeklyRewardSchedule = [10, 10, 10, 10, 15, 20, 30];

  static int weeklyDayForStreak(int streak) {
    if (streak <= 0) return 1;
    return ((streak - 1) % 7) + 1;
  }

  static int weeklyBonusForDay(int day) {
    if (day < 1 || day > weeklyRewardSchedule.length) return 0;
    return weeklyRewardSchedule[day - 1];
  }

  DocumentReference<Map<String, dynamic>> _streakRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('streak')
        .doc('main');
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int _daysBetween(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }

  String _monthKey(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isSameMonth(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month;
  }

  bool _wasFullMissionCompletedOnDate(StreakState state, DateTime day) {
    final moodDone = _isSameDay(state.lastMoodCheckInAt, day);
    final moodInsightDone = _isSameMonth(state.lastMoodInsightClaimAt, day);
    final diaryDone = _isSameDay(state.lastDiaryClaimAt, day);
    final publicDiaryDone =
        _isSameDay(state.lastPublicDiaryInteractionClaimAt, day);

    final affirmationReadDone =
        _isSameDay(state.lastAffirmationReadAt, day) &&
        state.affirmationReadCountToday >= 5;

    final affirmationSharedDone =
        _isSameDay(state.lastAffirmationShareAt, day);

    return moodDone &&
        moodInsightDone &&
        diaryDone &&
        publicDiaryDone &&
        affirmationReadDone &&
        affirmationSharedDone;
  }

  Future<void> _ensureExists(String uid) async {
    final ref = _streakRef(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set(StreakState.initial().toMap());
      return;
    }

    final data = snap.data() ?? {};
    final updates = <String, dynamic>{};

    if (!data.containsKey('freezeMax')) updates['freezeMax'] = 10;
    if (!data.containsKey('freezeEnabled')) updates['freezeEnabled'] = false;
    if (!data.containsKey('autoUseFreeze')) updates['autoUseFreeze'] = false;
    if (!data.containsKey('weeklyRewardClaimedDays')) {
      updates['weeklyRewardClaimedDays'] = <int>[];
    }
    if (!data.containsKey('longestStreak')) {
      updates['longestStreak'] = (data['currentStreak'] ?? 0) as int;
    }
    if (!data.containsKey('affirmationReadCountToday')) {
      updates['affirmationReadCountToday'] = 0;
    }
    if (!data.containsKey('affirmationReadIdsToday')) {
      updates['affirmationReadIdsToday'] = <String>[];
    }
    if (!data.containsKey('rewardedAdWatchCountToday')) {
      updates['rewardedAdWatchCountToday'] = 0;
    }
    if (!data.containsKey('lastRewardedAdWatchAt')) {
      updates['lastRewardedAdWatchAt'] = null;
    }
    if (!data.containsKey('lastAdBonusClaimAt')) {
      updates['lastAdBonusClaimAt'] = null;
    }
    if (!data.containsKey('adMissionWatchCountToday')) {
      updates['adMissionWatchCountToday'] = 0;
    }
    if (data['starterFreezeGranted'] != true) {
      final currentFreeze = (data['freezeOwned'] ?? 0) as int;
      updates['starterFreezeGranted'] = true;
      if (currentFreeze < 1) updates['freezeOwned'] = 1;
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(updates, SetOptions(merge: true));
    }
  }

  Stream<StreakState> watchState() async* {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      yield StreakState.initial();
      return;
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    yield* _streakRef(uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return StreakState.initial();
      return StreakState.fromMap(data);
    });
  }

  Future<StreakState> getState() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final snap = await _streakRef(uid).get();
    return StreakState.fromMap(snap.data() ?? {});
  }

  Future<StreakState> refreshStateForToday() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final ref = _streakRef(uid);
    final now = DateTime.now();
    final today = _dateOnly(now);

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (_isSameDay(current.lastStateReviewAt, today)) {
        return current;
      }

      int nextStreak = current.currentStreak;
      int nextFreezeOwned = current.freezeOwned;
      bool nextFreezeEnabled = current.freezeEnabled;
      bool nextAutoUse = current.autoUseFreeze;
      String? nextMonthlyKey = current.lastMonthlyFreezeRefillKey;
      List<int> nextWeeklyClaimedDays =
          List<int>.from(current.weeklyRewardClaimedDays);

      final yesterday = today.subtract(const Duration(days: 1));

      if (current.lastStateReviewAt != null) {
        final failedYesterday = !_wasFullMissionCompletedOnDate(current, yesterday);
        if (failedYesterday) {
          nextWeeklyClaimedDays = <int>[];
        }
      }

      final lastMoodDay = current.lastMoodCheckInAt == null
          ? null
          : _dateOnly(current.lastMoodCheckInAt!);

      if (lastMoodDay != null) {
        final gap = _daysBetween(lastMoodDay, today);

        if (gap > 1) {
          final missedDays = gap - 1;

          if ((current.freezeEnabled || current.autoUseFreeze) &&
              nextFreezeOwned > 0) {
            final consumed =
                missedDays <= nextFreezeOwned ? missedDays : nextFreezeOwned;

            nextFreezeOwned -= consumed;

            if (consumed < missedDays) {
              nextStreak = 0;
              nextWeeklyClaimedDays = <int>[];
            }
          } else {
            nextStreak = 0;
            nextWeeklyClaimedDays = <int>[];
          }
        }
      }

      if (today.day == 1) {
        final currentMonthKey = _monthKey(today);
        if (nextMonthlyKey != currentMonthKey) {
          nextFreezeOwned = (nextFreezeOwned + 1).clamp(0, current.freezeMax);
          nextMonthlyKey = currentMonthKey;
        }
      }

      if (nextFreezeOwned <= 0) {
        nextFreezeOwned = 0;
        nextFreezeEnabled = false;
        nextAutoUse = false;
      }

      final next = current.copyWith(
        currentStreak: nextStreak,
        freezeOwned: nextFreezeOwned,
        freezeEnabled: nextFreezeEnabled,
        autoUseFreeze: nextAutoUse,
        lastStateReviewAt: today,
        lastMonthlyFreezeRefillKey: nextMonthlyKey,
        weeklyRewardClaimedDays: nextWeeklyClaimedDays,
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));
      return next;
    });
  }

  Future<StreakClaimResult> claimMoodCheckIn() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return StreakClaimResult(
        state: StreakState.initial(),
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.moodDoneToday) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Mood hari ini sudah dicatat.',
        );
      }

      final int newStreak =
          current.currentStreak == 0 ? 1 : current.currentStreak + 1;

      final int newCycleDay = weeklyDayForStreak(newStreak);
      final List<int> nextWeeklyClaimedDays = newCycleDay == 1
          ? <int>[]
          : List<int>.from(current.weeklyRewardClaimedDays);

      final next = current.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > current.longestStreak ? newStreak : current.longestStreak,
        totalPoints: current.totalPoints + moodPoints,
        lastMoodCheckInAt: now,
        lastStateReviewAt: _dateOnly(now),
        weeklyRewardClaimedDays: nextWeeklyClaimedDays,
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: 'Mood berhasil dicatat.',
        pointsAdded: moodPoints,
      );
    });
  }

  Future<void> markMonthlyMoodInsightViewed() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.moodInsightDoneThisMonth) return;

      final next = current.copyWith(
        totalPoints: current.totalPoints + moodInsightPoints,
        lastMoodInsightClaimAt: now,
        lastStateReviewAt: _dateOnly(now),
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));
    });
  }

  Future<StreakClaimResult> claimDiaryBonus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return StreakClaimResult(
        state: StreakState.initial(),
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.diaryDoneToday) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Misi tulis diary publik hari ini sudah tercatat.',
        );
      }

      final next = current.copyWith(
        totalPoints: current.totalPoints + diaryPoints,
        lastDiaryClaimAt: now,
        lastStateReviewAt: _dateOnly(now),
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: 'Misi tulis diary publik berhasil dicatat.',
        pointsAdded: diaryPoints,
      );
    });
  }

  Future<void> registerPublicDiaryReaction() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});
      var next = current;

      if (!current.publicDiaryReactionDoneToday) {
        next = next.copyWith(
          lastPublicDiaryReactionAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      final shouldClaimInteraction = next.publicDiaryReactionDoneToday &&
          next.publicDiaryCommentDoneToday &&
          !next.publicDiaryInteractionDoneToday;

      if (shouldClaimInteraction) {
        next = next.copyWith(
          totalPoints: next.totalPoints + diaryInteractionPoints,
          lastPublicDiaryInteractionClaimAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      tx.set(ref, next.toMap(), SetOptions(merge: true));
    });
  }

  Future<void> registerPublicDiaryComment() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});
      var next = current;

      if (!current.publicDiaryCommentDoneToday) {
        next = next.copyWith(
          lastPublicDiaryCommentAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      final shouldClaimInteraction = next.publicDiaryReactionDoneToday &&
          next.publicDiaryCommentDoneToday &&
          !next.publicDiaryInteractionDoneToday;

      if (shouldClaimInteraction) {
        next = next.copyWith(
          totalPoints: next.totalPoints + diaryInteractionPoints,
          lastPublicDiaryInteractionClaimAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      tx.set(ref, next.toMap(), SetOptions(merge: true));
    });
  }

  Future<void> registerAffirmationRead({
    required String affirmationId,
  }) async {
    final uid = _auth.currentUser?.uid;
    final safeId = affirmationId.trim();
    if (uid == null || safeId.isEmpty) return;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final isSameReadDay = _isSameDay(current.lastAffirmationReadAt, now);
      final readIds = isSameReadDay
          ? List<String>.from(current.affirmationReadIdsToday)
          : <String>[];

      if (readIds.contains(safeId)) {
        return;
      }

      readIds.add(safeId);
      var next = current.copyWith(
        lastAffirmationReadAt: now,
        affirmationReadCountToday: readIds.length,
        affirmationReadIdsToday: readIds,
        lastStateReviewAt: _dateOnly(now),
      );

      if (!next.affirmationDoneToday && readIds.length >= 5) {
        next = next.copyWith(
          totalPoints: next.totalPoints + affirmationPoints,
          lastAffirmationClaimAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      tx.set(ref, next.toMap(), SetOptions(merge: true));
    });
  }

  Future<void> registerAffirmationShare() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.affirmationSharedToday) return;

      var next = current.copyWith(
        lastAffirmationShareAt: now,
        lastStateReviewAt: _dateOnly(now),
      );

      final readDone = next.affirmationReadProgressToday >= 5;

      if (readDone && !next.affirmationDoneToday) {
        next = next.copyWith(
          totalPoints: next.totalPoints + affirmationPoints,
          lastAffirmationClaimAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      tx.set(ref, next.toMap(), SetOptions(merge: true));
    });
  }

  Future<bool> registerRewardedAdWatch() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final sameDay = _isSameDay(current.lastRewardedAdWatchAt, now);
      int nextCount = sameDay ? current.rewardedAdWatchCountToday : 0;

      if (nextCount < adBonusTargetViews) {
        nextCount += 1;
      }

      var next = current.copyWith(
        lastRewardedAdWatchAt: now,
        rewardedAdWatchCountToday: nextCount,
        lastStateReviewAt: _dateOnly(now),
      );

      bool grantedBonus = false;

      if (nextCount >= adBonusTargetViews && !current.adBonusDoneToday) {
        grantedBonus = true;
        next = next.copyWith(
          totalPoints: next.totalPoints + adBonusPoints,
          lastAdBonusClaimAt: now,
          lastStateReviewAt: _dateOnly(now),
        );
      }

      tx.set(ref, next.toMap(), SetOptions(merge: true));
      return grantedBonus;
    });
  }

  Future<StreakClaimResult> claimAffirmationBonus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return StreakClaimResult(
        state: StreakState.initial(),
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.affirmationDoneToday) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Bonus afirmasi hari ini sudah diklaim.',
        );
      }

      final readDone = current.affirmationReadProgressToday >= 5;
      final shareDone = current.affirmationSharedToday;

      if (!readDone || !shareDone) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Selesaikan baca 5 afirmasi dan bagikan 1 afirmasi terlebih dahulu.',
        );
      }

      final next = current.copyWith(
        totalPoints: current.totalPoints + affirmationPoints,
        lastAffirmationClaimAt: now,
        lastStateReviewAt: _dateOnly(now),
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: 'Bonus afirmasi berhasil diklaim.',
        pointsAdded: affirmationPoints,
      );
    });
  }

  Future<StreakClaimResult> _claimDailyBonus({
    required _DailyBonusType type,
    required int points,
    required String successMessage,
    required String alreadyMessage,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return StreakClaimResult(
        state: StreakState.initial(),
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final alreadyClaimed = type == _DailyBonusType.affirmation
          ? current.affirmationDoneToday
          : false;

      if (alreadyClaimed) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: alreadyMessage,
        );
      }

      final next = current.copyWith(
        totalPoints: current.totalPoints + points,
        lastAffirmationClaimAt: now,
        lastStateReviewAt: _dateOnly(now),
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: successMessage,
        pointsAdded: points,
      );
    });
  }

  Future<StreakClaimResult> claimComboBonus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return StreakClaimResult(
        state: StreakState.initial(),
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureExists(uid);
    await refreshStateForToday();

    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.comboDoneToday) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Bonus mingguan hari ini sudah diklaim.',
        );
      }

      final ready = current.moodMissionCompletedCount == 2 &&
        current.diaryMissionCompletedCount == 2 &&
        current.affirmationMissionCompletedCount == 2;

      if (!ready) {
        return StreakClaimResult(
          state: current,
          success: false,
          message:
              'Combo belum siap. Selesaikan seluruh 6 misi harian terlebih dahulu.',
        );
      }

      final cycleDay = weeklyDayForStreak(current.currentStreak);
      final weeklyBonus = weeklyBonusForDay(cycleDay);

      final claimedDays = List<int>.from(current.weeklyRewardClaimedDays);
      if (!claimedDays.contains(cycleDay)) {
        claimedDays.add(cycleDay);
        claimedDays.sort();
      }

      final next = current.copyWith(
        totalPoints: current.totalPoints + weeklyBonus,
        lastComboClaimAt: now,
        lastStateReviewAt: _dateOnly(now),
        weeklyRewardClaimedDays: claimedDays,
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: 'Bonus progres mingguan hari ke-$cycleDay berhasil diklaim.',
        pointsAdded: weeklyBonus,
      );
    });
  }

  Future<StreakState> toggleFreeze(bool enabled) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final ref = _streakRef(uid);

    await ref.set({
      'freezeEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return getState();
  }

  Future<StreakState> toggleAutoUseFreeze(bool enabled) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final ref = _streakRef(uid);

    await ref.set({
      'autoUseFreeze': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return getState();
  }

  Future<StreakState> grantMonthlyFreezeBonus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final ref = _streakRef(uid);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final nextFreeze = (current.freezeOwned + 3).clamp(0, current.freezeMax);

      tx.set(ref, {
        'freezeOwned': nextFreeze,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return getState();
  }

  Future<StreakState> grantPremiumBonus({
    int pointBonus = 150,
    int freezeBonus = 2,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return StreakState.initial();

    await _ensureExists(uid);
    final ref = _streakRef(uid);

    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final nextFreeze =
          (current.freezeOwned + freezeBonus).clamp(0, current.freezeMax);

      tx.set(ref, {
        'totalPoints': current.totalPoints + pointBonus,
        'freezeOwned': nextFreeze,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });

    return getState();
  }
}

enum _DailyBonusType {
  affirmation,
}
