import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class SocialSignInButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback? onPressed;

  const SocialSignInButton({
    super.key,
    required this.label,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.socialBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(width: 22, height: 22, child: icon),
          const SizedBox(width: 8),
          Text(label, style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.socialText,
            fontWeight: FontWeight.w500,
          )),
        ],
      ),
    );
  }
}