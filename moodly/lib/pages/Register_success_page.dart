import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/moodly_primary_button.dart';
import 'login_page.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const SizedBox(height: 34),

                Text(
                  'Moodly',
                  style: AppTextStyles.brandTitle.copyWith(fontSize: 30),
                ),

                const SizedBox(height: 68),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 42, 24, 34),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.background,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 8,
                          ),
                        ),
                        child: const Icon(
                          Icons.celebration,
                          size: 78,
                          color: AppColors.primary,
                        ),
                      ),

                      const SizedBox(height: 22),

                      Text(
                        'Akun Berhasil\nDibuat!',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.heading1.copyWith(
                          fontSize: 30,
                          height: 1.15,
                          color: const Color(0xFF2B2B2B),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Text(
                        'Perjalanan Anda menuju\n'
                        'hidup yang lebih tenang dimulai\n'
                        'di sini. Kami senang Anda telah\n'
                        'bergabung bersama Moodly.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontSize: 14,
                          height: 1.6,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 26),

                      MoodlyPrimaryButton(
                        label: 'Ke Beranda',
                        width: 250,
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LoginPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                Text(
                  'Data Anda dilindungi oleh\nkebijakan privasi kami.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}