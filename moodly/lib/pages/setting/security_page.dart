import 'package:flutter/material.dart';
import '../../core/styles/moodly_colors.dart';
import 'change_password_page.dart';

class SecurityPage extends StatefulWidget {
  const SecurityPage({super.key});

  @override
  State<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends State<SecurityPage> {
  bool is2FAEnabled = false;

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
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Keamanan',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 72),

                  const _SectionTitle('Password'),

                  const SizedBox(height: 22),

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

                  const SizedBox(height: 44),

                  const _SectionTitle('OTENTIKASI DUA FAKTOR'),

                  const SizedBox(height: 22),

                  _TwoFactorCard(
                    value: is2FAEnabled,
                    onChanged: (value) {
                      setState(() {
                        is2FAEnabled = value;
                      });
                    },
                  ),

                  const SizedBox(height: 44),

                  const _SectionTitle('AKTIFITAS LOGIN'),

                  const SizedBox(height: 22),

                  const _DeviceCard(
                    icon: Icons.phone_iphone_rounded,
                    title: 'Iphone 15 Pro Max',
                    subtitle: 'Indonesia,IDN . Aktif sekarang',
                    badge: 'sesi saat ini',
                  ),

                  const SizedBox(height: 18),

                  const _DeviceCard(
                    icon: Icons.laptop_mac_rounded,
                    title: 'Macbook Pro 14',
                    subtitle: 'Indonesia,IDN . 2 hari yang lalu',
                  ),

                  const SizedBox(height: 64),

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
        fontSize: 20,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _PasswordCard extends StatelessWidget {
  final VoidCallback onTap;

  const _PasswordCard({
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.16),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: width * 0.12,
              height: width * 0.12,
              constraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 48,
                maxWidth: 58,
                maxHeight: 58,
              ),
              decoration: BoxDecoration(
                color: MoodlyColors.greenLight,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                color: MoodlyColors.green,
                size: 32,
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                'Ubah Kata Sandi',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: width < 360 ? 20 : 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),

            const SizedBox(width: 10),

            const Icon(
              Icons.arrow_forward_rounded,
              color: MoodlyColors.green,
              size: 34,
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
    final width = MediaQuery.of(context).size.width;

    return Container(
      constraints: const BoxConstraints(
        minHeight: 110,
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 16, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.16),
            blurRadius: 26,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          'Aktifkan 2FA',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: width < 360 ? 18 : 21,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(width: 6),

                      const Icon(
                        Icons.verified_rounded,
                        color: MoodlyColors.green,
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Tambahkan lapisan keamanan ekstra ke akun anda.',
                    style: TextStyle(
                      fontSize: width < 360 ? 13 : 15,
                      height: 1.35,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),

          Transform.scale(
            scale: 0.82,
            child: Switch(
              value: value,
              activeColor: MoodlyColors.green,
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
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: MoodlyColors.greenLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: MoodlyColors.green,
              size: 30,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    if (badge != null) ...[
                      const SizedBox(width: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: MoodlyColors.greenLight,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontSize: 11,
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
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
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
              'Menjaga keamanan akun membantu melindungi data dan ruang pribadi Anda.',
              style: TextStyle(
                fontSize: 17,
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