import 'package:flutter/material.dart';

import '../../core/styles/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/otp_service.dart';
import '../../core/styles/app_text_styles.dart';
import '../../widgets/moodly_text_field.dart';
import '../../widgets/moodly_primary_button.dart';
import '../../widgets/moodly_error_banner.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/social_sign_in_button.dart';
import '../chat_anonim/homepage_chat_anonim.dart';
import 'auth.dart';

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

  void _goToHomeChat() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeChatAnonim()),
      (route) => false,
    );
  }

  Future<void> _handleSignUp() async {
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

      setState(() {
        _isLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _handleFacebookSignIn() async {
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
      setState(() {
        _isLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription =
            result.errorMessage ?? 'Daftar dengan Facebook belum berhasil.';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
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
      setState(() {
        _isGoogleLoading = false;
        _hasError = true;
        _contactError = true;
        _passwordError = false;
        _errorMessage = 'Pendaftaran mengalami kendala.';
        _errorDescription =
            result.errorMessage ?? 'Daftar dengan Google belum berhasil.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text(
                      'Daftar',
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.primary,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Moodly',
                    style: AppTextStyles.brandTitle.copyWith(fontSize: 28),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Bergabung dengan Moodly',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.heading1.copyWith(fontSize: 30),
                ),
              ),

              const SizedBox(height: 24),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 60),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        if (_hasError) ...[
                          MoodlyErrorBanner(
                            title: _errorMessage!,
                            description: _errorDescription,
                          ),
                          const SizedBox(height: 16),
                        ],

                        MoodlyTextField(
                          controller: _fullNameController,
                          label: 'Nama Lengkap',
                          hintText: 'Muhammad Yusuf',
                          prefixIcon: const Icon(Icons.person_outline),
                          onChanged: (_) => _clearError(),
                        ),

                        const SizedBox(height: 16),

                        MoodlyTextField(
                          controller: _emailController,
                          label: 'Alamat Email',
                          hintText: 'yusuf@gmail.com',
                          prefixIcon: const Icon(Icons.mail_outline),
                          keyboardType: TextInputType.emailAddress,
                          hasError: _contactError,
                          onChanged: (_) => _clearError(),
                        ),

                        const SizedBox(height: 16),

                        MoodlyTextField(
                          controller: _phoneController,
                          label: 'Nomor Telepon',
                          hintText: '+62 812-1234-5678',
                          prefixIcon: const Icon(Icons.phone_outlined),
                          keyboardType: TextInputType.phone,
                          hasError: _contactError,
                          onChanged: (_) => _clearError(),
                        ),

                        const SizedBox(height: 16),

                        MoodlyTextField(
                          controller: _passwordController,
                          label: 'Kata Sandi',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.lock_outline),
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
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        MoodlyTextField(
                          controller: _confirmPasswordController,
                          label: 'Konfirmasi Kata Sandi',
                          hintText: '••••••••',
                          prefixIcon: const Icon(Icons.shield_outlined),
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
                        ),

                        const SizedBox(height: 24),

                        const OrDivider(),

                        const SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SocialSignInButton(
                              label: _isGoogleLoading ? 'Loading' : 'Google',
                              icon: Image.asset(
                                'assets/icons/login/google.png',
                                fit: BoxFit.contain,
                              ),
                              onPressed: _isGoogleLoading
                                  ? () {}
                                  : _handleGoogleSignIn,
                            ),
                            const SizedBox(width: 12),
                            SocialSignInButton(
                              label: 'Facebook',
                              icon: Image.asset(
                                'assets/icons/login/facebook.png',
                                fit: BoxFit.contain,
                              ),
                              onPressed: _handleFacebookSignIn,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    right: -10,
                    bottom: -28,
                    child: Image.asset(
                      'assets/icons/login/image1.png',
                      width: 100,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah punya akun? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      );
                    },
                    child: Text('Masuk', style: AppTextStyles.linkText),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
