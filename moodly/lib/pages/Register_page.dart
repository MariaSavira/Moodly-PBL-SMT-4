import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../core/validators.dart';
import '../services/auth_service.dart';
import '../widgets/moodly_text_field.dart';
import '../widgets/moodly_error_banner.dart';
import '../widgets/moodly_primary_button.dart';
import '../widgets/or_divider.dart';
import '../widgets/social_sign_in_button.dart';
import 'register_success_page.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _hasError = false;
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

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    final result = await AuthService.instance.signUp(
      fullName: _fullNameController.text,
      email: _emailController.text,
      password: _passwordController.text,
      phoneNumber: _phoneController.text,
    );

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Sign up encountered a small hic cup.';
        _errorDescription = result.errorMessage;
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);
    final result = await AuthService.instance.signInWithGoogle();

    if (!mounted) return;

    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const RegisterSuccessPage()),
      );
    } else {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = 'Sign up encountered a small hic cup.';
        _errorDescription = result.errorMessage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Sign up',
                    style: AppTextStyles.label.copyWith(color: AppColors.primary),
                  ),
                  const Spacer(),
                  Text(
                    'Moodly',
                    style: AppTextStyles.brandTitle.copyWith(fontSize: 22),
                  ),
                ],
              ),
            ),

            // ── Content ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    Text('Join the Sanctuary', style: AppTextStyles.heading1),
                    const SizedBox(height: 20),

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
                              ),
                              const SizedBox(height: 16),
                            ],

                            // ── Full Name ──
                            MoodlyTextField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              hintText: 'Muhammad Yusuf',
                              prefixIcon: const Icon(Icons.person_outline),
                              hasError: _hasError,
                              validator: Validators.validateFullName,
                              onChanged: (_) {
                                if (_hasError) setState(() => _hasError = false);
                              },
                            ),

                            const SizedBox(height: 16),

                            // ── Email ──
                            MoodlyTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              hintText: 'yusuf@gamil.com',
                              prefixIcon: const Icon(Icons.mail_outline),
                              keyboardType: TextInputType.emailAddress,
                              hasError: _hasError,
                              validator: Validators.validateEmail,
                              onChanged: (_) {
                                if (_hasError) setState(() => _hasError = false);
                              },
                            ),

                            const SizedBox(height: 16),

                            // ── Phone ──
                            MoodlyTextField(
                              controller: _phoneController,
                              label: 'Phone Number',
                              hintText: '+ 62 812-1283-9131',
                              prefixIcon: const Icon(Icons.phone_outlined),
                              keyboardType: TextInputType.phone,
                              hasError: _hasError,
                              validator: Validators.validatePhone,
                              onChanged: (_) {
                                if (_hasError) setState(() => _hasError = false);
                              },
                            ),

                            const SizedBox(height: 16),

                            // ── Password ──
                            MoodlyTextField(
                              controller: _passwordController,
                              label: 'Password',
                              hintText: '••••••••••••',
                              prefixIcon: const Icon(Icons.lock_outline),
                              obscureText: _obscurePassword,
                              validator: Validators.validatePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // ── Confirm Password ──
                            MoodlyTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              hintText: '••••••••••••',
                              prefixIcon: const Icon(Icons.shield_outlined),
                              obscureText: _obscureConfirmPassword,
                              validator: (value) =>
                                  Validators.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: AppColors.textHint,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirmPassword =
                                        !_obscureConfirmPassword),
                              ),
                            ),

                            const SizedBox(height: 24),

                            MoodlyPrimaryButton(
                              label: 'sign up',
                              onPressed: _handleSignUp,
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

                    const SizedBox(height: 24),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginPage()),
                          ),
                          child: Text('Sign in', style: AppTextStyles.linkText),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}