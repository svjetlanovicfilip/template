import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class ClientVisitInfo extends StatelessWidget {
  const ClientVisitInfo({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Icon(icon, color: AppColors.amber500, size: 18),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.amber500,
            ),
          ),
        ),
      ],
    );
  }
}
