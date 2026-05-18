import 'package:flutter/material.dart';
import '../../core/styles/moodly_colors.dart';

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
    return width > 390 ? 390 : width;
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: pageWidth,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Ubah Kata Sandi',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 56),

                  const _PasswordInfoCard(),

                  const SizedBox(height: 64),

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

                  const SizedBox(height: 34),

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

                  const SizedBox(height: 34),

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

                  const SizedBox(height: 58),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoodlyColors.green,
                        foregroundColor: Colors.white,
                        elevation: 12,
                        shadowColor: Colors.black.withOpacity(0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              'Ubah Kata Sandi',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(Icons.arrow_forward_rounded, size: 30),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 42),

                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Batal',
                        style: TextStyle(
                          color: MoodlyColors.green,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
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

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: onBack,
          child: const Icon(
            Icons.arrow_back,
            color: MoodlyColors.green,
            size: 22,
          ),
        ),

        const SizedBox(width: 6),

        Text(
          title,
          style: const TextStyle(
            color: MoodlyColors.green,
            fontSize: 17,
            fontWeight: FontWeight.w700,
          ),
        ),

        const Spacer(),

        const Text(
          'Moodly',
          style: TextStyle(
            color: Color(0xFFC65F59),
            fontSize: 32,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
          ),
        ),
      ],
    );
  }
}

class _PasswordInfoCard extends StatelessWidget {
  const _PasswordInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFC8C8),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            color: MoodlyColors.green,
            size: 40,
          ),

          SizedBox(width: 18),

          Expanded(
            child: Text(
              'Memilih kata sandi yang unik membantu menjaga keamanan ruang digital Anda. Kami menyarankan campuran simbol, angka, dan kenangan yang hanya Anda yang tahu.',
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
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
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),

        const SizedBox(height: 14),

        Container(
          height: 78,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.14),
                blurRadius: 24,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 34,
                color: Colors.black,
              ),

              const SizedBox(width: 18),

              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText,
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '••••••••••••',
                    hintStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
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
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}