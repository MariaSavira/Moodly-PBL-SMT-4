import 'package:flutter/material.dart';
import 'setting/moodly_settings_support.dart';
import '../core/services/moodly_notification_service.dart';
import '../models/moodly_notification_model.dart';
import 'afirmasi/widgets/cute_top_popup.dart';
import 'pages.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  static const Color _bg = Color(0xFFF1F5E4);
  static const Color _card = Colors.white;
  static const Color _green = Color(0xFF82C46B);
  static const Color _greenSoft = Color(0xFFDDEFCF);
  static const Color _pinkSoft = Color(0xFFFFEEF2);
  static const Color _peachSoft = Color(0xFFFFE9DE);
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
      default:
        return _peachSoft;
    }
  }

  Future<void> _handleTap(
    BuildContext context,
    MoodlyNotificationModel item,
  ) async {
    await MoodlyNotificationService.instance.markAsRead(item.id);

    if (!context.mounted) return;

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
      title: item.title,
      message: item.message,
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
                                    'Nanti notifikasi check-in mood dan dukungan saat mood berat akan muncul di sini.',
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

                          return GestureDetector(
                            onTap: () => _handleTap(context, item),
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
                                                item.title,
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
                                          item.message,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: _textSoft,
                                                height: 1.5,
                                              ),
                                        ),
                                        if (item.ctaLabel != null) ...[
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
                                              item.ctaLabel!,
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
