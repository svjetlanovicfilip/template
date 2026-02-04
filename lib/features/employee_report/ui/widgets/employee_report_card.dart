import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class EmployeeReportCard extends StatelessWidget {
  const EmployeeReportCard({
    required this.title,
    required this.value,
    required this.icon,
    super.key,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.amber50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.amber500, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            letterSpacing: 1,
            fontSize: 16,
            color: AppColors.slate500,
            fontWeight: FontWeight.w400,
          ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: AppColors.amber500,
          ),
        ),
      ),
    );
  }
}
