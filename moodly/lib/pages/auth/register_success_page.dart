import 'dart:ui';
import 'package:flutter/material.dart';

import '../../core/styles/app_colors.dart';
import '../../widgets/moodly_primary_button.dart';
import '../splash_screen.dart';

class RegisterSuccessPage extends StatelessWidget {
  const RegisterSuccessPage({super.key});

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
      color: const Color(0xFF222222),
      height: 1.1,
    );

    final bodyStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: Colors.black,
      height: 1.6,
    );

    final footnoteStyle = textTheme.bodyMedium?.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      fontStyle: FontStyle.italic,
      color: const Color(0xFF4A4A4A),
      height: 1.4,
    );

    return Scaffold(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Moodly',
                            style: brandTitleStyle,
                          ),
                          const SizedBox(height: 36),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 34, 24, 30),
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
                                Container(
                                  width: 146,
                                  height: 146,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: const Color(0xFFFFEEF2),
                                    border: Border.all(
                                      color: AppColors.primary,
                                      width: 6,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 16,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.celebration_rounded,
                                    size: 74,
                                    color: AppColors.primary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'Akun Berhasil\nDibuat!',
                                  textAlign: TextAlign.center,
                                  style: titleStyle,
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Perjalananmu menuju hidup yang lebih tenang dimulai di sini. Kami senang kamu sudah bergabung bersama Moodly.',
                                  textAlign: TextAlign.center,
                                  style: bodyStyle,
                                ),
                                const SizedBox(height: 26),
                                MoodlyPrimaryButton(
                                  label: 'Ke Beranda',
                                  width: double.infinity,
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SplashScreenMoodly(),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Data Anda dilindungi oleh\nkebijakan privasi kami.',
                            textAlign: TextAlign.center,
                            style: footnoteStyle,
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
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