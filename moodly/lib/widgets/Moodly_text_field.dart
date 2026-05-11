import 'package:flutter/material.dart';
import '../core/styles/styles.dart';

class MoodlyTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String label;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final bool hasError;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextStyle? labelStyle;

  const MoodlyTextField({
    super.key,
    this.controller,
    required this.label,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.hasError = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: labelStyle ?? AppTextStyles.label,
          ),
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
              prefixIcon: prefixIcon == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 13),
                      child: IconTheme(
                        data: IconThemeData(
                          color: hasError
                              ? AppColors.error
                              : AppColors.textPrimary,
                          size: 19,
                        ),
                        child: prefixIcon!,
                      ),
                    ),
              prefixIconConstraints: const BoxConstraints(minWidth: 42),
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 11),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.inputBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: hasError ? AppColors.error : AppColors.inputBorder,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
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