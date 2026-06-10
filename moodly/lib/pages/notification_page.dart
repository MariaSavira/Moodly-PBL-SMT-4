import 'package:flutter/material.dart';
import 'setting/moodly_settings_support.dart';
import '../core/services/moodly_notification_service.dart';
import '../models/moodly_notification_model.dart';
import 'afirmasi/widgets/cute_top_popup.dart';
import 'pages.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  static const Color _bg = Color(0xFFF1F5E4);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF82C46B);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _peachSoft = Color(0xFFFFE9DE);
  static const Color _mintSoft = Color(0xFFEFFAF7);
  static const Color _lavenderSoft = Color(0xFFF5EAFB);
  static const Color _textDark = Color(0xFF1F1F1F);
  static const Color _textSoft = Color(0xFF677164);

  static const Map<String, Map<String, String>> _copy = {
    'id': {
      'header': 'Notifikasi',
      'readAll': 'Baca semua',
      'done': 'Selesai',
      'allRead': 'Semua notifikasi ditandai sudah dibaca.',
      'emptyTitle': 'Belum ada notifikasi',
      'emptyBody':
          'Kalau nanti ada pengingat atau sinyal penting, mereka akan muncul di sini.',
    },
    'en': {
      'header': 'Notifications',
      'readAll': 'Read all',
      'done': 'Done',
      'allRead': 'All notifications have been marked as read.',
      'emptyTitle': 'No notifications yet',
      'emptyBody':
          'If reminders or important signals arrive later, they will appear here.',
    },
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await MoodlyNotificationService.instance.syncForCurrentUser();
    });
  }

  String _t(String languageCode, String key) =>
      _copy[languageCode]?[key] ?? key;

  List<BoxShadow> get _softShadow => const [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.10),
      offset: Offset(0, 6),
      blurRadius: 18,
      spreadRadius: 0,
    ),
  ];

  IconData _iconForType(String type) {
    switch (type) {
      case 'daily_checkin':
        return Icons.edit_note_rounded;
      case 'low_mood':
        return Icons.favorite_rounded;
      case 'morning_awareness':
        return Icons.wb_sunny_rounded;
      case 'achievement':
        return Icons.emoji_events_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _bgForType(String type) {
    switch (type) {
      case 'daily_checkin':
        return _greenSoft;
      case 'low_mood':
        return _pinkSoft;
      case 'morning_awareness':
        return _peachSoft;
      case 'achievement':
        return _lavenderSoft;
      default:
        return _mintSoft;
    }
  }

  ({String title, String message, String? ctaLabel}) _localizedNotif(
    String languageCode,
    MoodlyNotificationModel item,
  ) {
    switch (item.type) {
      case 'daily_checkin':
        return (
          title: languageCode == 'en'
              ? 'Don’t forget your mood check-in'
              : 'Jangan lupa check-in mood',
          message: languageCode == 'en'
              ? 'Try recording how you feel today. One small step still matters.'
              : 'Coba catat perasaanmu hari ini. Satu langkah kecil tetap berarti.',
          ctaLabel: languageCode == 'en' ? 'Log mood' : 'Isi mood',
        );

      case 'low_mood':
        return (
          title: languageCode == 'en'
              ? 'Your mood seems quite heavy'
              : 'Moodmu terlihat cukup berat',
          message: languageCode == 'en'
              ? 'Two of your last three mood entries were heavy. Try opening emergency support or seeking professional help.'
              : 'Dua dari tiga catatan mood terakhirmu cenderung berat. Coba buka bantuan darurat atau cari dukungan profesional.',
          ctaLabel: languageCode == 'en' ? 'View help' : 'Lihat bantuan',
        );

      case 'morning_awareness':
        return (
          title: languageCode == 'en'
              ? 'Good morning, take a gentle pause'
              : 'Selamat pagi, ambil jeda sebentar',
          message: languageCode == 'en'
              ? 'Start your day a little more calmly today.'
              : 'Mulai harimu dengan sedikit lebih tenang hari ini.',
          ctaLabel: languageCode == 'en' ? 'Take a breath' : 'Tarik napas',
        );

      case 'achievement':
        return (
          title: languageCode == 'en'
              ? 'Celebrate your small progress'
              : 'Rayakan progres kecilmu',
          message: languageCode == 'en'
              ? 'Even a small step still counts today.'
              : 'Langkah kecilmu tetap berarti hari ini.',
          ctaLabel: languageCode == 'en' ? 'See reminder' : 'Lihat pengingat',
        );

      default:
        return (
          title: item.title,
          message: item.message,
          ctaLabel: item.ctaLabel,
        );
    }
  }

  Future<void> _handleTap(
    BuildContext context,
    MoodlyNotificationModel item,
    String languageCode,
  ) async {
    await MoodlyNotificationService.instance.markAsRead(item.id);

    if (!context.mounted) return;
    final localized = _localizedNotif(languageCode, item);

    if (item.type == 'daily_checkin') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => MoodInput(selectedDate: DateTime.now()),
        ),
      );
      return;
    }

    if (item.type == 'low_mood') {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EmergencySupportPage()),
      );
      return;
    }

    showCuteTopPopup(
      context,
      title: localized.title,
      message: localized.message,
      type: CutePopupType.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: MoodlySettingsPrefs.languageNotifier,
      builder: (context, languageCode, _) {
        return Scaffold(
          backgroundColor: _bg,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.88),
                            shape: BoxShape.circle,
                            boxShadow: _softShadow,
                          ),
                          child: const Icon(
                            Icons.arrow_back_rounded,
                            color: _textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _t(languageCode, 'header'),
                          style: Theme.of(
                            context,
                          ).textTheme.headlineLarge?.copyWith(color: _textDark),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await MoodlyNotificationService.instance
                              .markAllAsRead();
                          if (!context.mounted) return;

                          showCuteTopPopup(
                            context,
                            title: _t(languageCode, 'done'),
                            message: _t(languageCode, 'allRead'),
                            type: CutePopupType.success,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: _greenSoft,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: _softShadow,
                          ),
                          child: Text(
                            _t(languageCode, 'readAll'),
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: _textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: StreamBuilder<List<MoodlyNotificationModel>>(
                    stream: MoodlyNotificationService.instance
                        .watchNotifications(),
                    builder: (context, snapshot) {
                      final items = snapshot.data ?? [];

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(color: _green),
                        );
                      }

                      if (items.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(28),
                                boxShadow: _softShadow,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 62,
                                    height: 62,
                                    decoration: BoxDecoration(
                                      color: _greenSoft,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications_none_rounded,
                                      color: _green,
                                      size: 30,
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Text(
                                    _t(languageCode, 'emptyTitle'),
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(color: _textDark),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _t(languageCode, 'emptyBody'),
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: _textSoft,
                                          height: 1.5,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.separated(
                        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          final bg = _bgForType(item.type);
                          final localized = _localizedNotif(languageCode, item);

                          return GestureDetector(
                            onTap: () => _handleTap(context, item, languageCode),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _card,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: _softShadow,
                                border: item.isRead
                                    ? null
                                    : Border.all(
                                        color: const Color(0xFFE9AAB3),
                                        width: 1.2,
                                      ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: bg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _iconForType(item.type),
                                      color: _textDark,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                localized.title,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      color: _textDark,
                                                    ),
                                              ),
                                            ),
                                            if (!item.isRead)
                                              Container(
                                                width: 9,
                                                height: 9,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: Color(0xFFE85E73),
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          localized.message,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: _textSoft,
                                                height: 1.5,
                                              ),
                                        ),
                                        if (localized.ctaLabel != null) ...[
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 8,
                                            ),
                                            decoration: BoxDecoration(
                                              color: bg,
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            child: Text(
                                              localized.ctaLabel!,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: _textDark,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
