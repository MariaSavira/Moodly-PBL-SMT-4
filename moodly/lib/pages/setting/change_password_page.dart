import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';
import '../../widgets/shared/moodly_settings_header.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool currentObscure = true;
  bool newObscure = true;
  bool confirmObscure = true;

  @override
  void dispose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: pageWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MoodlySettingsHeader(
                    title: 'Ubah Kata Sandi',
                  ),
                  const SizedBox(height: 32),
                  const _PasswordInfoCard(),
                  const SizedBox(height: 32),
                  _PasswordInput(
                    label: 'Kata Sandi Saat Ini',
                    controller: currentPasswordController,
                    icon: Icons.lock_open_rounded,
                    obscureText: currentObscure,
                    onToggle: () {
                      setState(() {
                        currentObscure = !currentObscure;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  _PasswordInput(
                    label: 'Kata Sandi Baru',
                    controller: newPasswordController,
                    icon: Icons.lock_rounded,
                    obscureText: newObscure,
                    onToggle: () {
                      setState(() {
                        newObscure = !newObscure;
                      });
                    },
                  ),
                  const SizedBox(height: 22),
                  _PasswordInput(
                    label: 'Konfirmasi Kata Sandi Baru',
                    controller: confirmPasswordController,
                    icon: Icons.verified_user_rounded,
                    obscureText: confirmObscure,
                    onToggle: () {
                      setState(() {
                        confirmObscure = !confirmObscure;
                      });
                    },
                  ),
                  const SizedBox(height: 34),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoodlyColors.green,
                        foregroundColor: Colors.white,
                        elevation: 8,
                        shadowColor: Colors.black.withOpacity(0.16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: const Text(
                        'Ubah Kata Sandi',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: MoodlyColors.green,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PasswordInfoCard extends StatelessWidget {
  const _PasswordInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD8D8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: MoodlyColors.green,
            size: 30,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Memilih kata sandi yang unik membantu menjaga keamanan ruang digital Anda.',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PasswordInput extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final bool obscureText;
  final VoidCallback onToggle;

  const _PasswordInput({
    required this.label,
    required this.controller,
    required this.icon,
    required this.obscureText,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 58,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.10),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 24,
                color: Colors.black,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••••••••••',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: onToggle,
                child: Icon(
                  obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: Colors.grey,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}