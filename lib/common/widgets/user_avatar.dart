import 'package:flutter/material.dart';

import '../../config/style/colors.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({required this.name, required this.initials, super.key});

  final String name;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 8,
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.slate600, width: 2),
            color: AppColors.slate700,
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(8),
          child: Text(
            initials,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
        ),
        Text(
          name,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.slate400),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
