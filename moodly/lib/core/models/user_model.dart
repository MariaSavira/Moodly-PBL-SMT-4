import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String role;
  final String? gender;
  final String preferredMatchGender;

  // legacy shortcut
  final bool isPremium;

  // legacy fields
  final DateTime? premiumActivatedAt;
  final DateTime? premiumExpiresAt;

  // new premium fields
  final String premiumTier; // free | premium | student
  final String premiumStatus; // inactive | active | expired | pending_student
  final String? premiumPlan; // monthly | semester | yearly | reward_self_1_month | dst
  final String? premiumSource; // manual | reward_points | gift_points | midtrans | student_email
  final String? premiumCampusEmail;
  final DateTime? premiumUpdatedAt;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.isEmailVerified = false,
    this.role = 'user',
    this.gender,
    this.preferredMatchGender = 'all',
    this.isPremium = false,
    this.premiumActivatedAt,
    this.premiumExpiresAt,
    this.premiumTier = 'free',
    this.premiumStatus = 'inactive',
    this.premiumPlan,
    this.premiumSource,
    this.premiumCampusEmail,
    this.premiumUpdatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    DateTime? parseDate(dynamic value) {
      if (value is Timestamp) return value.toDate();
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

    final bool legacyIsPremium = map['isPremium'] as bool? ?? false;
    final DateTime? activatedAt =
        parseDate(map['premiumActivatedAt'] ?? map['premiumStartAt']);
    final DateTime? expiresAt =
        parseDate(map['premiumExpiresAt'] ?? map['premiumEndAt']);
    final DateTime? updatedAt = parseDate(map['premiumUpdatedAt']);

    String premiumTier = (map['premiumTier'] as String?)?.trim() ?? 'free';
    String premiumStatus =
        (map['premiumStatus'] as String?)?.trim() ?? 'inactive';

    final bool expiredByDate =
        expiresAt != null && DateTime.now().isAfter(expiresAt);

    if (!map.containsKey('premiumTier') && legacyIsPremium) {
      premiumTier = 'premium';
    }

    if (!map.containsKey('premiumStatus')) {
      if (legacyIsPremium && !expiredByDate) {
        premiumStatus = 'active';
      } else if (expiredByDate) {
        premiumStatus = 'expired';
      } else {
        premiumStatus = 'inactive';
      }
    }

    final bool resolvedPremium =
        (premiumTier == 'premium' || premiumTier == 'student') &&
            premiumStatus == 'active' &&
            !expiredByDate;

    return UserModel(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: parseDate(map['createdAt']),
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      role: map['role'] as String? ?? 'user',
      gender: map['gender'] as String?,
      preferredMatchGender:
          (map['preferredMatchGender'] as String?)?.trim() ?? 'all',
      isPremium: resolvedPremium,
      premiumActivatedAt: activatedAt,
      premiumExpiresAt: expiresAt,
      premiumTier: premiumTier,
      premiumStatus: expiredByDate ? 'expired' : premiumStatus,
      premiumPlan: map['premiumPlan'] as String?,
      premiumSource: map['premiumSource'] as String?,
      premiumCampusEmail: map['premiumCampusEmail'] as String?,
      premiumUpdatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt?.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'role': role,
      'gender': gender,
      'preferredMatchGender': preferredMatchGender,
      'isPremium': isPremium,
      'premiumActivatedAt': premiumActivatedAt?.toIso8601String(),
      'premiumExpiresAt': premiumExpiresAt?.toIso8601String(),
      'premiumTier': premiumTier,
      'premiumStatus': premiumStatus,
      'premiumPlan': premiumPlan,
      'premiumSource': premiumSource,
      'premiumCampusEmail': premiumCampusEmail,
      'premiumUpdatedAt': premiumUpdatedAt?.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? uid,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? photoUrl,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? role,
    String? gender,
    String? preferredMatchGender,
    bool? isPremium,
    DateTime? premiumActivatedAt,
    DateTime? premiumExpiresAt,
    String? premiumTier,
    String? premiumStatus,
    String? premiumPlan,
    String? premiumSource,
    String? premiumCampusEmail,
    DateTime? premiumUpdatedAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      role: role ?? this.role,
      gender: gender ?? this.gender,
      preferredMatchGender:
          preferredMatchGender ?? this.preferredMatchGender,
      isPremium: isPremium ?? this.isPremium,
      premiumActivatedAt: premiumActivatedAt ?? this.premiumActivatedAt,
      premiumExpiresAt: premiumExpiresAt ?? this.premiumExpiresAt,
      premiumTier: premiumTier ?? this.premiumTier,
      premiumStatus: premiumStatus ?? this.premiumStatus,
      premiumPlan: premiumPlan ?? this.premiumPlan,
      premiumSource: premiumSource ?? this.premiumSource,
      premiumCampusEmail: premiumCampusEmail ?? this.premiumCampusEmail,
      premiumUpdatedAt: premiumUpdatedAt ?? this.premiumUpdatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel('
        'uid: $uid, '
        'fullName: $fullName, '
        'email: $email, '
        'role: $role, '
        'gender: $gender, '
        'preferredMatchGender: $preferredMatchGender, '
        'isPremium: $isPremium, '
        'premiumTier: $premiumTier, '
        'premiumStatus: $premiumStatus, '
        'premiumPlan: $premiumPlan'
        ')';
  }
}