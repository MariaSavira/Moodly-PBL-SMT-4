import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/premium_access_model.dart';

class PremiumService {
  PremiumService._();

  static final PremiumService instance = PremiumService._();

  FirebaseFirestore get _firestore => FirebaseFirestore.instance;
  FirebaseAuth get _auth => FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _userDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid);
  }

  Stream<PremiumAccessModel> watchAccess() {
    final doc = _userDoc;
    if (doc == null) {
      return Stream.value(PremiumAccessModel.empty());
    }

    return doc.snapshots().map((snapshot) {
      return PremiumAccessModel.fromUserMap(snapshot.data());
    });
  }

  Future<PremiumAccessModel> getAccess() async {
    final doc = _userDoc;
    if (doc == null) return PremiumAccessModel.empty();

    final snapshot = await doc.get();
    final access = PremiumAccessModel.fromUserMap(snapshot.data());

    if (_needsExpirySync(access)) {
      await _writeExpiredState(doc, access);
      return access.copyWith(
        isPremium: false,
        status: PremiumStatus.expired,
        tier: access.tier == PremiumTier.free ? PremiumTier.free : access.tier,
      );
    }

    return access;
  }

  Future<bool> hasActivePremium() async {
    final access = await getAccess();
    return access.hasPremiumAccess;
  }

  Future<void> refreshPremiumStatus() async {
    final doc = _userDoc;
    if (doc == null) return;

    final snapshot = await doc.get();
    final access = PremiumAccessModel.fromUserMap(snapshot.data());

    if (_needsExpirySync(access)) {
      await _writeExpiredState(doc, access);
    }
  }

  Future<void> activatePremium({
    required int months,
    required String planId,
    String source = 'manual',
    PremiumTier tier = PremiumTier.premium,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;

    final now = DateTime.now();
    final end = _addMonths(now, months);

    final access = PremiumAccessModel(
      isPremium: true,
      tier: tier,
      status: PremiumStatus.active,
      planId: planId,
      source: source,
      activatedAt: now,
      expiresAt: end,
      updatedAt: now,
    );

    await doc.set(access.toUserMap(), SetOptions(merge: true));
  }

  Future<void> activateStudentPremium({
    required int months,
    required String planId,
    required String campusEmail,
    String source = 'student_email',
  }) async {
    final doc = _userDoc;
    if (doc == null) return;

    final now = DateTime.now();
    final end = _addMonths(now, months);

    final access = PremiumAccessModel(
      isPremium: true,
      tier: PremiumTier.student,
      status: PremiumStatus.active,
      planId: planId,
      source: source,
      campusEmail: campusEmail.trim(),
      activatedAt: now,
      expiresAt: end,
      updatedAt: now,
    );

    await doc.set(access.toUserMap(), SetOptions(merge: true));
  }

  Future<void> markStudentPending({
    required String campusEmail,
  }) async {
    final doc = _userDoc;
    if (doc == null) return;

    final access = PremiumAccessModel(
      isPremium: false,
      tier: PremiumTier.student,
      status: PremiumStatus.pendingStudent,
      planId: null,
      source: 'student_email',
      campusEmail: campusEmail.trim(),
      activatedAt: null,
      expiresAt: null,
      updatedAt: DateTime.now(),
    );

    await doc.set(access.toUserMap(), SetOptions(merge: true));
  }

  Future<void> clearPremium() async {
    final doc = _userDoc;
    if (doc == null) return;

    final access = PremiumAccessModel(
      isPremium: false,
      tier: PremiumTier.free,
      status: PremiumStatus.inactive,
      planId: null,
      source: null,
      campusEmail: null,
      activatedAt: null,
      expiresAt: null,
      updatedAt: DateTime.now(),
    );

    await doc.set(access.toUserMap(), SetOptions(merge: true));
  }

  Future<void> grantGiftPremium({
    required String targetUid,
    required int months,
    required String planId,
    String source = 'gift_points',
  }) async {
    final userDoc = _firestore.collection('users').doc(targetUid);

    final now = DateTime.now();
    final currentSnapshot = await userDoc.get();
    final currentAccess = PremiumAccessModel.fromUserMap(currentSnapshot.data());

    DateTime start = now;
    if (currentAccess.hasPremiumAccess && currentAccess.expiresAt != null) {
      final stillActiveUntil = currentAccess.expiresAt!;
      if (stillActiveUntil.isAfter(now)) {
        start = stillActiveUntil;
      }
    }

    final end = _addMonths(start, months);

    final access = PremiumAccessModel(
      isPremium: true,
      tier: PremiumTier.premium,
      status: PremiumStatus.active,
      planId: planId,
      source: source,
      activatedAt: currentAccess.activatedAt ?? now,
      expiresAt: end,
      updatedAt: now,
    );

    await userDoc.set(access.toUserMap(), SetOptions(merge: true));
  }

  Future<void> syncLegacyPremiumFromFirestore() async {
    final doc = _userDoc;
    if (doc == null) return;

    final snapshot = await doc.get();
    final access = PremiumAccessModel.fromUserMap(snapshot.data());

    await doc.set(access.toUserMap(), SetOptions(merge: true));
  }

  bool _needsExpirySync(PremiumAccessModel access) {
    return access.isExpired &&
        access.status != PremiumStatus.expired &&
        access.tier != PremiumTier.free;
  }

  Future<void> _writeExpiredState(
    DocumentReference<Map<String, dynamic>> doc,
    PremiumAccessModel current,
  ) async {
    final patch = current.copyWith(
      isPremium: false,
      status: PremiumStatus.expired,
    );

    await doc.set(patch.toUserMap(), SetOptions(merge: true));
  }

  DateTime _addMonths(DateTime date, int monthsToAdd) {
    final int totalMonths = (date.month - 1) + monthsToAdd;
    final int year = date.year + (totalMonths ~/ 12);
    final int month = (totalMonths % 12) + 1;

    final int lastDayOfTargetMonth = DateTime(year, month + 1, 0).day;
    final int day = date.day > lastDayOfTargetMonth
        ? lastDayOfTargetMonth
        : date.day;

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
}