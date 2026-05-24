import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';
import '../pages.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool is2FAEnabled = false;

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
        child: Center(
          child: SizedBox(
            width: pageWidth,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(26, 16, 26, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Keamanan',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 44),

                  const _SectionTitle('PASSWORD'),
                  const SizedBox(height: 14),

                  _PasswordCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 34),

                  const _SectionTitle('OTENTIKASI DUA FAKTOR'),
                  const SizedBox(height: 14),

                  _TwoFactorCard(
                    value: is2FAEnabled,
                    onChanged: (value) {
                      setState(() {
                        is2FAEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: 34),

                  const _SectionTitle('AKTIVITAS LOGIN'),
                  const SizedBox(height: 14),

                  const _DeviceCard(
                    icon: Icons.phone_iphone_rounded,
                    title: 'iPhone 15 Pro Max',
                    subtitle: 'Indonesia, IDN • Aktif sekarang',
                    badge: 'Sesi saat ini',
                  ),

                  const SizedBox(height: 14),

                  const _DeviceCard(
                    icon: Icons.laptop_mac_rounded,
                    title: 'MacBook Pro 14',
                    subtitle: 'Indonesia, IDN • 2 hari yang lalu',
                  ),

                  const SizedBox(height: 34),

                  const _SecurityInfoCard(),
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

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: MoodlyColors.green,
        fontSize: 16,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PasswordCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: isSmall ? 46 : 50,
              height: isSmall ? 46 : 50,
              decoration: BoxDecoration(
                color: MoodlyColors.greenLight,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: MoodlyColors.green,
                size: 28,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'Ubah Kata Sandi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: isSmall ? 18 : 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.arrow_forward_rounded,
              color: MoodlyColors.green,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _TwoFactorCard extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _TwoFactorCard({
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: isSmall ? 46 : 50,
            height: isSmall ? 46 : 50,
            decoration: BoxDecoration(
              color: MoodlyColors.greenLight,
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.verified_user_rounded,
              color: MoodlyColors.green,
              size: 27,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aktifkan 2FA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 17 : 19,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Tambahkan lapisan keamanan ekstra ke akun Anda.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    height: 1.3,
                    color: Colors.black.withValues(alpha: 0.70),
                  ),
                ),
              ],
            ),
          ),

          Transform.scale(
            scale: isSmall ? 0.68 : 0.72,
            child: Switch(
              value: value,
              activeColor: Colors.white,
              activeTrackColor: MoodlyColors.green,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.black.withValues(alpha: 0.45),
              trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _DeviceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? badge;

  const _DeviceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isSmall ? 44 : 48,
            height: isSmall ? 44 : 48,
            decoration: BoxDecoration(
              color: MoodlyColors.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: MoodlyColors.green,
              size: isSmall ? 26 : 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isSmall ? 15 : 16,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    if (badge != null) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: MoodlyColors.greenLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    color: Colors.black.withValues(alpha: 0.70),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SecurityInfoCard extends StatelessWidget {
  const _SecurityInfoCard();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD8D0),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.09),
            blurRadius: 16,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.health_and_safety_rounded,
            color: MoodlyColors.green,
            size: 36,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              'Menjaga keamanan akun membantu melindungi data dan ruang pribadi Anda.',
              style: TextStyle(
                fontSize: isSmall ? 14 : 15,
                height: 1.45,
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