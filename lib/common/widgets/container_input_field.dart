import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../config/style/colors.dart';

class ContainerInputField extends StatelessWidget {
  const ContainerInputField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.inputFormatters,
    required this.maxLines,
    required this.onChanged,
    this.errorText,
    super.key,
  });

  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final String? errorText;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.done,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate400, width: 2),
        ),
        hintText: hintText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        fillColor: AppColors.slate200,
        hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.slate500,
          fontWeight: FontWeight.w400,
        ),
        errorText: errorText,
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red600),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.red600),
        ),
      ),
      onChanged: onChanged,
    );
  }
}
