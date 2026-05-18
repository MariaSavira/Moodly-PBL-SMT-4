import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MoodlyUserAvatar extends StatelessWidget {
  final String? uid;
  final String? username;
  final String? photoUrl;
  final String? avatarAsset;
  final double radius;
  final double borderWidth;
  final Color borderColor;
  final Color backgroundColor;
  final String placeholderAsset;

  const MoodlyUserAvatar({
    super.key,
    this.uid,
    this.username,
    this.photoUrl,
    this.avatarAsset,
    this.radius = 22,
    this.borderWidth = 0,
    this.borderColor = Colors.transparent,
    this.backgroundColor = Colors.white,
    this.placeholderAsset =
        'assets/profile_pic/PP.png', // <- GANTI PLACEHOLDER GLOBAL DI SINI kalau mau
  });

  @override
  Widget build(BuildContext context) {
    if ((photoUrl ?? '').trim().isNotEmpty || (avatarAsset ?? '').trim().isNotEmpty) {
      return _buildAvatar(
        resolvedPhotoUrl: photoUrl,
        resolvedAvatarAsset: avatarAsset,
      );
    }

    if ((uid ?? '').trim().isNotEmpty) {
      return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data();
          return _buildAvatar(
            resolvedPhotoUrl: (data?['photoUrl'] as String?)?.trim(),
            resolvedAvatarAsset: (data?['avatarId'] as String?)?.trim(),
          );
        },
      );
    }

    if ((username ?? '').trim().isNotEmpty) {
      return FutureBuilder<_AvatarLookupResult>(
        future: _lookupByUsername(username!.trim()),
        builder: (context, snapshot) {
          final result = snapshot.data;
          return _buildAvatar(
            resolvedPhotoUrl: result?.photoUrl,
            resolvedAvatarAsset: result?.avatarAsset,
          );
        },
      );
    }

    return _buildAvatar();
  }

  Future<_AvatarLookupResult> _lookupByUsername(String username) async {
    final users = FirebaseFirestore.instance.collection('users');

    final byNickname = await users.where('nickname', isEqualTo: username).limit(1).get();
    if (byNickname.docs.isNotEmpty) {
      final data = byNickname.docs.first.data();
      return _AvatarLookupResult(
        photoUrl: (data['photoUrl'] as String?)?.trim(),
        avatarAsset: (data['avatarId'] as String?)?.trim(),
      );
    }

    final byFullName = await users.where('fullName', isEqualTo: username).limit(1).get();
    if (byFullName.docs.isNotEmpty) {
      final data = byFullName.docs.first.data();
      return _AvatarLookupResult(
        photoUrl: (data['photoUrl'] as String?)?.trim(),
        avatarAsset: (data['avatarId'] as String?)?.trim(),
      );
    }

    return const _AvatarLookupResult();
  }

  Widget _buildAvatar({
    String? resolvedPhotoUrl,
    String? resolvedAvatarAsset,
  }) {
    Widget child;

    if ((resolvedPhotoUrl ?? '').isNotEmpty) {
      child = Image.network(
        resolvedPhotoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          if ((resolvedAvatarAsset ?? '').isNotEmpty) {
            return Image.asset(
              resolvedAvatarAsset!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _placeholder(),
            );
          }
          return _placeholder();
        },
      );
    } else if ((resolvedAvatarAsset ?? '').isNotEmpty) {
      child = Image.asset(
        resolvedAvatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    } else {
      child = _placeholder();
    }

    return Container(
      width: radius * 2,
      height: radius * 2,
      padding: EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: borderColor,
      ),
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
        ),
        child: ClipOval(child: child),
      ),
    );
  }

  Widget _placeholder() {
    return Image.asset(
      placeholderAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFEDE7DC),
        alignment: Alignment.center,
        child: const Icon(
          Icons.person_rounded,
          color: Color(0xFF7A6E63),
        ),
      ),
    );
  }
}

class _AvatarLookupResult {
  final String? photoUrl;
  final String? avatarAsset;

  const _AvatarLookupResult({
    this.photoUrl,
    this.avatarAsset,
  });
}