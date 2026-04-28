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
    });

    final result = await AuthService.instance.signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      // TODO: Navigate to Home
      // Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Login Failed';
        _errorDescription = result.errorMessage;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    final result = await AuthService.instance.signInWithGoogle();

    if (!mounted) return;

    if (result.isSuccess) {
      // TODO: Navigate to Home
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Login Failed';
        _errorDescription = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 24),

              // ── Logo & Brand ──
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Replace with Image.asset('assets/images/mascot.png')
                  const Icon(Icons.favorite, color: Colors.pinkAccent, size: 40),
                  const SizedBox(width: 8),
                  Text('Moodly', style: AppTextStyles.brandTitle),
                ],
              ),
              const SizedBox(height: 4),
              Text('Your empathic sanctuary', style: AppTextStyles.brandSubtitle),

              const SizedBox(height: 32),

              // ── Card ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Error Banner ──
                      if (_hasError && _errorMessage != null) ...[
                        MoodlyErrorBanner(
                          title: _errorMessage!,
                          description: _errorDescription,
                          actionLabel: 'Forget Password?',
                          onAction: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      Text('Sign in', style: AppTextStyles.heading1),
                      const SizedBox(height: 4),
                      Text(
                        "Welcome back, you've been missed",
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ── Email ──
                      MoodlyTextField(
                        controller: _emailController,
                        label: 'Email Address',
                        hintText: 'hello@gamil.com',
                        prefixIcon: const Icon(Icons.mail_outline),
                        keyboardType: TextInputType.emailAddress,
                        hasError: _hasError,
                        validator: Validators.validateEmail,
                        onChanged: (_) {
                          if (_hasError) setState(() => _hasError = false);
                        },
                      ),

                      const SizedBox(height: 20),

                      // ── Password label row ──
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Password', style: AppTextStyles.label),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const ForgotPasswordPage(),
                              ),
                            ),
                            child: Text(
                              'Forget your password?',
                              style: AppTextStyles.forgotPassword,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      MoodlyTextField(
                        controller: _passwordController,
                        label: '',
                        hintText: '••••••••••••',
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
                          onPressed: () =>
                              setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        onChanged: (_) {
                          if (_hasError) setState(() => _hasError = false);
                        },
                      ),

                      const SizedBox(height: 24),

                      MoodlyPrimaryButton(
                        label: 'sign in',
                        onPressed: _handleSignIn,
                        isLoading: _isLoading,
                      ),

                      const SizedBox(height: 20),
                      const OrDivider(),
                      const SizedBox(height: 16),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SocialSignInButton(
                            label: 'google',
                            icon: Image.network(
                              'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/512px-Google_%22G%22_logo.svg.png',
                              errorBuilder: (_, __, ___) =>
                                  const Icon(Icons.g_mobiledata, size: 22),
                            ),
                            onPressed: _handleGoogleSignIn,
                          ),
                          const SizedBox(width: 12),
                          SocialSignInButton(
                            label: 'facebook',
                            icon: const Icon(Icons.facebook,
                                color: Color(0xFF1877F2), size: 22),
                            onPressed: () {
                              // TODO: implement Facebook sign in
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "don't have an account? ",
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterPage()),
                    ),
                    child: Text('Sign up', style: AppTextStyles.linkText),
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