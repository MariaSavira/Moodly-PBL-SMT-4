import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/validators.dart';
import '../services/Auth_sevice.dart';
import '../widgets/moodly_text_field.dart';
import '../widgets/moodly_error_banner.dart';
import '../widgets/moodly_primary_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_sign_in_button.dart';
import 'register_page.dart';
import 'Forget_password_page.dart';

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
  bool _hasError = false;
  String? _errorMessage;
  String? _errorDescription;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;

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

      // TODO: arahkan ke halaman beranda nanti
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Login Gagal';
        _errorDescription =
            result.errorMessage ?? 'Email atau kata sandi salah. Coba lagi dengan tenang.';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login Google belum diaktifkan')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 20),

              SizedBox(
                height: 100,
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 6,
                      child: Image.asset(
                        'assets/icon/image1.png',
                        width: 95,
                        fit: BoxFit.contain,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Moodly', style: AppTextStyles.brandTitle),
                          const SizedBox(height: 4),
                          Text(
                            'Tempat aman untuk memahami diri',
                            style: AppTextStyles.brandSubtitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 28, 18, 56),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.10),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_hasError && _errorMessage != null) ...[
                            MoodlyErrorBanner(
                              title: _errorMessage!,
                              description: _errorDescription,
                              actionLabel: 'Lupa Kata Sandi?',
                              onAction: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const ForgotPasswordPage(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                          ],

                          Text('Masuk', style: AppTextStyles.heading1),
                          const SizedBox(height: 4),

                          Text(
                            'Selamat datang kembali',
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                            ),
                          ),

                          const SizedBox(height: 38),

                          MoodlyTextField(
                            controller: _emailController,
                            label: 'Alamat Email',
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

                          const SizedBox(height: 26),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Kata Sandi', style: AppTextStyles.label),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordPage(),
                                    ),
                                  );
                                },
                                child: Text(
                                  'Lupa kata sandi?',
                                  style: AppTextStyles.forgotPassword,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 8),

                          MoodlyTextField(
                            controller: _passwordController,
                            label: '',
                            hintText: '••••••••',
                            prefixIcon: const Icon(Icons.lock_outline),
                            obscureText: _obscurePassword,
                            hasError: _hasError,
                            validator: Validators.validatePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textHint,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            onChanged: (_) {
                              if (_hasError) {
                                setState(() => _hasError = false);
                              }
                            },
                          ),

                          const SizedBox(height: 26),

                          MoodlyPrimaryButton(
                            label: 'Masuk',
                            onPressed: _handleSignIn,
                            isLoading: _isLoading,
                          ),

                          const SizedBox(height: 28),
                          const OrDivider(),
                          const SizedBox(height: 24),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SocialSignInButton(
                                label: 'Google',
                                icon: Image.asset(
                                  'assets/icon/google.png',
                                  fit: BoxFit.contain,
                                ),
                                onPressed: _handleGoogleSignIn,
                              ),
                              const SizedBox(width: 12),
                              SocialSignInButton(
                                label: 'Facebook',
                                icon: Image.asset(
                                  'assets/icon/facebook.png',
                                  fit: BoxFit.contain,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Login Facebook belum diaktifkan',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  Positioned(
                    right: -8,
                    bottom: -28,
                    child: Image.asset(
                      'assets/icon/image1.png',
                      width: 105,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 42),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum punya akun? '),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Daftar',
                      style: AppTextStyles.linkText,
                    ),
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