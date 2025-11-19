import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

Future<void> showBookAppointmentModal(BuildContext ctx) async {
  final descriptionController = TextEditingController();

  TimeOfDay? selectedStart;
  TimeOfDay? selectedEnd;

  String formatDateLong(DateTime d) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  String formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  Future<TimeOfDay?> pickTime(TimeOfDay initialTime) {
    return showTimePicker(
      context: ctx,
      initialTime: initialTime,
      helpText: 'Select time',
    );
  }

  await showDialog<void>(
    context: ctx,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          final theme = Theme.of(context);

          Future<void> handleSubmit() async {
            if (selectedStart == null || selectedEnd == null) {
              Navigator.of(dialogContext).pop();
              return;
            }
            final start = DateTime.now();
            final end = DateTime.now();

            if (!end.isAfter(start)) {
              Navigator.of(dialogContext).pop();
              return;
            }

            final event = CalendarEventData(
              date: start,
              startTime: start,
              endTime: end,
              endDate: end,
              title: 'Appointment',
              event:
                  descriptionController.text.trim().isEmpty
                      ? 'Appointment'
                      : descriptionController.text.trim(),
            );

            CalendarControllerProvider.of(ctx).controller.add(event);
            Navigator.of(dialogContext).pop();
          }

          final initialForPicker = TimeOfDay.now();

          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 44),
                        Text(
                          'Dodaj termin',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(dialogContext).pop(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        formatDateLong(DateTime.now()),
                        style: theme.textTheme.labelMedium,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Početak',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final picked = await pickTime(
                                    selectedStart ?? initialForPicker,
                                  );
                                  if (picked != null) {
                                    setState(() => selectedStart = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.slate100,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedStart == null
                                            ? ''
                                            : formatTimeOfDay(selectedStart!),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.expand_more,
                                        color: AppColors.slate800,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Kraj',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              InkWell(
                                borderRadius: BorderRadius.circular(8),
                                onTap: () async {
                                  final base = selectedEnd ?? initialForPicker;
                                  final picked = await pickTime(base);
                                  if (picked != null) {
                                    setState(() => selectedEnd = picked);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: AppColors.slate100,
                                  ),
                                  child: Row(
                                    children: [
                                      Text(
                                        selectedEnd == null
                                            ? ''
                                            : formatTimeOfDay(selectedEnd!),
                                        style: Theme.of(
                                          context,
                                        ).textTheme.labelMedium?.copyWith(
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                      const Icon(
                                        Icons.expand_more,
                                        color: AppColors.slate800,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text('Detalji usluge', style: theme.textTheme.labelMedium),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descriptionController,

                      maxLines: 3,
                      decoration: InputDecoration(
                        hintText:
                            'E.g., Haircut and styling, Gel manicure, Makeup for event...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: AppColors.slate100,
                        hintStyle: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.slate400,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: handleSubmit,
                        child: const Text(
                          'Potvrdi',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    },
  );
}
