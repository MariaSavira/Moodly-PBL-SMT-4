import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/premium_access_model.dart';

enum RewardKind {
  avatar,
  frame,
  freeze,
  premiumSelf,
  premiumGift,
}

class RewardRedeemResult {
  final bool success;
  final String message;

  const RewardRedeemResult({
    required this.success,
    required this.message,
  });
}

class RewardService {
  RewardService._();

  static final RewardService instance = RewardService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DocumentReference<Map<String, dynamic>> _userRef(String uid) {
    return _firestore.collection('users').doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _streakRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('streak')
        .doc('main');
  }

  DocumentReference<Map<String, dynamic>> _inventoryRef(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('reward_inventory')
        .doc('main');
  }

  DateTime? _readDate(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  DateTime _resolvePremiumBaseDate(
    Map<String, dynamic>? userData,
    DateTime now,
  ) {
    final access = PremiumAccessModel.fromUserMap(userData);
    final expiresAt = access.expiresAt;

    if (expiresAt != null && expiresAt.isAfter(now)) {
      return expiresAt;
    }

    final legacyExpires = _readDate(userData?['premiumExpiresAt']);
    if (legacyExpires != null && legacyExpires.isAfter(now)) {
      return legacyExpires;
    }

    return now;
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final int totalMonths = (date.month - 1) + monthsToAdd;
    final int year = date.year + (totalMonths ~/ 12);
    final int month = (totalMonths % 12) + 1;

    final int lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final int day =
        date.day > lastDayOfTargetMonth ? lastDayOfTargetMonth : date.day;

    return DateTime(
      year,
      month,
      day,
      date.hour,
      date.minute,
      date.second,
      date.millisecond,
      date.microsecond,
    );
  }

  Map<String, dynamic> _buildPremiumActivationPatch({
    required Map<String, dynamic>? userData,
    required DateTime now,
    required int months,
    required String planId,
    required String source,
    String? giftedBy,
  }) {
    final access = PremiumAccessModel.fromUserMap(userData);
    final baseDate = _resolvePremiumBaseDate(userData, now);
    final expiresAt = _addMonths(baseDate, months);
    final activatedAt =
        access.hasPremiumAccess && access.activatedAt != null
            ? access.activatedAt!
            : now;

    return {
      // legacy fields
      'isPremium': true,
      'premiumActivatedAt': Timestamp.fromDate(activatedAt),
      'premiumExpiresAt': Timestamp.fromDate(expiresAt),

      // new fields
      'premiumTier': premiumTierToValue(PremiumTier.premium),
      'premiumStatus': premiumStatusToValue(PremiumStatus.active),
      'premiumPlan': planId,
      'premiumSource': source,
      'premiumUpdatedAt': FieldValue.serverTimestamp(),

      // general
      if (giftedBy != null) 'giftedBy': giftedBy,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Map<String, dynamic> _buildPremiumExpiredPatch(
    Map<String, dynamic>? userData,
  ) {
    final access = PremiumAccessModel.fromUserMap(userData);

    return {
      'isPremium': false,
      'premiumTier': premiumTierToValue(access.tier),
      'premiumStatus': premiumStatusToValue(PremiumStatus.expired),
      'premiumUpdatedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> _ensureStreakExists(String uid) async {
    final ref = _streakRef(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'currentStreak': 0,
        'longestStreak': 0,
        'totalPoints': 0,
        'freezeEnabled': false,
        'freezeOwned': 1,
        'freezeMax': 10,
        'autoUseFreeze': false,
        'weeklyRewardClaimedDays': <int>[],
        'starterFreezeGranted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      return;
    }

    final data = snap.data() ?? {};
    final updates = <String, dynamic>{};

    if (!data.containsKey('freezeOwned')) {
      updates['freezeOwned'] = 1;
    }

    if (!data.containsKey('freezeMax')) {
      updates['freezeMax'] = 10;
    }

    if (!data.containsKey('freezeEnabled')) {
      updates['freezeEnabled'] = false;
    }

    if (!data.containsKey('autoUseFreeze')) {
      updates['autoUseFreeze'] = false;
    }

    if (!data.containsKey('starterFreezeGranted')) {
      updates['starterFreezeGranted'] = true;
    }

    if (!data.containsKey('weeklyRewardClaimedDays')) {
      updates['weeklyRewardClaimedDays'] = <int>[];
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      await ref.set(updates, SetOptions(merge: true));
    }
  }

  Future<void> _ensureInventoryExists(String uid) async {
    final ref = _inventoryRef(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'ownedAvatarIds': <String>[],
        'ownedFrameIds': <String>[],
        'claimedBadgeIds': <String>[],
        'activeFrameId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> normalizeCurrentUserPremiumStatus() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    final ref = _userRef(uid);
    final snap = await ref.get();
    final data = snap.data();

    if (data == null) return;

    final access = PremiumAccessModel.fromUserMap(data);
    final legacyIsPremium = (data['isPremium'] as bool?) ?? false;
    final rawStatus = (data['premiumStatus'] as String?)?.trim() ?? '';

    if (access.isExpired && (legacyIsPremium || rawStatus == 'active')) {
      await ref.set(
        _buildPremiumExpiredPatch(data),
        SetOptions(merge: true),
      );
    }
  }

  Future<bool> isCurrentUserPremiumActive() async {
    await normalizeCurrentUserPremiumStatus();

    final uid = _auth.currentUser?.uid;
    if (uid == null) return false;

    final snap = await _userRef(uid).get();
    final data = snap.data();

    final access = PremiumAccessModel.fromUserMap(data);
    return access.hasPremiumAccess;
  }

  Future<RewardRedeemResult> redeemItem({
    required String itemId,
    required RewardKind kind,
    required int price,
    String? giftedUserId,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      return const RewardRedeemResult(
        success: false,
        message: 'User belum login.',
      );
    }

    await _ensureInventoryExists(uid);
    await _ensureStreakExists(uid);
    await normalizeCurrentUserPremiumStatus();

    final streakRef = _streakRef(uid);
    final inventoryRef = _inventoryRef(uid);
    final userRef = _userRef(uid);

    try {
      final successMessage = await _firestore.runTransaction<String>((tx) async {
        final streakSnap = await tx.get(streakRef);
        final inventorySnap = await tx.get(inventoryRef);

        final streakData = streakSnap.data() ?? {};
        final inventoryData = inventorySnap.data() ?? {};

        final totalPoints = (streakData['totalPoints'] as num?)?.toInt() ?? 0;
        if (totalPoints < price) {
          throw Exception('Poinmu belum cukup.');
        }

        final ownedAvatarIds =
            List<String>.from(inventoryData['ownedAvatarIds'] ?? const []);
        final ownedFrameIds =
            List<String>.from(inventoryData['ownedFrameIds'] ?? const []);
        final activeFrameId =
            (inventoryData['activeFrameId'] as String?)?.trim();

        if (kind == RewardKind.avatar && ownedAvatarIds.contains(itemId)) {
          throw Exception('Avatar ini sudah kamu miliki.');
        }

        if (kind == RewardKind.frame && ownedFrameIds.contains(itemId)) {
          throw Exception('Frame ini sudah kamu miliki.');
        }

        tx.set(streakRef, {
          'totalPoints': totalPoints - price,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        switch (kind) {
          case RewardKind.avatar:
            ownedAvatarIds.add(itemId);
            tx.set(inventoryRef, {
              'ownedAvatarIds': ownedAvatarIds,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            return 'Avatar berhasil ditukar.';

          case RewardKind.frame:
            ownedFrameIds.add(itemId);
            tx.set(inventoryRef, {
              'ownedFrameIds': ownedFrameIds,
              'activeFrameId': activeFrameId ?? itemId,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            return 'Bingkai avatar berhasil ditukar.';

          case RewardKind.freeze:
            final currentFreezeOwned =
                (streakData['freezeOwned'] as num?)?.toInt() ?? 1;
            final currentFreezeMax =
                (streakData['freezeMax'] as num?)?.toInt() ?? 10;

            final nextFreezeOwned =
                (currentFreezeOwned + 1).clamp(0, currentFreezeMax).toInt();

            tx.set(streakRef, {
              'freezeOwned': nextFreezeOwned,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            return 'Freeze +1 hari berhasil ditukar.';

          case RewardKind.premiumSelf:
            final userSnap = await tx.get(userRef);
            final userData = userSnap.data() ?? {};
            final now = DateTime.now();

            tx.set(
              userRef,
              _buildPremiumActivationPatch(
                userData: userData,
                now: now,
                months: 1,
                planId: 'reward_self_1_month',
                source: 'reward_points',
              ),
              SetOptions(merge: true),
            );

            return 'Premium 1 bulan berhasil diaktifkan.';

          case RewardKind.premiumGift:
            final targetUid = giftedUserId?.trim() ?? '';
            if (targetUid.isEmpty) {
              throw Exception('User ID tujuan tidak boleh kosong.');
            }

            if (targetUid == uid) {
              throw Exception(
                'Gunakan penukaran premium biasa untuk dirimu sendiri.',
              );
            }

            final targetRef = _userRef(targetUid);
            final targetSnap = await tx.get(targetRef);

            if (!targetSnap.exists) {
              throw Exception('User ID tujuan tidak ditemukan.');
            }

            final targetData = targetSnap.data() ?? {};
            final now = DateTime.now();
            final giftPatch = _buildPremiumActivationPatch(
              userData: targetData,
              now: now,
              months: 1,
              planId: 'reward_gift_1_month',
              source: 'gift_points',
              giftedBy: uid,
            );

            tx.set(
              targetRef,
              giftPatch,
              SetOptions(merge: true),
            );

            final giftExpiresAt =
                giftPatch['premiumExpiresAt'] as Timestamp?;

            tx.set(
              _firestore.collection('premium_gifts').doc(),
              {
                'senderUid': uid,
                'receiverUid': targetUid,
                'itemId': itemId,
                'planId': 'reward_gift_1_month',
                'source': 'gift_points',
                'createdAt': FieldValue.serverTimestamp(),
                'expiresAt': giftExpiresAt,
              },
            );

            return 'Premium 1 bulan berhasil dikirim ke User ID tujuan.';
        }
      });

      return RewardRedeemResult(
        success: true,
        message: successMessage,
      );
    } catch (e) {
      return RewardRedeemResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<Map<String, dynamic>> getInventoryOnce() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return {};

    await _ensureInventoryExists(uid);
    final snap = await _inventoryRef(uid).get();
    return snap.data() ?? {};
  }

  Future<void> unlockBadges(List<String> badgeIds) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null || badgeIds.isEmpty) return;

    await _ensureInventoryExists(uid);

    await _inventoryRef(uid).set({
      'claimedBadgeIds': FieldValue.arrayUnion(badgeIds),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> setActiveFrame(String? frameId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _ensureInventoryExists(uid);

    await _inventoryRef(uid).set({
      'activeFrameId': frameId,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<Map<String, dynamic>> watchInventory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _inventoryRef(uid).snapshots().map((doc) => doc.data() ?? {});
  }
}