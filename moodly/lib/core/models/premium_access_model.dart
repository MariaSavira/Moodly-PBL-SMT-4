import 'package:cloud_firestore/cloud_firestore.dart';

enum PremiumTier {
  free,
  premium,
  student,
}

enum PremiumStatus {
  inactive,
  active,
  expired,
  pendingStudent,
}

DateTime? _parsePremiumDate(dynamic value) {
  if (value == null) return null;
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

String premiumTierToValue(PremiumTier tier) {
  switch (tier) {
    case PremiumTier.free:
      return 'free';
    case PremiumTier.premium:
      return 'premium';
    case PremiumTier.student:
      return 'student';
  }
}

PremiumTier premiumTierFromValue(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'premium':
      return PremiumTier.premium;
    case 'student':
      return PremiumTier.student;
    default:
      return PremiumTier.free;
  }
}

String premiumStatusToValue(PremiumStatus status) {
  switch (status) {
    case PremiumStatus.inactive:
      return 'inactive';
    case PremiumStatus.active:
      return 'active';
    case PremiumStatus.expired:
      return 'expired';
    case PremiumStatus.pendingStudent:
      return 'pending_student';
  }
}

PremiumStatus premiumStatusFromValue(String? raw) {
  switch ((raw ?? '').trim().toLowerCase()) {
    case 'active':
      return PremiumStatus.active;
    case 'expired':
      return PremiumStatus.expired;
    case 'pending_student':
      return PremiumStatus.pendingStudent;
    default:
      return PremiumStatus.inactive;
  }
}

class PremiumAccessModel {
  final bool isPremium;
  final PremiumTier tier;
  final PremiumStatus status;
  final String? planId;
  final String? source;
  final String? campusEmail;
  final DateTime? activatedAt;
  final DateTime? expiresAt;
  final DateTime? updatedAt;

  const PremiumAccessModel({
    required this.isPremium,
    required this.tier,
    required this.status,
    this.planId,
    this.source,
    this.campusEmail,
    this.activatedAt,
    this.expiresAt,
    this.updatedAt,
  });

  factory PremiumAccessModel.empty() {
    return const PremiumAccessModel(
      isPremium: false,
      tier: PremiumTier.free,
      status: PremiumStatus.inactive,
    );
  }

  factory PremiumAccessModel.fromUserMap(Map<String, dynamic>? map) {
    if (map == null) return PremiumAccessModel.empty();

    final bool legacyIsPremium = map['isPremium'] == true;

    final DateTime? activatedAt = _parsePremiumDate(
      map['premiumActivatedAt'] ?? map['premiumStartAt'],
    );
    final DateTime? expiresAt = _parsePremiumDate(
      map['premiumExpiresAt'] ?? map['premiumEndAt'],
    );
    final DateTime? updatedAt = _parsePremiumDate(map['premiumUpdatedAt']);

    PremiumTier tier = premiumTierFromValue(map['premiumTier'] as String?);
    PremiumStatus status =
        premiumStatusFromValue(map['premiumStatus'] as String?);

    final bool hasExplicitTier = map.containsKey('premiumTier');
    final bool hasExplicitStatus = map.containsKey('premiumStatus');
    final bool expiredByDate =
        expiresAt != null && DateTime.now().isAfter(expiresAt);

    if (!hasExplicitTier && legacyIsPremium) {
      tier = PremiumTier.premium;
    }

    if (!hasExplicitStatus) {
      if (legacyIsPremium && !expiredByDate) {
        status = PremiumStatus.active;
      } else if (expiredByDate) {
        status = PremiumStatus.expired;
      } else {
        status = PremiumStatus.inactive;
      }
    }

    if (status == PremiumStatus.active && expiredByDate) {
      status = PremiumStatus.expired;
    }

    if (tier == PremiumTier.free &&
        status == PremiumStatus.active &&
        legacyIsPremium) {
      tier = PremiumTier.premium;
    }

    final bool resolvedIsPremium =
        (tier == PremiumTier.premium || tier == PremiumTier.student) &&
            status == PremiumStatus.active &&
            !expiredByDate;

    return PremiumAccessModel(
      isPremium: resolvedIsPremium,
      tier: tier,
      status: status,
      planId: (map['premiumPlan'] as String?)?.trim(),
      source: (map['premiumSource'] as String?)?.trim(),
      campusEmail: (map['premiumCampusEmail'] as String?)?.trim(),
      activatedAt: activatedAt,
      expiresAt: expiresAt,
      updatedAt: updatedAt,
    );
  }

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  bool get hasPremiumAccess =>
      !isExpired &&
      status == PremiumStatus.active &&
      (tier == PremiumTier.premium || tier == PremiumTier.student);

  bool get isStudentPending =>
      tier == PremiumTier.student &&
      status == PremiumStatus.pendingStudent;

  bool get canOpenMoodAnalysisAnytime => hasPremiumAccess;
  bool get canUseGenderFilter => hasPremiumAccess;
  bool get canUsePremiumAffirmations => hasPremiumAccess;
  bool get canUseAdvancedMoodStats => hasPremiumAccess;
  bool get canUsePremiumStreakBenefits => hasPremiumAccess;

  Map<String, dynamic> toUserMap() {
    return {
      'isPremium': hasPremiumAccess,
      'premiumTier': premiumTierToValue(tier),
      'premiumStatus': premiumStatusToValue(
        isExpired && status == PremiumStatus.active
            ? PremiumStatus.expired
            : status,
      ),
      'premiumPlan': planId,
      'premiumSource': source,
      'premiumCampusEmail': campusEmail,
      'premiumActivatedAt':
          activatedAt != null ? Timestamp.fromDate(activatedAt!) : null,
      'premiumExpiresAt':
          expiresAt != null ? Timestamp.fromDate(expiresAt!) : null,
      'premiumUpdatedAt': FieldValue.serverTimestamp(),
    };
  }

  PremiumAccessModel copyWith({
    bool? isPremium,
    PremiumTier? tier,
    PremiumStatus? status,
    String? planId,
    String? source,
    String? campusEmail,
    DateTime? activatedAt,
    DateTime? expiresAt,
    DateTime? updatedAt,
  }) {
    return PremiumAccessModel(
      isPremium: isPremium ?? this.isPremium,
      tier: tier ?? this.tier,
      status: status ?? this.status,
      planId: planId ?? this.planId,
      source: source ?? this.source,
      campusEmail: campusEmail ?? this.campusEmail,
      activatedAt: activatedAt ?? this.activatedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'PremiumAccessModel('
        'isPremium: $isPremium, '
        'tier: ${premiumTierToValue(tier)}, '
        'status: ${premiumStatusToValue(status)}, '
        'planId: $planId, '
        'source: $source, '
        'activatedAt: $activatedAt, '
        'expiresAt: $expiresAt'
        ')';
  }
}