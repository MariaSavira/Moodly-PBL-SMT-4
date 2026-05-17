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
  final DateTime? lastDiaryClaimAt;
  final DateTime? lastAffirmationClaimAt;
  final DateTime? lastComboClaimAt;

  final bool autoUseFreeze;

  const StreakState({
    required this.currentStreak,
    required this.longestStreak,
    required this.totalPoints,
    required this.freezeEnabled,
    required this.freezeOwned,
    required this.freezeMax,
    required this.lastMoodCheckInAt,
    required this.lastDiaryClaimAt,
    required this.lastAffirmationClaimAt,
    required this.lastComboClaimAt,
    required this.autoUseFreeze,
  });

  factory StreakState.initial() {
    return const StreakState(
      currentStreak: 0,
      longestStreak: 0,
      totalPoints: 0,
      freezeEnabled: false,
      freezeOwned: 1, // starter freeze
      freezeMax: 10,
      lastMoodCheckInAt: null,
      lastDiaryClaimAt: null,
      lastAffirmationClaimAt: null,
      lastComboClaimAt: null,
      autoUseFreeze: false,
    );
  }

  factory StreakState.fromMap(Map<String, dynamic> map) {
    DateTime? parseTs(dynamic value) {
      if (value is Timestamp) return value.toDate();
      return null;
    }

    return StreakState(
      currentStreak: (map['currentStreak'] ?? 0) as int,
      longestStreak: (map['longestStreak'] ?? 0) as int,
      totalPoints: (map['totalPoints'] ?? 0) as int,
      freezeEnabled: (map['freezeEnabled'] ?? false) as bool,
      freezeOwned: (map['freezeOwned'] ?? 1) as int,
      freezeMax: (map['freezeMax'] ?? 10) as int,
      lastMoodCheckInAt: parseTs(map['lastMoodCheckInAt']),
      lastDiaryClaimAt: parseTs(map['lastDiaryClaimAt']),
      lastAffirmationClaimAt: parseTs(map['lastAffirmationClaimAt']),
      lastComboClaimAt: parseTs(map['lastComboClaimAt']),
      autoUseFreeze: (map['autoUseFreeze'] ?? false) as bool,
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
      'lastDiaryClaimAt': toTs(lastDiaryClaimAt),
      'lastAffirmationClaimAt': toTs(lastAffirmationClaimAt),
      'lastComboClaimAt': toTs(lastComboClaimAt),
      'updatedAt': FieldValue.serverTimestamp(),
      'autoUseFreeze': autoUseFreeze,
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
    DateTime? lastDiaryClaimAt,
    DateTime? lastAffirmationClaimAt,
    DateTime? lastComboClaimAt,
    bool keepLastMoodCheckInAt = true,
    bool keepLastDiaryClaimAt = true,
    bool keepLastAffirmationClaimAt = true,
    bool keepLastComboClaimAt = true,
    bool? autoUseFreeze,
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
      lastDiaryClaimAt: keepLastDiaryClaimAt
          ? (lastDiaryClaimAt ?? this.lastDiaryClaimAt)
          : lastDiaryClaimAt,
      lastAffirmationClaimAt: keepLastAffirmationClaimAt
          ? (lastAffirmationClaimAt ?? this.lastAffirmationClaimAt)
          : lastAffirmationClaimAt,
      lastComboClaimAt: keepLastComboClaimAt
          ? (lastComboClaimAt ?? this.lastComboClaimAt)
          : lastComboClaimAt,
      autoUseFreeze: autoUseFreeze ?? this.autoUseFreeze,
    );
  }

  bool _isSameDay(DateTime? a, DateTime b) {
    if (a == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool get moodDoneToday => _isSameDay(lastMoodCheckInAt, DateTime.now());
  bool get diaryDoneToday => _isSameDay(lastDiaryClaimAt, DateTime.now());
  bool get affirmationDoneToday =>
      _isSameDay(lastAffirmationClaimAt, DateTime.now());
  bool get comboDoneToday => _isSameDay(lastComboClaimAt, DateTime.now());

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
  static const int diaryPoints = 5;
  static const int affirmationPoints = 5;
  static const int comboPoints = 5;

  DocumentReference<Map<String, dynamic>> _streakRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('streak').doc('main');
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  int _daysBetween(DateTime from, DateTime to) {
    return _dateOnly(to).difference(_dateOnly(from)).inDays;
  }

  Future<void> _ensureExists(String uid) async {
    final ref = _streakRef(uid);
    final snap = await ref.get();
    if (!snap.exists) {
      await ref.set(StreakState.initial().toMap());
    }
  }

  Stream<StreakState> watchState() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return Stream.value(StreakState.initial());
    }

    return _streakRef(uid).snapshots().map((doc) {
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

      int newStreak = current.currentStreak;
      int newFreezeOwned = current.freezeOwned;
      int freezeUsed = 0;

      if (current.lastMoodCheckInAt == null) {
        newStreak = 1;
      } else {
        final gapDays = _daysBetween(current.lastMoodCheckInAt!, now);

        if (gapDays == 1) {
          newStreak = current.currentStreak + 1;
        } else if (gapDays > 1) {
          final missedDays = gapDays - 1;

          if ((current.freezeEnabled || current.autoUseFreeze) &&
            current.freezeOwned >= missedDays) {
              freezeUsed = missedDays;
              newFreezeOwned = current.freezeOwned - missedDays;
              newStreak = current.currentStreak + gapDays;
            } else {
              newStreak = 1;
          }
        }
      }

      final next = current.copyWith(
        currentStreak: newStreak,
        longestStreak:
            newStreak > current.longestStreak ? newStreak : current.longestStreak,
        totalPoints: current.totalPoints + moodPoints,
        freezeOwned: newFreezeOwned,
        lastMoodCheckInAt: now,
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: freezeUsed > 0
            ? 'Mood berhasil dicatat. $freezeUsed freeze terpakai untuk menjaga streak.'
            : 'Mood berhasil dicatat.',
        pointsAdded: moodPoints,
        freezeUsed: freezeUsed,
      );
    });
  }

  Future<StreakClaimResult> claimDiaryBonus() async {
    return _claimDailyBonus(
      type: _DailyBonusType.diary,
      points: diaryPoints,
      successMessage: 'Bonus diary berhasil diklaim.',
      alreadyMessage: 'Bonus diary hari ini sudah diklaim.',
    );
  }

  Future<StreakClaimResult> claimAffirmationBonus() async {
    return _claimDailyBonus(
      type: _DailyBonusType.affirmation,
      points: affirmationPoints,
      successMessage: 'Bonus afirmasi berhasil diklaim.',
      alreadyMessage: 'Bonus afirmasi hari ini sudah diklaim.',
    );
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
    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      final alreadyClaimed = type == _DailyBonusType.diary
          ? current.diaryDoneToday
          : current.affirmationDoneToday;

      if (alreadyClaimed) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: alreadyMessage,
        );
      }

      final next = type == _DailyBonusType.diary
          ? current.copyWith(
              totalPoints: current.totalPoints + points,
              lastDiaryClaimAt: now,
            )
          : current.copyWith(
              totalPoints: current.totalPoints + points,
              lastAffirmationClaimAt: now,
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
    final ref = _streakRef(uid);
    final now = DateTime.now();

    return _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final current = StreakState.fromMap(snap.data() ?? {});

      if (current.comboDoneToday) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Bonus combo hari ini sudah diklaim.',
        );
      }

      final ready =
          current.moodDoneToday && current.diaryDoneToday && current.affirmationDoneToday;

      if (!ready) {
        return StreakClaimResult(
          state: current,
          success: false,
          message: 'Combo belum siap. Selesaikan mood, diary, dan afirmasi dulu.',
        );
      }

      final next = current.copyWith(
        totalPoints: current.totalPoints + comboPoints,
        lastComboClaimAt: now,
      );

      tx.set(ref, next.toMap(), SetOptions(merge: true));

      return StreakClaimResult(
        state: next,
        success: true,
        message: 'Bonus combo berhasil diklaim.',
        pointsAdded: comboPoints,
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
  diary,
  affirmation,
}