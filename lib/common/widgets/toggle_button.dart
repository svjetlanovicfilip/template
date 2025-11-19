import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class ToggleButton extends StatelessWidget {
  const ToggleButton({
    required this.title,
    required this.isActive,
    required this.onTap,
    super.key,
  });

  final String title;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style:
          isActive
              ? TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: AppColors.amber500,
                textStyle: Theme.of(context).textTheme.bodyMedium,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              )
              : TextButton.styleFrom(
                foregroundColor: AppColors.white,
                backgroundColor: AppColors.slate700,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: Theme.of(context).textTheme.bodyMedium,
              ),
      child: Text(title, textAlign: TextAlign.center),
    );
  }
}
