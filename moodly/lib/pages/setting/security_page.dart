import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../afirmasi/widgets/cute_top_popup.dart';
import '../pages.dart';
import 'moodly_settings_support.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool _isLoadingPrefs = true;
  bool _is2FAEnabled = false;
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Keamanan',
      'introTitle': 'Jaga akses akunmu',
      'introBody':
          'Halaman ini sekarang tidak lagi penuh hiasan random. Fokusnya keamanan akun yang benar-benar bisa kamu cek.',
      'password': 'Kata Sandi',
      'passwordTitle': 'Ubah Kata Sandi',
      'passwordBody': 'Perbarui kata sandi akun email kamu.',
      'extraVerification': 'Verifikasi Tambahan',
      'extraTitle': 'Verifikasi Dua Langkah',
      'extraBody':
          'Simpan preferensi keamanan tambahan di perangkat ini dulu. Belum tersambung ke OTP atau backend, jadi jangan pura-pura ini 2FA penuh.',
      'extraEnabled': 'Preferensi verifikasi tambahan diaktifkan.',
      'extraDisabled': 'Preferensi verifikasi tambahan dimatikan.',
      'accountStatus': 'Status Akun',
      'provider': 'Metode login',
      'verified': 'Email terverifikasi',
      'yes': 'Ya',
      'no': 'Tidak',
      'unknown': '-',
      'email': 'Email',
      'google': 'Google',
      'facebook': 'Facebook',
      'anonymous': 'Anonim',
      'currentSession': 'Sesi saat ini',
      'currentSessionBody': 'Akun ini sedang aktif di perangkat sekarang.',
      'moreLater': 'Riwayat perangkat lain belum tersedia di halaman ini.',
      'changePasswordHint':
          'Fitur ubah kata sandi hanya berlaku untuk akun email dan kata sandi.',
    },
    'en': {
      'header': 'Security',
      'introTitle': 'Protect your account access',
      'introBody':
          'This page is no longer stuffed with random decoration. The point is account security you can actually check.',
      'password': 'Password',
      'passwordTitle': 'Change Password',
      'passwordBody': 'Update the password for your email account.',
      'extraVerification': 'Extra Verification',
      'extraTitle': 'Two-Step Verification',
      'extraBody':
          'Store an extra security preference on this device first. It is not wired to OTP or backend yet, so pretending this is full 2FA would be nonsense.',
      'extraEnabled': 'Extra verification preference enabled.',
      'extraDisabled': 'Extra verification preference disabled.',
      'accountStatus': 'Account Status',
      'provider': 'Sign-in method',
      'verified': 'Email verified',
      'yes': 'Yes',
      'no': 'No',
      'unknown': '-',
      'email': 'Email',
      'google': 'Google',
      'facebook': 'Facebook',
      'anonymous': 'Anonymous',
      'currentSession': 'Current session',
      'currentSessionBody': 'This account is currently active on this device.',
      'moreLater': 'Other device history is not available on this page yet.',
      'changePasswordHint':
          'Password change only works for email and password accounts.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _loadPrefs();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    final twoFactor = await MoodlySettingsPrefs.loadTwoFactorEnabled();

    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _is2FAEnabled = twoFactor;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  String _providerLabel(User? user) {
    if (user == null) return _t('unknown');
    final providerIds =
        user.providerData.map((item) => item.providerId).toList();
    if (providerIds.contains('google.com')) return _t('google');
    if (providerIds.contains('facebook.com')) return _t('facebook');
    if (providerIds.contains('password')) return _t('email');
    if (user.isAnonymous) return _t('anonymous');
    return _t('unknown');
  }

  Future<void> _toggleTwoFactor(bool value) async {
    await MoodlySettingsPrefs.saveTwoFactorEnabled(value);
    if (!mounted) return;
    setState(() => _is2FAEnabled = value);
    showCuteTopPopup(
      context,
      title: _t('header'),
      message: value ? _t('extraEnabled') : _t('extraDisabled'),
      type: CutePopupType.success,
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final pageWidth = _pageWidth(context);
    final user = FirebaseAuth.instance.currentUser;
    final providerLabel = _providerLabel(user);
    final isVerified = user?.emailVerified ?? false;
    final hasPasswordProvider = user?.providerData
            .any((item) => item.providerId == 'password') ??
        false;

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
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodlySettingsHeader(
                        palette: palette,
                        title: _t('header'),
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 22),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('introTitle'),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: palette.textDark,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('introBody'),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: palette.textSoft,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySectionTitle(
                        palette: palette,
                        title: _t('password'),
                      ),
                      const SizedBox(height: 12),
                      MoodlySettingsCard(
                        palette: palette,
                        child: MoodlyOptionTile(
                          palette: palette,
                          icon: Icons.lock_reset_rounded,
                          title: _t('passwordTitle'),
                          subtitle: hasPasswordProvider
                              ? _t('passwordBody')
                              : _t('changePasswordHint'),
                          isSelected: true,
                          backgroundColor: palette.mintSoft,
                          onTap: () async {
                            if (!hasPasswordProvider) {
                              showCuteTopPopup(
                                context,
                                title: _t('header'),
                                message: _t('changePasswordHint'),
                                type: CutePopupType.warning,
                              );
                              return;
                            }
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ChangePasswordPage(),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySectionTitle(
                        palette: palette,
                        title: _t('extraVerification'),
                      ),
                      const SizedBox(height: 12),
                      MoodlySettingsCard(
                        palette: palette,
                        child: MoodlySwitchTile(
                          palette: palette,
                          icon: Icons.verified_user_rounded,
                          iconColor: palette.greenDark,
                          title: _t('extraTitle'),
                          subtitle: _t('extraBody'),
                          value: _is2FAEnabled,
                          onChanged: _toggleTwoFactor,
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySectionTitle(
                        palette: palette,
                        title: _t('accountStatus'),
                      ),
                      const SizedBox(height: 12),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          children: [
                            _InfoRow(
                              label: _t('provider'),
                              value: providerLabel,
                              palette: palette,
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: _t('verified'),
                              value: isVerified ? _t('yes') : _t('no'),
                              palette: palette,
                            ),
                            const SizedBox(height: 14),
                            _InfoRow(
                              label: _t('currentSession'),
                              value: _t('currentSessionBody'),
                              palette: palette,
                              multiline: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Text(
                          _t('moreLater'),
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: palette.textSoft,
                                height: 1.45,
                              ),
                        ),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final MoodlySettingsPalette palette;
  final bool multiline;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.palette,
    this.multiline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment:
          multiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: palette.textDark,
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          flex: 6,
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: palette.textSoft,
                  height: 1.4,
                ),
          ),
        ),
      ],
    );
  }
}