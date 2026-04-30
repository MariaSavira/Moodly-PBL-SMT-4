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
        if (label.isNotEmpty) ...[
          Text(label, style: AppTextStyles.label),
          const SizedBox(height: 8),
        ],
        SizedBox(
          height: 43,
          child: TextFormField(
            controller: controller,
            obscureText: obscureText,
            keyboardType: keyboardType,
            validator: validator,
            onChanged: onChanged,
            style: AppTextStyles.bodyMedium.copyWith(
              color: hasError ? AppColors.error : AppColors.textPrimary,
              fontSize: 12,
            ),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTextStyles.hintText.copyWith(
                color: hasError ? AppColors.error : AppColors.textHint,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: IconTheme(
                  data: IconThemeData(
                    color: hasError ? AppColors.error : AppColors.textPrimary,
                    size: 19,
                  ),
                  child: prefixIcon,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(minWidth: 42),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.inputBorder,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(50),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              errorStyle: const TextStyle(height: 0, fontSize: 0),
            ),
          ),
        ),
      ],
    );
  }
}