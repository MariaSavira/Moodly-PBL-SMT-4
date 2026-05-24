import 'package:flutter/material.dart';

import '../../core/services/auth_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'moodly_settings_support.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  bool _currentObscure = true;
  bool _newObscure = true;
  bool _confirmObscure = true;
  bool _isSubmitting = false;
  bool _isLoadingPrefs = !MoodlySettingsPrefs.isHydrated;
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Ubah Kata Sandi',
      'title': 'Perbarui keamanan akunmu',
      'description': 'Masukkan kata sandi saat ini, lalu ganti dengan yang baru.',
      'currentPassword': 'Kata Sandi Saat Ini',
      'newPassword': 'Kata Sandi Baru',
      'confirmPassword': 'Konfirmasi Kata Sandi Baru',
      'currentHint': 'Masukkan kata sandi saat ini',
      'newHint': 'Minimal 6 karakter',
      'confirmHint': 'Ulangi kata sandi baru',
      'tipsTitle': 'Hal yang sebaiknya kamu perhatikan',
      'tipsBody': 'Gunakan kata sandi yang unik, tidak sama dengan akun lain, dan hindari pola yang terlalu jelas.',
      'submit': 'Simpan Kata Sandi Baru',
      'cancel': 'Batal',
      'emptyCurrent': 'Kata sandi saat ini belum diisi.',
      'emptyNew': 'Kata sandi baru belum diisi.',
      'emptyConfirm': 'Konfirmasi kata sandi belum diisi.',
      'minLength': 'Kata sandi baru minimal 6 karakter.',
      'samePassword': 'Kata sandi baru tidak boleh sama dengan kata sandi lama.',
      'notMatch': 'Konfirmasi kata sandi tidak cocok.',
      'success': 'Kata sandi berhasil diperbarui.',
      'providerNote': 'Fitur ini hanya berlaku untuk akun email dan kata sandi.',
    },
    'en': {
      'header': 'Change Password',
      'title': 'Update your account security',
      'description': 'Enter your current password, then replace it with a new one.',
      'currentPassword': 'Current Password',
      'newPassword': 'New Password',
      'confirmPassword': 'Confirm New Password',
      'currentHint': 'Enter your current password',
      'newHint': 'At least 6 characters',
      'confirmHint': 'Repeat your new password',
      'tipsTitle': 'What you should keep in mind',
      'tipsBody': 'Use a unique password, do not reuse old ones, and avoid obvious patterns.',
      'submit': 'Save New Password',
      'cancel': 'Cancel',
      'emptyCurrent': 'Current password is still empty.',
      'emptyNew': 'New password is still empty.',
      'emptyConfirm': 'Password confirmation is still empty.',
      'minLength': 'New password must be at least 6 characters.',
      'samePassword': 'New password must be different from the current password.',
      'notMatch': 'Password confirmation does not match.',
      'success': 'Password updated successfully.',
      'providerNote': 'This only works for email and password accounts.',
    },
  };

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();
    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  void _showMessage(String message, {bool error = false}) {
    showCuteTopPopup(
      context,
      title: error ? 'Oops' : 'OK',
      message: message,
      type: error ? CutePopupType.error : CutePopupType.success,
    );
  }

  Future<void> _submit() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty) return _showMessage(_t('emptyCurrent'), error: true);
    if (next.isEmpty) return _showMessage(_t('emptyNew'), error: true);
    if (confirm.isEmpty) return _showMessage(_t('emptyConfirm'), error: true);
    if (next.length < 6) return _showMessage(_t('minLength'), error: true);
    if (current == next) return _showMessage(_t('samePassword'), error: true);
    if (next != confirm) return _showMessage(_t('notMatch'), error: true);

    setState(() => _isSubmitting = true);
    final result = await AuthService.instance.changePassword(
      currentPassword: current,
      newPassword: next,
    );
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.isSuccess) {
      _showMessage(_t('success'));
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) Navigator.pop(context, true);
      return;
    }

    _showMessage(result.errorMessage ?? _t('providerNote'), error: true);
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final pageWidth = _pageWidth(context);

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: palette.bg,
        body: Center(child: CircularProgressIndicator(color: palette.greenDark)),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
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
                              _t('title'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: palette.textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('description'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.45),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          children: [
                            _PasswordInput(
                              palette: palette,
                              label: _t('currentPassword'),
                              hint: _t('currentHint'),
                              controller: _currentPasswordController,
                              icon: Icons.lock_open_rounded,
                              obscureText: _currentObscure,
                              onToggle: () => setState(() => _currentObscure = !_currentObscure),
                            ),
                            const SizedBox(height: 16),
                            _PasswordInput(
                              palette: palette,
                              label: _t('newPassword'),
                              hint: _t('newHint'),
                              controller: _newPasswordController,
                              icon: Icons.lock_rounded,
                              obscureText: _newObscure,
                              onToggle: () => setState(() => _newObscure = !_newObscure),
                            ),
                            const SizedBox(height: 16),
                            _PasswordInput(
                              palette: palette,
                              label: _t('confirmPassword'),
                              hint: _t('confirmHint'),
                              controller: _confirmPasswordController,
                              icon: Icons.verified_user_rounded,
                              obscureText: _confirmObscure,
                              onToggle: () => setState(() => _confirmObscure = !_confirmObscure),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: palette.pinkSoft,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(Icons.health_and_safety_rounded, color: palette.greenDark),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _t('tipsTitle'),
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textDark),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _t('tipsBody'),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: palette.textSoft, height: 1.45),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlyPrimaryButton(
                        palette: palette,
                        label: _t('submit'),
                        onPressed: _isSubmitting ? null : _submit,
                        isLoading: _isSubmitting,
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

class _PasswordInput extends StatelessWidget {
  final MoodlySettingsPalette palette;
  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordInput({
    required this.palette,
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(color: palette.textDark),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: palette.mintSoft,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            children: [
              Icon(icon, color: palette.greenDark),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  style: TextStyle(color: palette.textDark, fontSize: 16),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: hint,
                    hintStyle: TextStyle(color: palette.textSoft),
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggle,
                icon: Icon(
                  obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                  color: palette.textSoft,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
