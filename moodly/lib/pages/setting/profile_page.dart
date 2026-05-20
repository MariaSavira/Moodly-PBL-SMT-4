import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/streak_service.dart';
import '../pages.dart';

const Color _profileBg = Color(0xFFF4F8EA);
const Color _profileCard = Colors.white;
const Color _profileGreen = Color(0xFF7BC25D);
const Color _profileGreenDark = Color(0xFF5E9E49);
const Color _profileGreenSoft = Color(0xFFDDEFCF);
const Color _profileMintSoft = Color(0xFFE9F7E8);
const Color _profilePinkSoft = Color(0xFFFFEEF2);
const Color _profilePeachSoft = Color(0xFFFFE9DD);
const Color _profileTextDark = Color(0xFF1F1F1F);
const Color _profileTextSoft = Color(0xFF6F746E);
const Color _profileBrand = Color(0xFFC65F59);

List<BoxShadow> get _profileShadow => const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 8),
        blurRadius: 20,
      ),
    ];

TextStyle _titleLarge(BuildContext context, {Color color = _profileTextDark}) {
  return TextStyle(
    color: color,
    fontSize: MediaQuery.of(context).size.width < 380 ? 22 : 24,
    fontWeight: FontWeight.w800,
  );
}

TextStyle _titleMedium(BuildContext context, {Color color = _profileTextDark}) {
  return TextStyle(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );
}

TextStyle _body(BuildContext context, {Color color = _profileTextSoft}) {
  return TextStyle(
    color: color,
    fontSize: 13,
    height: 1.35,
    fontWeight: FontWeight.w500,
  );
}

TextStyle _button(BuildContext context, {Color color = Colors.white}) {
  return TextStyle(
    color: color,
    fontSize: 16,
    fontWeight: FontWeight.w800,
  );
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  double _maxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  String _badgeTitleFor(int streak) {
    if (streak >= 120) return 'Tumbuh dengan Tenang';
    if (streak >= 30) return 'Menjaga Diri dengan Setia';
    if (streak >= 14) return 'Tumbuh Pelan-Pelan';
    if (streak >= 7) return 'Teman Diri Sendiri';
    if (streak >= 3) return 'Mulai Konsisten';
    return 'Belum ada badge';
  }

  String _resolveName(Map<String, dynamic>? data, User? user) {
    final fullName = (data?['fullName'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'Pengguna Moodly';
  }

  String _resolveEmail(Map<String, dynamic>? data, User? user) {
    final email = (data?['email'] as String?)?.trim() ?? user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;
    return '-';
  }

  String? _resolvePhotoUrl(Map<String, dynamic>? data, User? user) {
    final photoUrl = (data?['photoUrl'] as String?)?.trim();
    if (photoUrl != null && photoUrl.isNotEmpty) return photoUrl;

    final authPhoto = user?.photoURL?.trim();
    if (authPhoto != null && authPhoto.isNotEmpty) return authPhoto;

    return null;
  }

  String? _resolveAvatarAsset(Map<String, dynamic>? data) {
    final avatarId = (data?['avatarId'] as String?)?.trim();
    if (avatarId != null && avatarId.isNotEmpty) return avatarId;
    return null;
  }

  String _resolvePhone(Map<String, dynamic>? data) {
    final phone = (data?['phoneNumber'] as String?)?.trim();
    if (phone != null && phone.isNotEmpty) return phone;
    return 'Belum ditambahkan';
  }

  String _providerLabel(User? user) {
    if (user == null) return '-';

    final ids = user.providerData.map((e) => e.providerId).toList();

    if (ids.contains('google.com')) return 'Google';
    if (ids.contains('facebook.com')) return 'Facebook';
    if (ids.contains('password')) return 'Email';
    if (user.isAnonymous) return 'Anonim';

    return 'Firebase';
  }

  DateTime? _parseCreatedAt(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  Widget _background() {
    return Stack(
      children: [
        Positioned(
          top: -30,
          right: -30,
          child: Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _profilePinkSoft.withOpacity(0.7),
            ),
          ),
        ),
        Positioned(
          top: 240,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _profileMintSoft.withOpacity(0.85),
            ),
          ),
        ),
        Positioned(
          bottom: 90,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _profileGreenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final maxWidth = _maxWidth(context);
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    return Scaffold(
      backgroundColor: _profileBg,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: maxWidth,
                child: uid == null
                    ? Center(
                        child: Text(
                          'Tidak ada user yang sedang login.',
                          style: _body(context),
                        ),
                      )
                    : StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(uid)
                            .snapshots(),
                        builder: (context, snapshot) {
                          final data = snapshot.data?.data();

                          final name = _resolveName(data, user);
                          final email = _resolveEmail(data, user);
                          final photoUrl = _resolvePhotoUrl(data, user);
                          final avatarAsset = _resolveAvatarAsset(data);
                          final phone = _resolvePhone(data);
                          final isVerified =
                              (data?['isEmailVerified'] as bool?) ??
                                  (user?.emailVerified ?? false);
                          final role =
                              ((data?['role'] as String?) ?? 'user').trim();
                          final createdAt =
                              _parseCreatedAt(data?['createdAt']);
                          final provider = _providerLabel(user);

                          return SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _ProfileHeader(
                                  onBack: () => Navigator.pop(context),
                                ),
                                const SizedBox(height: 22),
                                _ProfileHeroCard(
                                  name: name,
                                  email: email,
                                  photoUrl: photoUrl,
                                  avatarAsset: avatarAsset,
                                  isVerified: isVerified,
                                  provider: provider,
                                  onEdit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const EditProfilePage(),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 14),
                                StreamBuilder<StreakState>(
                                  stream: StreakService.instance.watchState(),
                                  builder: (context, snapshot) {
                                    final streak =
                                        snapshot.data ?? StreakState.initial();
                                    final badgeTitle =
                                        _badgeTitleFor(streak.currentStreak);

                                    return _BadgeCard(
                                      badgeTitle: badgeTitle,
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniProfileCard(
                                        icon: Icons.verified_user_rounded,
                                        iconColor: _profileGreenDark,
                                        value: isVerified ? 'Ya' : 'Tidak',
                                        label: 'Status verifikasi',
                                        bg: _profileMintSoft,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _MiniProfileCard(
                                        icon: Icons.login_rounded,
                                        iconColor: const Color(0xFFE08C9B),
                                        value: provider,
                                        label: 'Metode login',
                                        bg: _profilePinkSoft,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _AccountSummaryCard(
                                  joinedDate: _formatDate(createdAt),
                                  role: role,
                                  phone: phone,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _ProfileHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: _profileGreenDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        const Text(
          'Profil',
          style: TextStyle(
            color: _profileGreenDark,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          'Moodly',
          style: TextStyle(
            color: _profileBrand,
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _ProfileHeroCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final String? avatarAsset;
  final bool isVerified;
  final String provider;
  final VoidCallback onEdit;

  const _ProfileHeroCard({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.avatarAsset,
    required this.isVerified,
    required this.provider,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(30),
        boxShadow: _profileShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: onEdit,
            child: _ProfileAvatar(
              photoUrl: photoUrl,
              avatarAsset: avatarAsset,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: _titleLarge(context),
          ),
          const SizedBox(height: 6),
          Text(
            email,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: _body(context),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _InfoChip(
                icon: Icons.verified_rounded,
                label: isVerified
                    ? 'Email terverifikasi'
                    : 'Email belum verifikasi',
                bg: _profileGreenSoft,
                fg: _profileGreenDark,
              ),
              _InfoChip(
                icon: Icons.login_rounded,
                label: provider,
                bg: _profilePinkSoft,
                fg: const Color(0xFFB56E7B),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onEdit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _profileGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Ubah Profil', style: _button(context)),
                  const SizedBox(width: 10),
                  const Icon(Icons.arrow_forward_rounded),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final String? avatarAsset;

  const _ProfileAvatar({
    required this.photoUrl,
    required this.avatarAsset,
  });

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (photoUrl != null && photoUrl!.isNotEmpty) {
      child = Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          if (avatarAsset != null && avatarAsset!.isNotEmpty) {
            return Image.asset(
              avatarAsset!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.person_rounded,
                size: 74,
                color: _profileTextDark,
              ),
            );
          }
          return const Icon(
            Icons.person_rounded,
            size: 74,
            color: _profileTextDark,
          );
        },
      );
    } else if (avatarAsset != null && avatarAsset!.isNotEmpty) {
      child = Image.asset(
        avatarAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(
          Icons.person_rounded,
          size: 74,
          color: _profileTextDark,
        ),
      );
    } else {
      child = const Icon(
        Icons.person_rounded,
        size: 74,
        color: _profileTextDark,
      );
    }

    return SizedBox(
      width: 132,
      height: 132,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 132,
            height: 132,
            padding: const EdgeInsets.all(6),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF92D373), Color(0xFFD9EDC5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(child: child),
            ),
          ),
          Positioned(
            right: 4,
            bottom: 4,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _profilePinkSoft,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: _profileGreenDark,
                size: 22,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final String badgeTitle;

  const _BadgeCard({required this.badgeTitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(24),
        boxShadow: _profileShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _profilePinkSoft,
            ),
            child: const Icon(
              Icons.workspace_premium_rounded,
              color: _profileBrand,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Badge Milestone', style: _body(context)),
                const SizedBox(height: 4),
                Text(
                  badgeTitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: _titleMedium(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color fg;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: fg,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniProfileCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final Color bg;

  const _MiniProfileCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.bg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 126,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(value, style: _titleLarge(context)),
          ),
          const SizedBox(height: 4),
          Text(label, style: _body(context)),
        ],
      ),
    );
  }
}

class _AccountSummaryCard extends StatelessWidget {
  final String joinedDate;
  final String role;
  final String phone;

  const _AccountSummaryCard({
    required this.joinedDate,
    required this.role,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _profileCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _profileShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Ringkasan Akun', style: _titleLarge(context)),
          const SizedBox(height: 16),
          _SummaryRow(
            title: 'Bergabung sejak',
            value: joinedDate,
            tint: _profilePeachSoft,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            title: 'Role akun',
            value: role,
            tint: _profileMintSoft,
          ),
          const SizedBox(height: 10),
          _SummaryRow(
            title: 'Nomor telepon',
            value: phone,
            tint: _profilePinkSoft,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final Color tint;

  const _SummaryRow({
    required this.title,
    required this.value,
    required this.tint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: _body(context))),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _titleMedium(context),
            ),
          ),
        ],
      ),
    );
  }
}