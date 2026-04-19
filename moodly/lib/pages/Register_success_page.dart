import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';
import '../widgets/moodly_primary_button.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Brand Name ──
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text('Moodly', style: AppTextStyles.brandTitle),
            ),

            const Spacer(),

            // ── Success Card ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 36),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Icon ──
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2.5,
                        ),
                      ),
                      child: const Icon(
                        Icons.celebration_outlined,
                        color: AppColors.primary,
                        size: 44,
                      ),
                    ),

                    const SizedBox(height: 24),

                    Text(
                      'Akun Berhasil\nDibuat!',
                      style: AppTextStyles.heading1.copyWith(fontSize: 26),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Perjalanan anda menuju hidup yang lebih tenang dimulai disini. kami sangat anda telah bergabung di tempat perlindungan kami.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 28),

                    MoodlyPrimaryButton(
                      label: 'Go To Home',
                      onPressed: () {
                        // TODO: Navigate to Home
                        // Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // ── Privacy Note ──
            Padding(
              padding: const EdgeInsets.only(bottom: 28),
              child: Text(
                'Your data is protected by our sanctuary\nprivacy policy',
                style: AppTextStyles.bodySmall.copyWith(
                  fontStyle: FontStyle.italic,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}