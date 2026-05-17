import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  DocumentReference<Map<String, dynamic>> _streakRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('streak').doc('main');
  }

  DocumentReference<Map<String, dynamic>> _inventoryRef(String uid) {
    return _firestore.collection('users').doc(uid).collection('reward_inventory').doc('main');
  }

  Future<void> _ensureInventoryExists(String uid) async {
    final ref = _inventoryRef(uid);
    final snap = await ref.get();

    if (!snap.exists) {
      await ref.set({
        'ownedAvatarIds': <String>[],
        'ownedFrameIds': <String>[],
        'claimedBadgeIds': <String>[],
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
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

    final streakRef = _streakRef(uid);
    final inventoryRef = _inventoryRef(uid);

    try {
      await _firestore.runTransaction((tx) async {
        final streakSnap = await tx.get(streakRef);
        final inventorySnap = await tx.get(inventoryRef);

        final streakData = streakSnap.data() ?? {};
        final inventoryData = inventorySnap.data() ?? {};

        final totalPoints = (streakData['totalPoints'] ?? 0) as int;
        if (totalPoints < price) {
          throw Exception('Poinmu belum cukup.');
        }

        final ownedAvatarIds =
            List<String>.from(inventoryData['ownedAvatarIds'] ?? []);
        final ownedFrameIds =
            List<String>.from(inventoryData['ownedFrameIds'] ?? []);

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
            break;

          case RewardKind.frame:
            ownedFrameIds.add(itemId);
            tx.set(inventoryRef, {
              'ownedFrameIds': ownedFrameIds,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            break;

          case RewardKind.freeze:
            final freezeOwned = (streakData['freezeOwned'] ?? 1) as int;
            final freezeMax = (streakData['freezeMax'] ?? 10) as int;
            final nextFreeze = (freezeOwned + 1).clamp(0, freezeMax);

            tx.set(streakRef, {
              'freezeOwned': nextFreeze,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            break;

          case RewardKind.premiumSelf:
            final userRef = _firestore.collection('users').doc(uid);
            final now = DateTime.now();
            final expiresAt = now.add(const Duration(days: 30));

            tx.set(userRef, {
              'isPremium': true,
              'premiumActivatedAt': Timestamp.fromDate(now),
              'premiumExpiresAt': Timestamp.fromDate(expiresAt),
              'premiumSource': 'reward_self',
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));
            break;

          case RewardKind.premiumGift:
            if (giftedUserId == null || giftedUserId.trim().isEmpty) {
              throw Exception('User ID tujuan tidak boleh kosong.');
            }

            if (giftedUserId.trim() == uid) {
              throw Exception('Gunakan penukaran premium biasa untuk dirimu sendiri.');
            }

            final targetRef = _firestore.collection('users').doc(giftedUserId.trim());
            final targetSnap = await tx.get(targetRef);

            if (!targetSnap.exists) {
              throw Exception('User ID tujuan tidak ditemukan.');
            }

            final now = DateTime.now();
            final expiresAt = now.add(const Duration(days: 30));

            tx.set(targetRef, {
              'isPremium': true,
              'premiumActivatedAt': Timestamp.fromDate(now),
              'premiumExpiresAt': Timestamp.fromDate(expiresAt),
              'premiumSource': 'reward_gift',
              'giftedBy': uid,
              'updatedAt': FieldValue.serverTimestamp(),
            }, SetOptions(merge: true));

            tx.set(
              _firestore.collection('premium_gifts').doc(),
              {
                'senderUid': uid,
                'receiverUid': giftedUserId.trim(),
                'itemId': itemId,
                'createdAt': FieldValue.serverTimestamp(),
              },
            );
            break;
        }
      });

      return const RewardRedeemResult(
        success: true,
        message: 'Reward berhasil ditukar.',
      );
    } catch (e) {
      return RewardRedeemResult(
        success: false,
        message: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Stream<Map<String, dynamic>> watchInventory() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _inventoryRef(uid).snapshots().map((doc) => doc.data() ?? {});
  }
}