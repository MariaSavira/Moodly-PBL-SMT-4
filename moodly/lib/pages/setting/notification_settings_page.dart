import 'package:flutter/material.dart';

import '../../core/styles/moodly_colors.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool dailyNote = false;
  bool morningAwareness = true;
  bool lowMoodAlert = true;
  bool achievementAlert = false;
  bool appUpdate = true;
  bool securityAlert = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final horizontalPadding = isSmall ? 22.0 : 28.0;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                16,
                horizontalPadding,
                32,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Pemberitahuan',
                    onBack: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 26),

                  Text(
                    'Personalisasi peringatan ruang Anda.\n'
                    'Pilih notifikasi mana yang membantu\n'
                    'Anda tetap sadar dan terhubung.',
                    style: TextStyle(
                      fontSize: isSmall ? 15 : 16,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 38),

                  const _SectionTitle('UMUM'),
                  const SizedBox(height: 12),

                  _NotificationCard(
                    children: [
                      _NotificationItem(
                        title: 'Pencatatan Harian',
                        subtitle:
                            'Pengingat halus untuk mencatat suasana hati Anda',
                        value: dailyNote,
                        onChanged: (value) {
                          setState(() => dailyNote = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      _NotificationItem(
                        title: 'Kesadaran Pagi',
                        subtitle:
                            'Mulailah hari Anda dengan anjuran yang menenangkan',
                        value: morningAwareness,
                        onChanged: (value) {
                          setState(() => morningAwareness = value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  const _SectionTitle('WAWASAN'),
                  const SizedBox(height: 12),

                  _NotificationCard(
                    children: [
                      _NotificationItem(
                        title: 'Peringatan Mood Rendah',
                        subtitle: 'Terima laporan jika tren mood Anda turun',
                        value: lowMoodAlert,
                        onChanged: (value) {
                          setState(() => lowMoodAlert = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      _NotificationItem(
                        title: 'Peringatan Pencapaian',
                        subtitle:
                            'Rayakan pencapaian kesadaran mindfulness Anda',
                        value: achievementAlert,
                        onChanged: (value) {
                          setState(() => achievementAlert = value);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 34),

                  const _SectionTitle('SISTEM'),
                  const SizedBox(height: 12),

                  _NotificationCard(
                    children: [
                      _NotificationItem(
                        title: 'Pembaruan Aplikasi',
                        subtitle: 'Dapatkan informasi fitur dan perbaikan baru',
                        value: appUpdate,
                        onChanged: (value) {
                          setState(() => appUpdate = value);
                        },
                      ),
                      const SizedBox(height: 22),
                      _NotificationItem(
                        title: 'Peringatan Keamanan',
                        subtitle: 'Notifikasi untuk aktivitas keamanan akun',
                        value: securityAlert,
                        onChanged: (value) {
                          setState(() => securityAlert = value);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
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
  final String title;

  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: MoodlyColors.green,
        fontSize: 17,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final List<Widget> children;

  const _NotificationCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 18, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotificationItem({
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: isSmall ? 17 : 18,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    subtitle!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black.withValues(alpha: 0.72),
                      fontSize: isSmall ? 12 : 13,
                      height: 1.25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Transform.scale(
          scale: isSmall ? 0.66 : 0.70,
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
    );
  }
}