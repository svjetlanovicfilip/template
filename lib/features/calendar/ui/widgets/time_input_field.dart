import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class TimeInputField extends StatelessWidget {
  const TimeInputField({
    required this.isTimeRangeValid,
    required this.label,
    required this.selectedDateTime,
    required this.onTimeSelected,
    this.disabled = false,
    super.key,
  });

  final bool isTimeRangeValid;
  final String label;
  final DateTime? selectedDateTime;
  final VoidCallback onTimeSelected;
  final bool disabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: disabled ? null : onTimeSelected,
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.slate200,
              border:
                  isTimeRangeValid ? null : Border.all(color: AppColors.red600),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDateTime != null
                      ? _formatTimeOfDay(selectedDateTime!)
                      : '',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Icon(Icons.expand_more, color: AppColors.slate800),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatTimeOfDay(DateTime t) {
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
