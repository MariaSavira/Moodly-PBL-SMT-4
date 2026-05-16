import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/styles/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/otp_service.dart';
import '../../widgets/moodly_text_field.dart';
import '../../widgets/moodly_primary_button.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/social_sign_in_button.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import '../chat_anonim/homepage_chat_anonim.dart';
import 'auth.dart';
import '../splash_screen.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  bool _hasError = false;
  bool _passwordError = false;
  bool _contactError = false;

  String? _errorMessage;
  String? _errorDescription;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_hasError) {
      setState(() {
        _hasError = false;
        _passwordError = false;
        _contactError = false;
        _errorMessage = null;
        _errorDescription = null;
      });
    }
  }

  void _showRegisterError({
    required String title,
    required String message,
  }) {
    showCuteTopPopup(
      context,
      title: title,
      message: message,
      type: CutePopupType.error,
    );
  }

  void _goToHomeChat() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SplashScreenMoodly()),
      (route) => false,
    );
  }

  Future<void> _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (_fullNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      setState(() {
        _hasError = true;
        _contactError = false;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = 'Semua data harus diisi.';
      });

      _showRegisterError(
        title: 'Data belum lengkap',
        message: 'Semua kolom wajib diisi dulu ya.',
      );
      return;
    }

    if (!_emailController.text.trim().contains('@')) {
      setState(() {
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = 'Format email tidak valid.';
      });

      _showRegisterError(
        title: 'Email belum valid',
        message: 'Coba cek lagi format alamat emailmu.',
      );
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      setState(() {
        _hasError = true;
        _passwordError = true;
        _contactError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = 'Kata sandi minimal 6 karakter.';
      });

      _showRegisterError(
        title: 'Kata sandi terlalu pendek',
        message: 'Minimal gunakan 6 karakter ya.',
      );
      return;
    }

    if (_passwordController.text.trim() !=
        _confirmPasswordController.text.trim()) {
      setState(() {
        _hasError = true;
        _passwordError = true;
        _contactError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = 'Kata sandi dan konfirmasi kata sandi harus sama.';
      });

      _showRegisterError(
        title: 'Kata sandi belum sama',
        message: 'Pastikan konfirmasi kata sandi sesuai.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _passwordError = false;
      _contactError = false;
    });

    try {
      await OtpService.instance.sendRegisterOtp(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OtpVerificationPage(
            fullName: _fullNameController.text.trim(),
            email: _emailController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final rawMessage = e.toString().replaceFirst('Exception: ', '').trim();

      debugPrint('REGISTER OTP ERROR: $rawMessage');

      setState(() {
        _isLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = rawMessage;
      });

      _showRegisterError(
        title: 'OTP gagal dikirim',
        message: rawMessage.isEmpty
            ? 'Terjadi kendala saat mengirim OTP.'
            : rawMessage,
      );
    }
  }

  Future<void> _handleFacebookSignIn() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _errorDescription = null;
    });

    final result = await AuthService.instance.signInWithFacebook();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isLoading = false);
      _goToHomeChat();
    } else {
      final msg =
          result.errorMessage ?? 'Daftar dengan Facebook belum berhasil.';

      setState(() {
        _isLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = msg;
      });

      _showRegisterError(
        title: 'Facebook gagal',
        message: msg,
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    FocusScope.of(context).unfocus();

    setState(() {
      _isGoogleLoading = true;
      _hasError = false;
      _errorMessage = null;
      _errorDescription = null;
    });

    final result = await AuthService.instance.signInWithGoogle();

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isGoogleLoading = false);
      _goToHomeChat();
    } else {
      final msg =
          result.errorMessage ?? 'Daftar dengan Google belum berhasil.';

      setState(() {
        _isGoogleLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = msg;
      });

      _showRegisterError(
        title: 'Google gagal',
        message: msg,
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

    final brandSubtitleStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w700,
      color: Colors.black,
      height: 1.3,
    );

    final backLabelStyle = textTheme.titleMedium?.copyWith(
      fontSize: 17,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
    );

    final headingStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
      height: 1.05,
    );

    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: const Color(0xFF2D2D2D),
      height: 1.45,
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 26,
                      vertical: 18,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 36,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 4),

                          Row(
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => Navigator.pop(context),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.arrow_back_ios_new_rounded,
                                        size: 18,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Daftar',
                                        style: backLabelStyle,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                'Moodly',
                                style: brandTitleStyle?.copyWith(fontSize: 28),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          SizedBox(
                            width: double.infinity,
                            child: Column(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Image.asset(
                                    'assets/icons/login/image1.png',
                                    width: 92,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Bergabung dengan Moodly',
                                  textAlign: TextAlign.center,
                                  style: headingStyle?.copyWith(fontSize: 24),
                                ),
                                const SizedBox(height: 8),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: Text(
                                    'Mulai langkah kecil untuk memahami diri dengan lebih hangat dan terarah.',
                                    textAlign: TextAlign.center,
                                    style: subtitleStyle,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.fromLTRB(22, 28, 22, 38),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    MoodlyTextField(
                                      controller: _fullNameController,
                                      label: 'Nama Lengkap',
                                      labelStyle: sectionLabelStyle,
                                      hintText: 'Muhammad Yusuf',
                                      prefixIcon:
                                          const Icon(Icons.person_outline),
                                      onChanged: (_) => _clearError(),
                                    ),

                                    const SizedBox(height: 18),

                                    MoodlyTextField(
                                      controller: _emailController,
                                      label: 'Alamat Email',
                                      labelStyle: sectionLabelStyle,
                                      hintText: 'yusuf@gmail.com',
                                      prefixIcon:
                                          const Icon(Icons.mail_outline),
                                      keyboardType:
                                          TextInputType.emailAddress,
                                      hasError: _contactError,
                                      onChanged: (_) => _clearError(),
                                    ),

                                    const SizedBox(height: 18),

                                    MoodlyTextField(
                                      controller: _phoneController,
                                      label: 'Nomor Telepon',
                                      labelStyle: sectionLabelStyle,
                                      hintText: '+62 812-1234-5678',
                                      prefixIcon:
                                          const Icon(Icons.phone_outlined),
                                      keyboardType: TextInputType.phone,
                                      hasError: _contactError,
                                      onChanged: (_) => _clearError(),
                                    ),

                                    const SizedBox(height: 18),

                                    MoodlyTextField(
                                      controller: _passwordController,
                                      label: 'Kata Sandi',
                                      labelStyle: sectionLabelStyle,
                                      hintText: '••••••••',
                                      prefixIcon:
                                          const Icon(Icons.lock_outline),
                                      obscureText: _obscurePassword,
                                      hasError: _passwordError,
                                      onChanged: (_) => _clearError(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscurePassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _passwordError
                                              ? AppColors.error
                                              : AppColors.textHint,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscurePassword =
                                                !_obscurePassword;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 18),

                                    MoodlyTextField(
                                      controller: _confirmPasswordController,
                                      label: 'Konfirmasi Kata Sandi',
                                      labelStyle: sectionLabelStyle,
                                      hintText: '••••••••',
                                      prefixIcon:
                                          const Icon(Icons.shield_outlined),
                                      obscureText: _obscureConfirmPassword,
                                      hasError: _passwordError,
                                      onChanged: (_) => _clearError(),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscureConfirmPassword
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: _passwordError
                                              ? AppColors.error
                                              : AppColors.textHint,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _obscureConfirmPassword =
                                                !_obscureConfirmPassword;
                                          });
                                        },
                                      ),
                                    ),

                                    const SizedBox(height: 24),

                                    MoodlyPrimaryButton(
                                      label: 'Daftar',
                                      onPressed: _handleSignUp,
                                      isLoading: _isLoading,
                                      width: double.infinity,
                                    ),

                                    const SizedBox(height: 28),
                                    const OrDivider(),
                                    const SizedBox(height: 22),

                                    Center(
                                      child: Wrap(
                                        alignment: WrapAlignment.center,
                                        crossAxisAlignment:
                                            WrapCrossAlignment.center,
                                        spacing: 12,
                                        runSpacing: 12,
                                        children: [
                                          SocialSignInButton(
                                            label: _isGoogleLoading
                                                ? 'Loading'
                                                : 'Google',
                                            icon: Image.asset(
                                              'assets/icons/login/google.png',
                                              fit: BoxFit.contain,
                                            ),
                                            onPressed: _isGoogleLoading
                                                ? () {}
                                                : _handleGoogleSignIn,
                                          ),
                                          SocialSignInButton(
                                            label: 'Facebook',
                                            icon: Image.asset(
                                              'assets/icons/login/facebook.png',
                                              fit: BoxFit.contain,
                                            ),
                                            onPressed:
                                                _handleFacebookSignIn,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Positioned(
                                right: -4,
                                bottom: -20,
                                child: Image.asset(
                                  'assets/icons/login/image1.png',
                                  width: 108,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 40),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Sudah punya akun? ',
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