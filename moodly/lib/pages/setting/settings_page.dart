
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/auth_service.dart';
import '../../main.dart';
import '../pages.dart';

const String _settingsPlaceholderAsset = 'assets/profile_pic/PP_default.jpg';
const String _prefLanguageKey = 'moodly_settings_language_code';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _languageCode = 'id';
  bool _isLoadingPrefs = true;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Pengaturan',
      'accountSettings': 'Pengaturan Akun',
      'profile': 'Profil',
      'security': 'Keamanan',
      'reports': 'Laporan & Banding',
      'appPreferences': 'Preferensi Aplikasi',
      'notifications': 'Notifikasi',
      'language': 'Bahasa',
      'about': 'Tentang',
      'terms': 'Syarat & Ketentuan',
      'logout': 'Keluar',
      'cancel': 'Batal',
      'logoutQuestion': 'Apakah Anda yakin ingin\nkeluar dari akun Anda?',
      'logoutFailed': 'Logout gagal. Coba lagi sebentar.',
      'indonesian': 'Indonesia',
      'english': 'Inggris',
      'member': 'Moodly Member',
      'moodlyUser': 'Pengguna Moodly',
      'notLoggedIn': 'Belum login',
    },
    'en': {
      'header': 'Settings',
      'accountSettings': 'Account Settings',
      'profile': 'Profile',
      'security': 'Security',
      'reports': 'Reports & Appeals',
      'appPreferences': 'App Preferences',
      'notifications': 'Notifications',
      'language': 'Language',
      'about': 'About',
      'terms': 'Terms & Conditions',
      'logout': 'Log out',
      'cancel': 'Cancel',
      'logoutQuestion': 'Are you sure you want to\nlog out of your account?',
      'logoutFailed': 'Logout failed. Please try again.',
      'indonesian': 'Indonesian',
      'english': 'English',
      'member': 'Moodly Member',
      'moodlyUser': 'Moodly User',
      'notLoggedIn': 'Not logged in',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_prefLanguageKey);

    if (!mounted) return;

    setState(() {
      _languageCode = (savedLanguage == 'en') ? 'en' : 'id';
      _isLoadingPrefs = false;
    });
  }


  Future<void> _saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefLanguageKey, languageCode);
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  String get _languageSubtitle =>
      _languageCode == 'en' ? _t('english') : _t('indonesian');

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  Widget _background(_SettingsPalette palette) {
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
              color: palette.pinkSoft.withOpacity(0.72),
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
              color: palette.mintSoft.withOpacity(0.82),
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
              color: palette.greenSoft.withOpacity(0.55),
            ),
          ),
        ),
      ],
    );
  }

  TextStyle? _h1(BuildContext context, _SettingsPalette palette) {
    return Theme.of(context).textTheme.headlineLarge?.copyWith(
      color: palette.brand,
    );
  }

  TextStyle? _h2(BuildContext context, _SettingsPalette palette, {Color? color}) {
    return Theme.of(context).textTheme.titleMedium?.copyWith(
      color: color ?? palette.textDark,
    );
  }

  TextStyle? _body(BuildContext context, _SettingsPalette palette, {Color? color}) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
      color: color ?? palette.textSoft,
    );
  }

  TextStyle? _bodyAlt(
    BuildContext context,
    _SettingsPalette palette, {
    Color? color,
  }) {
    return Theme.of(context).textTheme.bodySmall?.copyWith(
      color: color ?? palette.textDark,
    );
  }

  TextStyle? _button(
    BuildContext context,
    _SettingsPalette palette, {
    Color? color,
  }) {
    return Theme.of(context).textTheme.labelLarge?.copyWith(
      color: color ?? Colors.white,
    );
  }

  void _showLogoutDialog(BuildContext context, _SettingsPalette palette) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (_) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 34),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          backgroundColor: palette.bg,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.warning_rounded, color: Colors.red, size: 48),
                const SizedBox(height: 14),
                Text(
                  _t('logoutQuestion'),
                  textAlign: TextAlign.center,
                  style: _h2(context, palette),
                ),
                const SizedBox(height: 26),
                Row(
                  children: [
                    Expanded(
                      child: _SettingsDialogButton(
                        label: _t('cancel'),
                        color: palette.greenSoft,
                        textColor: palette.textDark,
                        onTap: () => Navigator.pop(context),
                        palette: palette,
                        textStyle: _button(context, palette, color: palette.textDark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SettingsDialogButton(
                        label: _t('logout'),
                        color: const Color(0xFFFFD7DD),
                        textColor: palette.textDark,
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
                              SnackBar(
                                content: Text(_t('logoutFailed')),
                              ),
                            );
                          }
                        },
                        palette: palette,
                        textStyle: _button(context, palette, color: palette.textDark),
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


  Future<void> _openLanguagePage() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => LanguagePage(
          initialLanguageCode: _languageCode,
        ),
      ),
    );

    if (result == null || !mounted) return;

    setState(() {
      _languageCode = result;
    });
    await _saveLanguage(result);
  }

  @override
  Widget build(BuildContext context) {
    if (FirebaseAuth.instance.currentUser == null) {
      return const RootPage();
    }

    final pageWidth = _pageWidth(context);
    final palette = _SettingsPalette.of();

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: palette.bg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          _background(palette),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SettingsHeader(
                        onBack: () => Navigator.pop(context),
                        title: _t('header'),
                        palette: palette,
                        titleStyle: _h2(context, palette, color: palette.greenDark),
                        brandStyle: _h1(context, palette),
                      ),
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
                        palette: palette,
                        headingStyle: _h2(context, palette),
                        bodyStyle: _body(context, palette),
                        fallbackName: _t('moodlyUser'),
                        fallbackSubtitle: _t('notLoggedIn'),
                      ),
                      const SizedBox(height: 18),
                      _SettingsSection(
                        title: _t('accountSettings'),
                        palette: palette,
                        titleStyle: _h2(context, palette, color: palette.greenDark),
                        children: [
                          _SettingsItem(
                            icon: Icons.account_circle_rounded,
                            iconColor: palette.greenDark,
                            title: _t('profile'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ProfilePage(),
                                ),
                              );
                            },
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                          ),
                          _SettingsItem(
                            icon: Icons.shield_rounded,
                            iconColor: palette.greenDark,
                            title: _t('security'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SecurityPage(),
                                ),
                              );
                            },
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                          ),
                          _SettingsItem(
                            icon: Icons.error_outline_rounded,
                            iconColor: palette.greenDark,
                            title: _t('reports'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReportHistoryPage(),
                                ),
                              );
                            },
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: _t('appPreferences'),
                        palette: palette,
                        titleStyle: _h2(context, palette, color: palette.greenDark),
                        children: [
                          _SettingsItem(
                            icon: Icons.notifications_rounded,
                            iconColor: palette.preferenceIcon,
                            title: _t('notifications'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const NotificationSettingsPage(),
                                ),
                              );
                            },
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                          ),
                          _SettingsItem(
                            icon: Icons.language_rounded,
                            iconColor: palette.preferenceIcon,
                            title: _t('language'),
                            subtitle: _languageSubtitle,
                            onTap: _openLanguagePage,
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                            subtitleStyle: _body(context, palette),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _SettingsSection(
                        title: _t('about'),
                        palette: palette,
                        titleStyle: _h2(context, palette, color: palette.greenDark),
                        children: [
                          _SettingsItem(
                            icon: Icons.description_outlined,
                            iconColor: palette.textSoft,
                            title: _t('terms'),
                            trailing: Icon(
                              Icons.open_in_new_rounded,
                              color: palette.textSoft,
                              size: 20,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const TermsConditionsPage(),
                                ),
                              );
                            },
                            palette: palette,
                            textStyle: _bodyAlt(context, palette),
                          ),
                          _SettingsLogoutItem(
                            onTap: () => _showLogoutDialog(context, palette),
                            palette: palette,
                            title: _t('logout'),
                            textStyle: _bodyAlt(context, palette, color: palette.logout),
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
  final String title;
  final _SettingsPalette palette;
  final TextStyle? titleStyle;
  final TextStyle? brandStyle;

  const _SettingsHeader({
    required this.onBack,
    required this.title,
    required this.palette,
    required this.titleStyle,
    required this.brandStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: Icon(
            Icons.arrow_back_rounded,
            color: palette.greenDark,
            size: 26,
          ),
        ),
        const SizedBox(width: 10),
        Text(title, style: titleStyle),
        const Spacer(),
        Text('Moodly', style: brandStyle),
      ],
    );
  }
}

class _SettingsProfileCard extends StatelessWidget {
  final VoidCallback onEdit;
  final _SettingsPalette palette;
  final TextStyle? headingStyle;
  final TextStyle? bodyStyle;
  final String fallbackName;
  final String fallbackSubtitle;

  const _SettingsProfileCard({
    required this.onEdit,
    required this.palette,
    required this.headingStyle,
    required this.bodyStyle,
    required this.fallbackName,
    required this.fallbackSubtitle,
  });

  String _resolveName(Map<String, dynamic>? data, User? user) {
    final fullName = (data?['fullName'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;

    final displayName = user?.displayName?.trim();
    if (displayName != null && displayName.isNotEmpty) return displayName;

    final email = user?.email?.trim();
    if (email != null && email.isNotEmpty) {
      return email.split('@').first;
    }

    return fallbackName;
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
        name: fallbackName,
        subtitle: fallbackSubtitle,
        photoUrl: null,
        avatarAsset: null,
        onEdit: onEdit,
        palette: palette,
        headingStyle: headingStyle,
        bodyStyle: bodyStyle,
      );
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data();

        return _SettingsProfileContent(
          name: _resolveName(data, user),
          subtitle: _resolveSubtitle(data, user),
          photoUrl: _resolvePhotoUrl(data, user),
          avatarAsset: _resolveAvatarAsset(data),
          onEdit: onEdit,
          palette: palette,
          headingStyle: headingStyle,
          bodyStyle: bodyStyle,
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
  final _SettingsPalette palette;
  final TextStyle? headingStyle;
  final TextStyle? bodyStyle;

  const _SettingsProfileContent({
    required this.name,
    required this.subtitle,
    required this.photoUrl,
    required this.avatarAsset,
    required this.onEdit,
    required this.palette,
    required this.headingStyle,
    required this.bodyStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: palette.shadow,
        border: Border.all(color: palette.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 68,
            height: 68,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [palette.avatarStart, palette.avatarEnd],
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: palette.card,
              ),
              child: ClipOval(
                child: photoUrl != null && photoUrl!.isNotEmpty
                    ? Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            _buildFallbackAvatar(palette),
                      )
                    : (avatarAsset != null && avatarAsset!.isNotEmpty
                          ? Image.asset(
                              avatarAsset!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildFallbackAvatar(palette),
                            )
                          : _buildFallbackAvatar(palette)),
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
                  style: headingStyle,
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: bodyStyle,
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
                color: palette.pinkSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.edit_rounded, color: palette.greenDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackAvatar(_SettingsPalette palette) {
    return Image.asset(
      _settingsPlaceholderAsset,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.person_rounded,
          color: palette.textDark,
          size: 34,
        ),
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final _SettingsPalette palette;
  final TextStyle? titleStyle;

  const _SettingsSection({
    required this.title,
    required this.children,
    required this.palette,
    required this.titleStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
      decoration: BoxDecoration(
        color: palette.card,
        borderRadius: BorderRadius.circular(28),
        boxShadow: palette.shadow,
        border: Border.all(color: palette.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: titleStyle),
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
  final _SettingsPalette palette;
  final TextStyle? textStyle;
  final TextStyle? subtitleStyle;

  const _SettingsItem({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
    required this.palette,
    required this.textStyle,
    this.subtitleStyle,
  });

  @override
  Widget build(BuildContext context) {
    final itemBg = subtitle == null ? palette.mintSoft : palette.pinkSoft;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: itemBg,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 22),
              const SizedBox(width: 12),
              Expanded(
                child: subtitle == null
                    ? Text(title, style: textStyle)
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: textStyle),
                          const SizedBox(height: 2),
                          Text(subtitle!, style: subtitleStyle),
                        ],
                      ),
              ),
              trailing ??
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: palette.textDark,
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
  final _SettingsPalette palette;
  final String title;
  final TextStyle? textStyle;

  const _SettingsLogoutItem({
    required this.onTap,
    required this.palette,
    required this.title,
    required this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: palette.logoutSoft,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            Icon(Icons.logout_rounded, color: palette.logout, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Text(title, style: textStyle),
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
  final _SettingsPalette palette;
  final TextStyle? textStyle;

  const _SettingsDialogButton({
    required this.label,
    required this.color,
    required this.textColor,
    required this.onTap,
    required this.palette,
    required this.textStyle,
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
            style: textStyle ?? TextStyle(color: textColor),
          ),
        ),
      ),
    );
  }
}

class _SettingsPalette {
  final Color bg;
  final Color card;
  final Color cardBorder;
  final Color greenDark;
  final Color greenSoft;
  final Color mintSoft;
  final Color pinkSoft;
  final Color textDark;
  final Color textSoft;
  final Color brand;
  final Color preferenceIcon;
  final Color logout;
  final Color logoutSoft;
  final Color avatarStart;
  final Color avatarEnd;
  final List<BoxShadow> shadow;

  const _SettingsPalette({
    required this.bg,
    required this.card,
    required this.cardBorder,
    required this.greenDark,
    required this.greenSoft,
    required this.mintSoft,
    required this.pinkSoft,
    required this.textDark,
    required this.textSoft,
    required this.brand,
    required this.preferenceIcon,
    required this.logout,
    required this.logoutSoft,
    required this.avatarStart,
    required this.avatarEnd,
    required this.shadow,
  });

  factory _SettingsPalette.of() {
    return const _SettingsPalette(
      bg: Color(0xFFF4F8EA),
      card: Colors.white,
      cardBorder: Color(0x00000000),
      greenDark: Color(0xFF5E9E49),
      greenSoft: Color(0xFFDDEFCF),
      mintSoft: Color(0xFFE9F7E8),
      pinkSoft: Color(0xFFFFEEF2),
      textDark: Color(0xFF1F1F1F),
      textSoft: Color(0xFF6F746E),
      brand: Color(0xFFC65F59),
      preferenceIcon: Color(0xFFE08C9B),
      logout: Colors.red,
      logoutSoft: Color(0xFFFFEEF1),
      avatarStart: Color(0xFF92D373),
      avatarEnd: Color(0xFFD9EDC5),
      shadow: [
        BoxShadow(
          color: Color.fromRGBO(0, 0, 0, 0.08),
          offset: Offset(0, 8),
          blurRadius: 20,
          spreadRadius: 0,
        ),
      ],
    );
  }
}
