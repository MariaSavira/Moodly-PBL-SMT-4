import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/services/notification_service.dart';
import '../afirmasi/widgets/cute_top_popup.dart';
import 'moodly_settings_support.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _dailyNote = false;
  bool _morningAwareness = true;
  bool _achievementAlert = false;
  bool _isLoadingPrefs = true;
  bool _isBusy = false;
  String _languageCode = MoodlySettingsPrefs.currentLanguageCode;

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Notifikasi',
      'title': 'Atur pengingat yang memang berguna',
      'description':
          'Toggle benar-benar disimpan dan akan menjadwalkan atau membatalkan notifikasi sesuai pilihanmu.',
      'general': 'Umum',
      'insight': 'Wawasan',
      'dailyTitle': 'Pencatatan Harian',
      'dailyBody': 'Pengingat untuk mencatat suasana hati setiap malam.',
      'morningTitle': 'Kesadaran Pagi',
      'morningBody': 'Ajakan singkat untuk mulai hari dengan lebih tenang.',
      'achievementTitle': 'Pencapaian Kecil',
      'achievementBody': 'Pengingat untuk merayakan progres kecilmu.',
      'info': 'Kalau izin notifikasi perangkat mati, toggle tetap tersimpan tapi notifikasi jelas tidak muncul.',
      'testButton': 'Test Notifikasi',
      'testSent': 'Test notifikasi dikirim. Cek panel notifikasimu.',
      'saveFailed': 'Gagal memperbarui pengaturan notifikasi.',
      'initFailed': 'Layanan notifikasi belum siap. Biasanya ini soal permission atau konfigurasi Android.',
    },
    'en': {
      'header': 'Notifications',
      'title': 'Keep only reminders that matter',
      'description':
          'Each toggle is stored and will schedule or cancel notifications based on your choice.',
      'general': 'General',
      'insight': 'Insight',
      'dailyTitle': 'Daily Mood Check-In',
      'dailyBody': 'A reminder to log your mood every evening.',
      'morningTitle': 'Morning Awareness',
      'morningBody': 'A short prompt to start the day more calmly.',
      'achievementTitle': 'Small Wins',
      'achievementBody': 'A reminder to celebrate your small progress.',
      'info': 'If notification permission is off on your device, these toggles are still saved but notifications will obviously not appear.',
      'testButton': 'Test Notification',
      'testSent': 'Test notification sent. Check your notification panel.',
      'saveFailed': 'Failed to update notification settings.',
      'initFailed': 'Notification service is not ready yet. Usually this means permission or Android setup issues.',
    },
  };

  @override
  void initState() {
    super.initState();
    MoodlySettingsPrefs.languageNotifier.addListener(_onLanguageChanged);
    _initialize();
  }

  void _onLanguageChanged() {
    if (!mounted) return;
    setState(() {
      _languageCode = MoodlySettingsPrefs.languageNotifier.value;
    });
  }

  @override
  void dispose() {
    MoodlySettingsPrefs.languageNotifier.removeListener(_onLanguageChanged);
    super.dispose();
  }

  Future<void> _initialize() async {
    final language = await MoodlySettingsPrefs.loadLanguageCode();

    try {
      await NotificationService.instance.initialize();
    } catch (e) {
      debugPrint('Notification init error: $e');
      if (mounted) {
        showCuteTopPopup(
          context,
          title: 'Oops',
          message: language == 'en'
              ? _copy['en']!['initFailed']!
              : _copy['id']!['initFailed']!,
          type: CutePopupType.error,
        );
      }
    }

    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;
    setState(() {
      _languageCode = language;
      _dailyNote = prefs.getBool('dailyNote') ?? false;
      _morningAwareness = prefs.getBool('morningAwareness') ?? true;
      _achievementAlert = prefs.getBool('achievementAlert') ?? false;
      _isLoadingPrefs = false;
    });
  }

  String _t(String key) => _copy[_languageCode]?[key] ?? key;

  double _pageWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width > 430 ? 430 : width;
  }

  Future<void> _saveBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Future<void> _updateSetting({
    required String key,
    required bool value,
    required void Function(bool value) applyLocal,
    required Future<void> Function() onEnabled,
    required Future<void> Function() onDisabled,
  }) async {
    final previousDaily = _dailyNote;
    final previousMorning = _morningAwareness;
    final previousAchievement = _achievementAlert;

    setState(() {
      _isBusy = true;
      applyLocal(value);
    });

    try {
      await _saveBool(key, value);
      if (value) {
        await onEnabled();
      } else {
        await onDisabled();
      }
    } catch (e) {
      debugPrint('Notification update error: $e');
      if (!mounted) return;
      setState(() {
        _dailyNote = previousDaily;
        _morningAwareness = previousMorning;
        _achievementAlert = previousAchievement;
      });
      showCuteTopPopup(
        context,
        title: 'Oops',
        message: _t('saveFailed'),
        type: CutePopupType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  Future<void> _testNotification() async {
    try {
      await NotificationService.instance.initialize();
      await NotificationService.instance.showInstantNotification(
        title: 'Moodly 🌿',
        body: _languageCode == 'en'
            ? 'Your test notification works.'
            : 'Notifikasi percobaan berhasil muncul.',
      );
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'OK',
        message: _t('testSent'),
        type: CutePopupType.success,
      );
    } catch (e) {
      debugPrint('Notification test error: $e');
      if (!mounted) return;
      showCuteTopPopup(
        context,
        title: 'Oops',
        message: _t('saveFailed'),
        type: CutePopupType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = MoodlySettingsPalette.of();
    final pageWidth = _pageWidth(context);

    if (_isLoadingPrefs) {
      return Scaffold(
        backgroundColor: palette.bg,
        body: Center(child: CircularProgressIndicator(color: palette.greenDark)),
      );
    }

    return Scaffold(
      backgroundColor: palette.bg,
      body: Stack(
        children: [
          MoodlySettingsBackground(palette: palette),
          SafeArea(
            child: Center(
              child: SizedBox(
                width: pageWidth,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MoodlySettingsHeader(
                        palette: palette,
                        title: _t('header'),
                        onBack: () => Navigator.pop(context),
                      ),
                      const SizedBox(height: 22),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _t('title'),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: palette.textDark,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _t('description'),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: palette.textSoft,
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySectionTitle(palette: palette, title: _t('general')),
                      const SizedBox(height: 12),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Column(
                          children: [
                            MoodlySwitchTile(
                              palette: palette,
                              icon: Icons.calendar_month_rounded,
                              iconColor: palette.greenDark,
                              title: _t('dailyTitle'),
                              subtitle: _t('dailyBody'),
                              value: _dailyNote,
                              onChanged: _isBusy
                                  ? (_) {}
                                  : (value) => _updateSetting(
                                        key: 'dailyNote',
                                        value: value,
                                        applyLocal: (newValue) => _dailyNote = newValue,
                                        onEnabled: () => NotificationService.instance.scheduleDailyMoodReminder(),
                                        onDisabled: () => NotificationService.instance.cancelDailyMoodReminder(),
                                      ),
                            ),
                            const SizedBox(height: 12),
                            MoodlySwitchTile(
                              palette: palette,
                              icon: Icons.wb_sunny_rounded,
                              iconColor: palette.preferenceIcon,
                              title: _t('morningTitle'),
                              subtitle: _t('morningBody'),
                              value: _morningAwareness,
                              onChanged: _isBusy
                                  ? (_) {}
                                  : (value) => _updateSetting(
                                        key: 'morningAwareness',
                                        value: value,
                                        applyLocal: (newValue) => _morningAwareness = newValue,
                                        onEnabled: () => NotificationService.instance.scheduleMorningAwarenessReminder(),
                                        onDisabled: () => NotificationService.instance.cancelMorningAwarenessReminder(),
                                      ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySectionTitle(palette: palette, title: _t('insight')),
                      const SizedBox(height: 12),
                      MoodlySettingsCard(
                        palette: palette,
                        child: MoodlySwitchTile(
                          palette: palette,
                          icon: Icons.emoji_events_rounded,
                          iconColor: palette.preferenceIcon,
                          title: _t('achievementTitle'),
                          subtitle: _t('achievementBody'),
                          value: _achievementAlert,
                          onChanged: _isBusy
                              ? (_) {}
                              : (value) => _updateSetting(
                                    key: 'achievementAlert',
                                    value: value,
                                    applyLocal: (newValue) => _achievementAlert = newValue,
                                    onEnabled: () => NotificationService.instance.scheduleAchievementReminder(),
                                    onDisabled: () => NotificationService.instance.cancelAchievementReminder(),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlySettingsCard(
                        palette: palette,
                        child: Text(
                          _t('info'),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: palette.textSoft,
                                height: 1.45,
                              ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      MoodlyPrimaryButton(
                        palette: palette,
                        label: _t('testButton'),
                        onPressed: _isBusy ? null : _testNotification,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
