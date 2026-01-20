import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class SearchField extends StatelessWidget {
  const SearchField({required this.onChanged, required this.hint, this.controller, super.key});

  final TextEditingController? controller;
  final Function(String) onChanged;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.done,
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.slate400, width: 2),
        ),
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        fillColor: AppColors.slate200,
        hintStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: AppColors.slate500,
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: const Icon(Icons.search),
      ),
    );
  }
}
