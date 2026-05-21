import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/notification_service.dart';
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
  bool achievementAlert = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      dailyNote = prefs.getBool('dailyNote') ?? false;
      morningAwareness = prefs.getBool('morningAwareness') ?? true;
      achievementAlert = prefs.getBool('achievementAlert') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _updateSetting({
    required String key,
    required bool value,
    required void Function(bool value) updateState,
    required Future<void> Function() onEnabled,
    required Future<void> Function() onDisabled,
  }) async {
    setState(() {
      updateState(value);
    });

    await _saveNotificationSetting(key, value);

    if (value) {
      await onEnabled();
    } else {
      await onDisabled();
    }
  }

  Future<void> _testNotification() async {
    await NotificationService.instance.showInstantNotification(
      title: 'Moodly 🌿',
      body: 'Notifikasi berhasil muncul di HP kamu.',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Test notifikasi dikirim. Cek notifikasi HP kamu.'),
      ),
    );
  }

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width >= 1200) return 540;
    if (width >= 900) return 500;
    if (width >= 600) return 460;

    return width;
  }

  EdgeInsets _pagePadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 360) {
      return const EdgeInsets.fromLTRB(16, 16, 16, 28);
    }

    if (width < 600) {
      return const EdgeInsets.fromLTRB(22, 16, 22, 32);
    }

    return const EdgeInsets.fromLTRB(26, 18, 26, 34);
  }

  @override
  Widget build(BuildContext context) {
    final pageWidth = _pageWidth(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmall = screenWidth < 380;

    return Scaffold(
      backgroundColor: MoodlyColors.bgLight,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: pageWidth,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: _pagePadding(context),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Header(
                    title: 'Pemberitahuan',
                    onBack: () => Navigator.pop(context),
                  ),

                  SizedBox(height: isSmall ? 22 : 26),

                  Text(
                    'Personalisasi peringatan ruang Anda.\n'
                    'Pilih notifikasi yang membantu Anda\n'
                    'tetap sadar dan terhubung.',
                    style: TextStyle(
                      fontSize: isSmall ? 14 : 16,
                      height: 1.45,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),

                  SizedBox(height: isSmall ? 30 : 38),

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
                          _updateSetting(
                            key: 'dailyNote',
                            value: value,
                            updateState: (newValue) {
                              dailyNote = newValue;
                            },
                            onEnabled: () {
                              return NotificationService.instance
                                  .scheduleDailyMoodReminder();
                            },
                            onDisabled: () {
                              return NotificationService.instance
                                  .cancelDailyMoodReminder();
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 22),
                      _NotificationItem(
                        title: 'Kesadaran Pagi',
                        subtitle:
                            'Mulailah hari Anda dengan anjuran yang menenangkan',
                        value: morningAwareness,
                        onChanged: (value) {
                          _updateSetting(
                            key: 'morningAwareness',
                            value: value,
                            updateState: (newValue) {
                              morningAwareness = newValue;
                            },
                            onEnabled: () {
                              return NotificationService.instance
                                  .scheduleMorningAwarenessReminder();
                            },
                            onDisabled: () {
                              return NotificationService.instance
                                  .cancelMorningAwarenessReminder();
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  SizedBox(height: isSmall ? 30 : 34),

                  const _SectionTitle('WAWASAN'),
                  const SizedBox(height: 12),

                  _NotificationCard(
                    children: [
                      _NotificationItem(
                        title: 'Peringatan Pencapaian',
                        subtitle:
                            'Rayakan pencapaian kesadaran mindfulness Anda',
                        value: achievementAlert,
                        onChanged: (value) {
                          _updateSetting(
                            key: 'achievementAlert',
                            value: value,
                            updateState: (newValue) {
                              achievementAlert = newValue;
                            },
                            onEnabled: () {
                              return NotificationService.instance
                                  .scheduleAchievementReminder();
                            },
                            onDisabled: () {
                              return NotificationService.instance
                                  .cancelAchievementReminder();
                            },
                          );
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  const _InfoNote(),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: _testNotification,
                      icon: const Icon(Icons.notifications_active_rounded),
                      label: const Text('Test Notifikasi'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MoodlyColors.green,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 15,
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

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const _Header({
    required this.title,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

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
          style: TextStyle(
            color: MoodlyColors.green,
            fontSize: isSmall ? 15 : 17,
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
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Text(
      title,
      style: TextStyle(
        color: MoodlyColors.green,
        fontSize: isSmall ? 15 : 17,
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
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        isSmall ? 16 : 20,
        isSmall ? 18 : 20,
        isSmall ? 14 : 18,
        isSmall ? 18 : 20,
      ),
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
      child: Column(children: children),
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
                    fontSize: isSmall ? 16 : 18,
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

class _InfoNote extends StatelessWidget {
  const _InfoNote();

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmall ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEF2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Text(
        'Pengaturan notifikasi lainnya masih dalam pengembangan.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black.withValues(alpha: 0.70),
          fontSize: isSmall ? 12 : 13,
          height: 1.35,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}