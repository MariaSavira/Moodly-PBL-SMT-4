import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../core/app_text_styles.dart';

class MoodlyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final Widget prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final bool hasError;
  final void Function(String)? onChanged;

  const MoodlyTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.hasError = false,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          style: AppTextStyles.bodyMedium.copyWith(
            color: hasError ? AppColors.error : AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: AppTextStyles.hintText,
            prefixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: IconTheme(
                data: IconThemeData(
                  color: hasError ? AppColors.error : AppColors.textHint,
                  size: 20,
                ),
                child: prefixIcon,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: suffixIcon,
                  )
                : null,
            filled: true,
            fillColor: hasError ? AppColors.inputErrorFill : AppColors.inputFill,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.inputBorder,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary,
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(50),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
            errorStyle: const TextStyle(height: 0), // hide inline error; use banner
          ),
        ),
      ],
    );
  }
}