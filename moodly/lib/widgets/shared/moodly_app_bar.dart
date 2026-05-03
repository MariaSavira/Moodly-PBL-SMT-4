import 'package:flutter/material.dart';
import '../../core/moodly_colors.dart';

PreferredSizeWidget moodlyAppBar(
  BuildContext context,
  String title,
) {
  return AppBar(
    backgroundColor: MoodlyColors.bgLight,
    elevation: 0,
    leading: IconButton(
      icon: const Icon(Icons.arrow_back_ios, size: 18, color: MoodlyColors.green),
      onPressed: () => Navigator.pop(context),
    ),
    title: Text(
      title,
      style: const TextStyle(
        color: MoodlyColors.green,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}