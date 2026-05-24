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

const Color _bg = Color(0xFFF4F8EA);
const Color _green = Color(0xFF80C96F);
const Color _greenDark = Color(0xFF5E9E49);
const Color _panel = Color(0xFFE5F5D4);
const Color _brand = Color(0xFFC65F59);
const Color _textDark = Color(0xFF202020);
const Color _textSoft = Color(0xFF7E7E7E);
const Color _pink = Color(0xFFF5AFC0);

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 1200) return 520;
    if (width > 800) return 500;
    if (width > 600) return 470;

    return width;
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 380) {
      return const EdgeInsets.fromLTRB(18, 16, 18, 24);
    }

    return const EdgeInsets.fromLTRB(24, 18, 24, 28);
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
          backgroundColor: _bg,
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
                const Text(
                  'Apakah Anda yakin ingin\nkeluar dari akun Anda?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: _textDark,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: 'Batal',
                        color: const Color(0xFFDDEFCF),
                        textColor: _textDark,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: 'Keluar',
                        color: const Color(0xFFFFD7DD),
                        textColor: _textDark,
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
    if (FirebaseAuth.instance.currentUser == null) {
      return const RootPage();
    }

    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 380;

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
                            title: 'Laporan & Banding',
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
                            onTap: () {},
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

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Row(
            children: [
              Icon(
                Icons.arrow_back_rounded,
                color: _greenDark,
                size: isSmall ? 20 : 22,
              ),
              const SizedBox(width: 4),
              Text(
                'Settings',
                style: TextStyle(
                  color: _greenDark,
                  fontSize: isSmall ? 15 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          'Moodly',
          style: TextStyle(
            color: _brand,
            fontSize: isSmall ? 30 : 34,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const _ProfileCard({required this.onEdit});

  String _resolveName(Map<String, dynamic>? data, User? user) {
    final fullName = (data?['fullName'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) return email.split('@').first;

    return 'Pengguna Moodly';
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      return _ProfileContent(name: 'Pengguna Moodly', onEdit: onEdit);
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        return _ProfileContent(
          name: _resolveName(data, user),
          onEdit: onEdit,
        );
      },
    );
  }
}

class _ProfileContent extends StatelessWidget {
  final String name;
  final VoidCallback onEdit;

  const _ProfileContent({
    required this.name,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Container(
      width: screenWidth < 500 ? screenWidth * 0.72 : 340,
      constraints: const BoxConstraints(
        minWidth: 260,
        maxWidth: 340,
      ),
      padding: EdgeInsets.fromLTRB(
        isSmall ? 10 : 12,
        isSmall ? 8 : 10,
        isSmall ? 12 : 16,
        isSmall ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(42),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.18),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 54 : 62,
            height: isSmall ? 54 : 62,
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: _green,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icons/login/image3.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.person_rounded,
                  color: _textDark,
                  size: 34,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 15 : 18,
                      fontWeight: FontWeight.w800,
                      color: _textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Premium Sanctuary Member',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isSmall ? 9 : 11,
                      fontWeight: FontWeight.w400,
                      color: _textSoft,
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Icon(
              Icons.edit_rounded,
              color: _greenDark,
              size: isSmall ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsPanel extends StatelessWidget {
  final VoidCallback onLogout;

  const _SettingsPanel({required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmall ? 14 : 20,
        18,
        isSmall ? 14 : 20,
        24,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(isSmall ? 20 : 24),
        border: Border.all(
          color: const Color(0xFFCFE8BE),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(120, 170, 95, 0.18),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle('ACCOUNT SETTINGS'),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.account_circle_rounded,
            iconColor: _green,
            title: 'Profile',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfilePage()),
              );
            },
          ),
          _MenuItem(
            icon: Icons.shield_rounded,
            iconColor: _green,
            title: 'Security',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SecurityPage()),
              );
            },
          ),
          _MenuItem(
            icon: Icons.error_rounded,
            iconColor: _green,
            title: 'Riwayat Pelapor',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ReportHistoryPage()),
              );
            },
          ),
          const SizedBox(height: 12),
          const _SectionTitle('APP PREFERENCES'),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.notifications_rounded,
            iconColor: _pink,
            title: 'Notifications',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const NotificationSettingsPage(),
                ),
              );
            },
          ),
          _MenuItem(
            icon: Icons.palette_rounded,
            iconColor: _pink,
            title: 'Theme',
            subtitle: 'Light Sanctuary',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ThemePage()),
              );
            },
          ),
          _MenuItem(
            icon: Icons.language_rounded,
            iconColor: _pink,
            title: 'Language',
            subtitle: 'Indonesia',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LanguagePage()),
              );
            },
          ),
          const SizedBox(height: 12),
          const _SectionTitle('ABOUT'),
          const SizedBox(height: 12),
          _MenuItem(
            icon: Icons.description_rounded,
            iconColor: Colors.grey,
            title: 'Terms & Conditions',
            trailing: const Icon(
              Icons.open_in_new_rounded,
              color: Colors.grey,
              size: 22,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsConditionsPage()),
              );
            },
          ),
          _LogoutItem(onTap: onLogout),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Text(
      title,
      style: TextStyle(
        color: _green,
        fontSize: screenWidth < 380 ? 14 : 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.2,
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Padding(
      padding: const EdgeInsets.only(bottom: 11),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 48),
          padding: EdgeInsets.symmetric(
            horizontal: isSmall ? 10 : 14,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.14),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: isSmall ? 22 : 26,
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 13 : 15,
                          fontWeight: FontWeight.w500,
                          color: _textDark,
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmall ? 13 : 15,
                              fontWeight: FontWeight.w500,
                              color: _textDark,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isSmall ? 9 : 10,
                              fontWeight: FontWeight.w400,
                              color: _textSoft,
                              height: 1,
                            ),
                          ),
                        ],
                      ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.black,
                    size: isSmall ? 20 : 24,
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LogoutItem extends StatelessWidget {
  final VoidCallback onTap;

  const _LogoutItem({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: EdgeInsets.symmetric(
          horizontal: isSmall ? 10 : 14,
          vertical: 9,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.14),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.logout_rounded,
              color: Colors.red,
              size: isSmall ? 22 : 26,
            ),
            SizedBox(width: isSmall ? 8 : 12),
            Expanded(
              child: Text(
                'Logout',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 13 : 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _DialogButton({
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
          child: Text(
            label,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}