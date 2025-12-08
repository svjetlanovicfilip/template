import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.onTap,
    this.title,
    this.icon,
    this.borderRadius,
    this.isLoading = false,
    super.key,
  });

  final String? title;
  final VoidCallback onTap;
  final IconData? icon;
  final BorderRadius? borderRadius;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.amber500,
          borderRadius: borderRadius,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          spacing: 8,
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, color: Colors.white),
            if (isLoading)
              const SizedBox(
                height: 25,
                width: 25,
                child: CircularProgressIndicator(color: Colors.white),
              )
            else if (title != null)
              Text(
                title!,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
          ],
        ),
      ),
    );
  }
}
