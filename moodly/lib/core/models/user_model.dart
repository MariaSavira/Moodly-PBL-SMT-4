class UserModel {
  final String uid;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? photoUrl;
  final DateTime? createdAt;
  final bool isEmailVerified;
  final String role;

  const UserModel({
    required this.uid,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.photoUrl,
    this.createdAt,
    this.isEmailVerified = false,
    this.role = 'user',
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString())
          : null,
      isEmailVerified: map['isEmailVerified'] as bool? ?? false,
      role: map['role'] as String? ?? 'user',
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
    );
  }

  @override
  String toString() {
    return 'UserModel(uid: $uid, fullName: $fullName, email: $email, isEmailVerified: $isEmailVerified, role: $role)';
  }
}