import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/styles/app_colors.dart';
import '../../widgets/moodly_text_field.dart';
import '../../widgets/moodly_primary_button.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'auth.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  bool _isLoading = false;
  bool _hasError = false;
  String? _message;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _showPopup({
    required String title,
    required String message,
    required CutePopupType type,
  }) {
    showCuteTopPopup(
      context,
      title: title,
      message: message,
      type: type,
    );
  }

  Future<void> _handleResetPassword() async {
    FocusScope.of(context).unfocus();
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _hasError = true;
        _message = 'Email tidak boleh kosong';
      });

      _showPopup(
        title: 'Email kosong',
        message: 'Masukkan email yang terdaftar dulu ya.',
        type: CutePopupType.warning,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _message = null;
    });

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _message = 'Tautan reset kata sandi sudah dikirim ke email.';
      });

      _showPopup(
        title: 'Email terkirim',
        message: 'Cek inbox atau folder spam kamu ya.',
        type: CutePopupType.success,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _message = 'Email tidak ditemukan.';
      });

      _showPopup(
        title: 'Reset gagal',
        message: 'Email tidak ditemukan atau belum terdaftar.',
        type: CutePopupType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final brandTitleStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: const Color(0xFFD5676E),
    );

    final titleStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
      height: 1.05,
    );

    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2D2D2D),
      height: 1.55,
    );

    final sectionLabelStyle = textTheme.titleMedium?.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    final bottomTextStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF222222),
    );

    final linkStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFFEFF5D6),
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Color(0xFFEFF5D6),
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            Positioned.fill(
              child: Container(color: AppColors.background),
            ),
            Positioned(
              top: -70,
              left: -55,
              child: _softBlob(
                size: 220,
                color: const Color(0xFFFFDDE4).withOpacity(0.42),
              ),
            ),
            Positioned(
              right: -56,
              top: 120,
              child: _softBlob(
                size: 190,
                color: const Color(0xFFCDEAB6).withOpacity(0.30),
              ),
            ),
            Positioned(
              left: -78,
              bottom: 120,
              child: _softBlob(
                size: 210,
                color: const Color(0xFFFFE7EC).withOpacity(0.24),
              ),
            ),
            Positioned(
              right: -74,
              bottom: 10,
              child: _softBlob(
                size: 215,
                color: const Color(0xFFD5EDC3).withOpacity(0.22),
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(4),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 18,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text('Moodly', style: brandTitleStyle),
                              const Spacer(),
                              const SizedBox(width: 26),
                            ],
                          ),
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(22, 30, 22, 34),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(28),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.75),
                                width: 1.1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFDDE3),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        'Jangan khawatir,\nkami bantu!',
                                        textAlign: TextAlign.center,
                                        style: textTheme.bodyMedium?.copyWith(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.black,
                                          height: 1.25,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Image.asset(
                                      'assets/icons/login/image3.png',
                                      width: 104,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 42),
                                Text(
                                  'Lupa Kata Sandi',
                                  textAlign: TextAlign.center,
                                  style: titleStyle,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Masukkan alamat email yang terdaftar pada akun Anda, lalu kami akan mengirimkan tautan untuk mengatur ulang kata sandi.',
                                  textAlign: TextAlign.center,
                                  style: subtitleStyle,
                                ),
                                const SizedBox(height: 32),
                                MoodlyTextField(
                                  controller: _emailController,
                                  label: 'Alamat Email',
                                  labelStyle: sectionLabelStyle,
                                  hintText: 'hello@gmail.com',
                                  prefixIcon: const Icon(Icons.mail_outline),
                                  keyboardType:
                                      TextInputType.emailAddress,
                                  hasError: _hasError,
                                  onChanged: (_) {
                                    if (_hasError || _message != null) {
                                      setState(() {
                                        _hasError = false;
                                        _message = null;
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                MoodlyPrimaryButton(
                                  label: 'Atur Ulang Kata Sandi',
                                  onPressed: _handleResetPassword,
                                  isLoading: _isLoading,
                                  width: double.infinity,
                                ),
                                if (_message != null) ...[
                                  const SizedBox(height: 14),
                                  Text(
                                    _message!,
                                    textAlign: TextAlign.center,
                                    style: textTheme.bodyMedium?.copyWith(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _hasError
                                          ? AppColors.error
                                          : AppColors.primary,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 34),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah ingat? ',
                                style: bottomTextStyle,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const LoginPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Masuk',
                                  style: linkStyle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _softBlob({
    required double size,
    required Color color,
  }) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}