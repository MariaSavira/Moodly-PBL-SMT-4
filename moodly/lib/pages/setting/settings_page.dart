import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';

// pages
import 'theme_page.dart';
import 'language_page.dart';
import 'notification_settings_page.dart';
import 'report_history_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 24.0 : 32.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: "Pengaturan",
                    onBack: () => Navigator.pop(context),
                  ),
                  const SizedBox(height: 36),

                  Center(
                    child: _ProfileCard(
                      onEdit: () {
                        Navigator.pushNamed(context, '/edit-profile');
                      },
                    ),
                  ),

                  const SizedBox(height: 34),

                  _MainSettingsContainer(
                    children: [
                      _SectionTitle("PENGATURAN AKUN"),
                      const SizedBox(height: 12),

                      _SettingItem(
                        icon: Icons.account_circle,
                        iconColor: MoodlyColors.green,
                        title: "Profil",
                        onTap: () {
                          Navigator.pushNamed(context, '/profile');
                        },
                      ),

                      _SettingItem(
                        icon: Icons.shield,
                        iconColor: MoodlyColors.green,
                        title: "Keamanan",
                        onTap: () {
                          Navigator.pushNamed(context, '/security');
                        },
                      ),

                      _SettingItem(
                        icon: Icons.error,
                        iconColor: MoodlyColors.green,
                        title: "Riwayat Pelapor",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReportHistoryPage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),
                      _SectionTitle("PREFERENSI APLIKASI"),
                      const SizedBox(height: 12),

                      _SettingItem(
                        icon: Icons.notifications,
                        iconColor: MoodlyColors.pinkAccent,
                        title: "Notifikasi",
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

                      _SettingItem(
                        icon: Icons.palette,
                        iconColor: MoodlyColors.pinkAccent,
                        title: "Tema",
                        subtitle: "Mode Terang",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ThemePage(),
                            ),
                          );
                        },
                      ),

                      _SettingItem(
                        icon: Icons.language,
                        iconColor: MoodlyColors.pinkAccent,
                        title: "Bahasa",
                        subtitle: "Indonesia",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LanguagePage(),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 18),
                      _SectionTitle("TENTANG"),
                      const SizedBox(height: 12),

                      _SettingItem(
                        icon: Icons.description,
                        iconColor: Colors.grey,
                        title: "Syarat & Ketentuan",
                        trailing: const Icon(
                          Icons.open_in_new,
                          color: Colors.grey,
                          size: 22,
                        ),
                        onTap: () {},
                      ),

                      _LogoutItem(
                        onTap: () => _showLogoutDialog(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: MoodlyColors.bgLight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 14),
                const Text(
                  "Apakah Anda yakin ingin\nkeluar dari akun Anda?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _DialogButton(
                        label: "Batal",
                        color: MoodlyColors.greenLight,
                        textColor: Colors.black,
                        onTap: () => Navigator.pop(context),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _DialogButton(
                        label: "Keluar",
                        color: MoodlyColors.pinkAccent,
                        textColor: Colors.black,
                        onTap: () {
                          Navigator.pop(context);
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
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: MoodlyColors.green,
            size: 22,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        const Text(
          "Moodly",
          style: TextStyle(
            color: Color(0xFFC65F59),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final VoidCallback onEdit;

  const _ProfileCard({required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: MoodlyColors.green, width: 5),
            ),
            child: const Center(
              child: Text("🧠", style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Muhammad Yusuf",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Premium Sanctuary Member",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: const Icon(
              Icons.edit,
              color: MoodlyColors.green,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}

class _MainSettingsContainer extends StatelessWidget {
  final List<Widget> children;

  const _MainSettingsContainer({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
      decoration: BoxDecoration(
        color: MoodlyColors.greenLight.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: MoodlyColors.green.withValues(alpha: 0.18),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: MoodlyColors.green,
        fontSize: 15,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingItem({
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
          height: subtitle == null ? 42 : 54,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 25),
              const SizedBox(width: 14),
              Expanded(
                child: subtitle == null
                    ? Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            subtitle!,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
              ),
              trailing ??
                  const Icon(
                    Icons.arrow_forward,
                    color: Colors.black,
                    size: 22,
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
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 42,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: const Row(
            children: [
              Icon(Icons.logout, color: Colors.red, size: 27),
              SizedBox(width: 14),
              Text(
                "Keluar",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
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
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}