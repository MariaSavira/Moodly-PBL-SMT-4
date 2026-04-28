import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle brandTitle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: AppColors.brandTitle,
    letterSpacing: 1.2,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    letterSpacing: 0.3,
  );

  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    letterSpacing: 0.5,
  );

  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.linkGreen,
  );

  static const TextStyle hintText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textHint,
  );

  static const TextStyle errorTitle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.error,
  );

  static const TextStyle errorBody = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle forgotPassword = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle dividerText = TextStyle(
    fontSize: 13,
    fontStyle: FontStyle.italic,
    color: AppColors.textSecondary,
  );
}