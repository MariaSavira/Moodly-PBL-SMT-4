import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/styles/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/validators.dart';
import '../../widgets/moodly_text_field.dart';
import '../../widgets/moodly_primary_button.dart';
import '../../widgets/or_divider.dart';
import '../../widgets/social_sign_in_button.dart';
import '../afirmasi/widgets/cute_top_popup.dart'; // kalau nama file popup kamu beda, sesuaikan ini
import '../splash_screen.dart';
import 'auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  bool _hasError = false;
  String? _errorMessage;
  String? _errorDescription;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToHomeChat() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const SplashScreenMoodly(),
      ),
      (route) => false,
    );
  }

  void _showLoginError({
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

  Future<void> _handleSignIn() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _showLoginError(
        title: 'Form belum lengkap',
        message: 'Coba cek lagi email dan kata sandimu ya.',
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
      _errorDescription = null;
    });

    final result = await AuthService.instance.signIn(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (result.isSuccess) {
      setState(() => _isLoading = false);
      _goToHomeChat();
    } else {
      final message =
          result.errorMessage ?? 'Email atau kata sandi salah. Coba lagi.';

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Login Gagal';
        _errorDescription = message;
      });

      _showLoginError(
        title: 'Login gagal',
        message: message,
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SplashScreenMoodly(),
        ),
        (route) => false,
      );
    } else {
      final message =
          result.errorMessage ?? 'Login Facebook belum berhasil.';

      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Login Facebook Gagal';
        _errorDescription = message;
      });

      _showLoginError(
        title: 'Facebook gagal',
        message: message,
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

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const SplashScreenMoodly(),
        ),
        (route) => false,
      );
    } else {
      final message =
          result.errorMessage ?? 'Login Google belum berhasil.';

      setState(() {
        _isGoogleLoading = false;
        _hasError = true;
        _errorMessage = 'Login Google Gagal';
        _errorDescription = message;
      });

      _showLoginError(
        title: 'Google gagal',
        message: message,
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

    final headingStyle = textTheme.headlineLarge?.copyWith(
      fontSize: 30,
      fontWeight: FontWeight.w700,
      color: const Color(0xFF111111),
      height: 1.0,
    );

    final subtitleStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF2D2D2D),
      height: 1.3,
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

    final forgotPasswordStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w700,
      color: AppColors.primary,
      decoration: TextDecoration.underline,
      decorationColor: AppColors.primary,
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
              child: Container(
                color: AppColors.background,
              ),
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
                          const SizedBox(height: 8),

                          SizedBox(
                            height: 110,
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 0,
                                  top: 4,
                                  child: Transform.rotate(
                                    angle: -0.03,
                                    child: Image.asset(
                                      'assets/icons/login/image1.png',
                                      width: 102,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Moodly',
                                        style: brandTitleStyle,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Tempat aman untuk memahami diri',
                                        style: brandSubtitleStyle,
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
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
                                padding: const EdgeInsets.fromLTRB(22, 28, 22, 38),
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
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Masuk', style: headingStyle),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Selamat datang kembali',
                                        style: subtitleStyle,
                                      ),
                                      const SizedBox(height: 32),

                                      MoodlyTextField(
                                        controller: _emailController,
                                        label: 'Alamat Email',
                                        labelStyle: sectionLabelStyle,
                                        hintText: 'hello@gmail.com',
                                        prefixIcon: const Icon(Icons.mail_outline),
                                        keyboardType: TextInputType.emailAddress,
                                        hasError: _hasError,
                                        validator: Validators.validateEmail,
                                        onChanged: (_) {
                                          if (_hasError) {
                                            setState(() => _hasError = false);
                                          }
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Kata Sandi',
                                            style: sectionLabelStyle,
                                          ),
                                          InkWell(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const ForgotPasswordPage(),
                                                ),
                                              );
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 4,
                                                vertical: 4,
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    'Lupa kata sandi?',
                                                    style: forgotPasswordStyle,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Icon(
                                                    Icons.chevron_right_rounded,
                                                    size: 16,
                                                    color: AppColors.primary,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 8),

                                      MoodlyTextField(
                                        controller: _passwordController,
                                        label: '',
                                        hintText: '••••••••',
                                        prefixIcon:
                                            const Icon(Icons.lock_outline),
                                        obscureText: _obscurePassword,
                                        hasError: _hasError,
                                        validator: Validators.validatePassword,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons
                                                    .visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            color: AppColors.textHint,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _obscurePassword =
                                                  !_obscurePassword;
                                            });
                                          },
                                        ),
                                        onChanged: (_) {
                                          if (_hasError) {
                                            setState(() => _hasError = false);
                                          }
                                        },
                                      ),

                                      const SizedBox(height: 24),

                                      MoodlyPrimaryButton(
                                        label: 'Masuk',
                                        onPressed: _handleSignIn,
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
                                'Belum punya akun? ',
                                style: bottomTextStyle,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const RegisterPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Daftar',
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