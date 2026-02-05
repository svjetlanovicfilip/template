import 'package:flutter/material.dart';

import '../../config/style/colors.dart';
import '../../features/calendar/data/models/calendar_type_enum.dart';
import 'toggle_button.dart';

class ToggleButtonGroup extends StatefulWidget {
  const ToggleButtonGroup({
    required this.onSelectionChanged,
    required this.selectedCalendarType,
    super.key,
  });

  final void Function(CalendarType)? onSelectionChanged;
  final CalendarType selectedCalendarType;

  @override
  State<ToggleButtonGroup> createState() => _ToggleButtonGroupState();
}

class _ToggleButtonGroupState extends State<ToggleButtonGroup> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      constraints: const BoxConstraints(minHeight: 48),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.slate700,
      ),
      child: Row(
        spacing: 4,
        children: [
          Expanded(
            child: ToggleButton(
              title: 'Dan',
              isActive: widget.selectedCalendarType == CalendarType.day,
              onTap: () {
                if (widget.selectedCalendarType != CalendarType.day) {
                  widget.onSelectionChanged?.call(CalendarType.day);
                }
              },
            ),
          ),

          Expanded(
            child: ToggleButton(
              title: 'Sedmica',
              isActive: widget.selectedCalendarType == CalendarType.week,
              onTap: () {
                if (widget.selectedCalendarType != CalendarType.week) {
                  widget.onSelectionChanged?.call(CalendarType.week);
                }
              },
            ),
          ),

          Expanded(
            child: ToggleButton(
              title: 'Tefter',
              isActive: widget.selectedCalendarType == CalendarType.employees,
              onTap: () {
                if (widget.selectedCalendarType != CalendarType.employees) {
                  widget.onSelectionChanged?.call(CalendarType.employees);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
