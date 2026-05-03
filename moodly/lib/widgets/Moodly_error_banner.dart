import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class MoodlyErrorBanner extends StatelessWidget {
  final String title;
  final String? description;
  final String? actionLabel;
  final VoidCallback? onAction;

  const MoodlyErrorBanner({
    super.key,
    required this.title,
    this.description,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 250,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.errorBackground,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.error, color: AppColors.error, size: 18),
            const SizedBox(width: 7),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: AppTextStyles.errorBody,
                  children: [
                    TextSpan(text: '$title\n', style: AppTextStyles.errorTitle),
                    if (description != null) TextSpan(text: '$description\n'),
                    if (actionLabel != null)
                      TextSpan(
                        text: actionLabel!,
                        style: AppTextStyles.errorTitle.copyWith(fontSize: 20),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}