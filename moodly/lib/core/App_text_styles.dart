import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  // ── Brand ──
  static const TextStyle brandTitle = TextStyle(
    fontSize: 34,
    fontWeight: FontWeight.w900,
    color: AppColors.brandTitle,
  );

  static const TextStyle brandSubtitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // ── Heading ──
  static const TextStyle heading1 = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w900,
    color: AppColors.textPrimary,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  // ── Body ──
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
  );

  // 🔥 INI YANG TADI ERROR
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  // ── Label ──
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  // ── Button ──
  static const TextStyle buttonText = TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.w900,
    color: Colors.white,
  );

  // ── Link ──
  static const TextStyle linkText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.linkGreen,
  );

  // ── Hint ──
  static const TextStyle hintText = TextStyle(
    fontSize: 12,
    color: AppColors.textHint,
  );

  // ── Error ──
  static const TextStyle errorTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.error,
  );

  static const TextStyle errorBody = TextStyle(
    fontSize: 13,
    color: AppColors.textPrimary,
  );

  // ── Forgot Password ──
  static const TextStyle forgotPassword = TextStyle(
    fontSize: 12,
    color: AppColors.textPrimary,
  );

  // ── Divider ──
  static const TextStyle dividerText = TextStyle(
    fontSize: 15,
    fontStyle: FontStyle.italic,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );
}