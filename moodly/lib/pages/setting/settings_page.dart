import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../../main.dart';
import '../pages.dart';

import 'theme_page.dart';
import 'language_page.dart';
import 'notification_settings_page.dart';
import 'report_history_page.dart';
import 'terms_conditions_page.dart';

const Color _settingsBg = Color(0xFFF4F8EA);
const Color _settingsCard = Colors.white;
const Color _settingsGreenDark = Color(0xFF5E9E49);
const Color _settingsGreenSoft = Color(0xFFDDEFCF);
const Color _settingsMintSoft = Color(0xFFE9F7E8);
const Color _settingsPinkSoft = Color(0xFFFFEEF2);
const Color _settingsTextDark = Color(0xFF1F1F1F);
const Color _settingsTextSoft = Color(0xFF6F746E);
const Color _settingsBrand = Color(0xFFC65F59);

List<BoxShadow> get _settingsShadow => const [
      BoxShadow(
        color: Color.fromRGBO(0, 0, 0, 0.08),
        offset: Offset(0, 8),
        blurRadius: 20,
      ),
    ];

TextStyle? _sh1(BuildContext context, {Color color = _settingsTextDark}) {
  return Theme.of(context).textTheme.headlineLarge?.copyWith(color: color);
}

TextStyle? _sh2(BuildContext context, {Color color = _settingsTextDark}) {
  return Theme.of(context).textTheme.titleMedium?.copyWith(color: color);
}

TextStyle? _sbody(BuildContext context, {Color color = _settingsTextSoft}) {
  return Theme.of(context).textTheme.bodyMedium?.copyWith(color: color);
}

TextStyle? _sbodyAlt(BuildContext context, {Color color = _settingsTextDark}) {
  return Theme.of(context).textTheme.bodySmall?.copyWith(color: color);
}

TextStyle? _sbutton(BuildContext context, {Color color = Colors.white}) {
  return Theme.of(context).textTheme.labelLarge?.copyWith(color: color);
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
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
              color: _settingsPinkSoft.withOpacity(0.7),
            ),
          ),
        ),
        Positioned(
          top: 250,
          left: -70,
          child: Container(
            width: 170,
            height: 170,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _settingsMintSoft.withOpacity(0.85),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -60,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _settingsGreenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: _settingsBg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.warning_rounded,
                  color: Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 14),
                Text(
                  'Apakah Anda yakin ingin\nkeluar dari akun Anda?',
                  textAlign: TextAlign.center,
                  style: _sh2(context, color: _settingsTextDark),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _SettingsDialogButton(
                        label: 'Batal',
                        color: _settingsGreenSoft,
                        textColor: _settingsTextDark,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SettingsDialogButton(
                        label: 'Keluar',
                        color: const Color(0xFFFFD7DD),
                        textColor: _settingsTextDark,
                        onTap: () async {
                          Navigator.pop(context);

                          try {
                            await AuthService.instance.signOut();

                            if (!context.mounted) return;

                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (_) => const RootPage(),
                              ),
                              (route) => false,
                            );
                          } catch (_) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Logout gagal. Coba lagi sebentar.',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);

    if (FirebaseAuth.instance.currentUser == null) {
      return const RootPage();
    }

    return Scaffold(
      backgroundColor: _settingsBg,
      body: Stack(
        children: [
          _background(),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsHeader(onBack: () => Navigator.pop(context)),
                      const SizedBox(height: 22),
                      _SettingsProfileCard(
                        onEdit: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const EditProfilePage(),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      _SettingsSection(
                        title: 'Pengaturan Akun',
                        children: [
                          _SettingsItem(
                            icon: Icons.account_circle_rounded,
                            iconColor: _settingsGreenDark,
                            title: 'Profil',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage(),
                                ),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.shield_rounded,
                            iconColor: _settingsGreenDark,
                            title: 'Keamanan',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecurityPage(),
                                ),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.error_outline_rounded,
                            iconColor: _settingsGreenDark,
                            title: 'Riwayat Pelapor',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReportHistoryPage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: 'Preferensi Aplikasi',
                        children: [
                          _SettingsItem(
                            icon: Icons.notifications_rounded,
                            iconColor: const Color(0xFFE08C9B),
                            title: 'Notifikasi',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsPage(),
                                ),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.palette_outlined,
                            iconColor: const Color(0xFFE08C9B),
                            title: 'Tema',
                            subtitle: 'Mode Terang',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ThemePage(),
                                ),
                              );
                            },
                          ),
                          _SettingsItem(
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFFE08C9B),
                            title: 'Bahasa',
                            subtitle: 'Indonesia',
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LanguagePage(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: 'Tentang',
                        children: [
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            iconColor: _settingsTextSoft,
                            title: 'Syarat & Ketentuan',
                            trailing: const Icon(
                              Icons.open_in_new_rounded,
                              color: _settingsTextSoft,
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TermsConditionsPage(),
                                ),
                              );
                            },
                          ),
                          _SettingsLogoutItem(
                            onTap: () => _showLogoutDialog(context),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  final VoidCallback onBack;

  const _SettingsHeader({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back_rounded,
            color: _settingsGreenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          'Pengaturan',
          style: _sh2(context, color: _settingsGreenDark),
        ),
        const Spacer(),
        Text(
          'Moodly',
          style: _sh1(context, color: _settingsBrand),
        ),
      ],
    );
  }
}

class _SettingsProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const _SettingsProfileCard({required this.onEdit});

  String _resolveName(Map<String, dynamic>? data, User? user) {
    final fullName = (data?['fullName'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return 'Pengguna Moodly';
  }

  String _resolveSubtitle(Map<String, dynamic>? data, User? user) {
    final email = (data?['email'] as String?)?.trim() ?? user?.email?.trim();
    if (email != null && email.isNotEmpty) return email;

    final role = (data?['role'] as String?)?.trim();
    if (role != null && role.isNotEmpty) return role;

    return 'Moodly Member';
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

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      return _SettingsProfileContent(
        name: 'Pengguna Moodly',
        subtitle: 'Belum login',
        photoUrl: null,
        avatarAsset: null,
        onEdit: onEdit,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();
        final avatarAsset = _resolveAvatarAsset(data);

        return _SettingsProfileContent(
          name: _resolveName(data, user),
          subtitle: _resolveSubtitle(data, user),
          photoUrl: _resolvePhotoUrl(data, user),
          avatarAsset: avatarAsset,
          onEdit: onEdit,
        );
      },
    );
  }
}

class _SettingsProfileContent extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? photoUrl;
  final String? avatarAsset;
  final VoidCallback onEdit;

  const _SettingsProfileContent({
    required this.name,
    required this.subtitle,
    required this.photoUrl,
    required this.avatarAsset,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: _settingsCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _settingsShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF92D373), Color(0xFFD9EDC5)],
              ),
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: ClipOval(
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) {
                          if (avatarAsset != null && avatarAsset!.isNotEmpty) {
                            return Image.asset(
                              avatarAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.person_rounded,
                                  color: _settingsTextDark,
                                  size: 34,
                                ),
                              ),
                            );
                          }

                          return const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: _settingsTextDark,
                              size: 34,
                            ),
                          );
                        },
                      )
                    : avatarAsset != null && avatarAsset!.isNotEmpty
                        ? Image.asset(
                            avatarAsset!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Center(
                              child: Icon(
                                Icons.person_rounded,
                                color: _settingsTextDark,
                                size: 34,
                              ),
                            ),
                          )
                        : const Center(
                            child: Icon(
                              Icons.person_rounded,
                              color: _settingsTextDark,
                              size: 34,
                            ),
                          ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _sh2(context, color: _settingsTextDark),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: _sbody(context),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _settingsPinkSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: _settingsGreenDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: _settingsCard,
        borderRadius: BorderRadius.circular(28),
        boxShadow: _settingsShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: _sh2(context, color: _settingsGreenDark)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: subtitle == null ? _settingsMintSoft : _settingsPinkSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        style: _sbodyAlt(context, color: _settingsTextDark),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: _sbodyAlt(context, color: _settingsTextDark),
                          ),
                          const SizedBox(height: 2),
                          Text(subtitle!, style: _sbody(context)),
                        ],
                      ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: _settingsTextDark,
                    size: 16,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingsLogoutItem extends StatelessWidget {
  final VoidCallback onTap;

  const _SettingsLogoutItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFEEF1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Keluar',
                style: _sbodyAlt(context, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsDialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _SettingsDialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Center(
          child: Text(label, style: _sbutton(context, color: textColor)),
        ),
      ),
    );
  }
}