import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/moodly_text_field.dart';
import '../widgets/moodly_primary_button.dart';
import 'login_page.dart';

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

  Future<void> _handleResetPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        _hasError = true;
        _message = 'Email tidak boleh kosong';
      });
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
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _hasError = true;
        _message = 'Email tidak ditemukan.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),

              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: AppColors.primary,
                      size: 22,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Moodly',
                    style: AppTextStyles.brandTitle.copyWith(fontSize: 30),
                  ),
                  const Spacer(),
                  const SizedBox(width: 22),
                ],
              ),

              const SizedBox(height: 90),

              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: -36,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDDE3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Jangan khawatir,\nkami bantu!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Image.asset(
                    'assets/icon/image3.png',
                    width: 110,
                  ),
                ],
              ),

              const SizedBox(height: 42),

              Text(
                'Lupa Kata Sandi',
                textAlign: TextAlign.center,
                style: AppTextStyles.heading1.copyWith(fontSize: 32),
              ),

              const SizedBox(height: 18),

              Text(
                'Masukkan alamat email yang terdaftar\npada akun Anda, lalu kami akan mengirimkan\ntautan untuk mengatur ulang kata sandi.',
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium.copyWith(
                  height: 1.6,
                ),
              ),

              const SizedBox(height: 56),

              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Text(
                    'Alamat Email',
                    style: AppTextStyles.label,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: MoodlyTextField(
                  controller: _emailController,
                  label: '',
                  hintText: 'hello@gmail.com',
                  prefixIcon: const Icon(Icons.mail_outline),
                  keyboardType: TextInputType.emailAddress,
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
              ),

              const SizedBox(height: 28),

              MoodlyPrimaryButton(
                label: 'Atur Ulang Kata Sandi',
                onPressed: _handleResetPassword,
                isLoading: _isLoading,
                width: 275,
              ),

              if (_message != null) ...[
                const SizedBox(height: 14),
                Text(
                  _message!,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: _hasError ? AppColors.error : AppColors.primary,
                  ),
                ),
              ],

              const SizedBox(height: 60),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Sudah ingat? '),
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
                      style: AppTextStyles.linkText,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}