import 'package:flutter/material.dart';

Future<void> showStreakFeedbackPopup(
  BuildContext context, {
  required String title,
  required String message,
  required IconData icon,
  required Color accent,
  String? chipLabel,
  String? secondaryChipLabel,
  String buttonLabel = 'Oke',
}) {
  return showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.42),
    builder: (_) => _StreakFeedbackPopup(
      title: title,
      message: message,
      icon: icon,
      accent: accent,
      chipLabel: chipLabel,
      secondaryChipLabel: secondaryChipLabel,
      buttonLabel: buttonLabel,
    ),
  );
}

class _StreakFeedbackPopup extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color accent;
  final String? chipLabel;
  final String? secondaryChipLabel;
  final String buttonLabel;

  const _StreakFeedbackPopup({
    required this.title,
    required this.message,
    required this.icon,
    required this.accent,
    this.chipLabel,
    this.secondaryChipLabel,
    required this.buttonLabel,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFDF9),
          borderRadius: BorderRadius.circular(28),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.14),
              offset: Offset(0, 8),
              blurRadius: 18,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withOpacity(0.18),
              ),
              child: Icon(
                icon,
                color: accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.headlineLarge?.copyWith(
                fontSize: 24,
                color: const Color(0xFF222222),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontSize: 13,
                height: 1.5,
                color: const Color(0xFF6F7A67),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (chipLabel != null || secondaryChipLabel != null) ...[
              const SizedBox(height: 14),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (chipLabel != null)
                    _PopupChip(
                      label: chipLabel!,
                      accent: accent,
                    ),
                  if (secondaryChipLabel != null)
                    _PopupChip(
                      label: secondaryChipLabel!,
                      accent: const Color(0xFF84C76A),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: const Color(0xFF84C76A),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupChip extends StatelessWidget {
  final String label;
  final Color accent;

  const _PopupChip({
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: accent,
        ),
      ),
    );
  }
}