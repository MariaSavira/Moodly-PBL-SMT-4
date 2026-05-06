import 'package:flutter/material.dart';

enum CutePopupType { success, info, warning, error }

void showCuteTopPopup(
  BuildContext context, {
  required String title,
  required String message,
  CutePopupType type = CutePopupType.info,
  Duration duration = const Duration(seconds: 2),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;

  entry = OverlayEntry(
    builder: (_) => _CuteTopPopup(
      title: title,
      message: message,
      type: type,
      duration: duration,
      onDismiss: () {
        entry.remove();
      },
    ),
  );

  overlay.insert(entry);
}

class _CuteTopPopup extends StatefulWidget {
  final String title;
  final String message;
  final CutePopupType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _CuteTopPopup({
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_CuteTopPopup> createState() => _CuteTopPopupState();
}

class _CuteTopPopupState extends State<_CuteTopPopup> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      setState(() => _visible = true);

      await Future.delayed(widget.duration);

      if (!mounted) return;
      setState(() => _visible = false);

      await Future.delayed(const Duration(milliseconds: 280));

      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final style = _popupStyle(widget.type);
    final screenWidth = MediaQuery.of(context).size.width;

    return IgnorePointer(
      ignoring: true,
      child: Material(
        color: Colors.transparent,
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 10),
              child: AnimatedSlide(
                offset: _visible ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOut,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenWidth * 0.72,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: style.backgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: style.borderColor,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 14,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: style.iconBackgroundColor,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                style.icon,
                                size: 18,
                                color: style.iconColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF2F2F2F),
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.message,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Color(0xFF5A5A5A),
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupStyleData {
  final Color backgroundColor;
  final Color borderColor;
  final Color iconBackgroundColor;
  final Color iconColor;
  final IconData icon;

  const _PopupStyleData({
    required this.backgroundColor,
    required this.borderColor,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.icon,
  });
}

_PopupStyleData _popupStyle(CutePopupType type) {
  switch (type) {
    case CutePopupType.success:
      return const _PopupStyleData(
        backgroundColor: Color(0xFFF1FAEE),
        borderColor: Color(0xFF99D28F),
        iconBackgroundColor: Color(0xFFDDF3D6),
        iconColor: Color(0xFF4E8B44),
        icon: Icons.favorite_rounded,
      );

    case CutePopupType.warning:
      return const _PopupStyleData(
        backgroundColor: Color(0xFFFFF8E8),
        borderColor: Color(0xFFF2D38B),
        iconBackgroundColor: Color(0xFFFFEDC2),
        iconColor: Color(0xFFC58A00),
        icon: Icons.star_rounded,
      );

    case CutePopupType.error:
      return const _PopupStyleData(
        backgroundColor: Color(0xFFFFF0F1),
        borderColor: Color(0xFFFFC4CC),
        iconBackgroundColor: Color(0xFFFFDEE3),
        iconColor: Color(0xFFD95067),
        icon: Icons.close_rounded,
      );

    case CutePopupType.info:
      return const _PopupStyleData(
        backgroundColor: Color(0xFFEFF7FF),
        borderColor: Color(0xFFB7D9F6),
        iconBackgroundColor: Color(0xFFD8EDFF),
        iconColor: Color(0xFF3E8CCB),
        icon: Icons.info_rounded,
      );
  }
}