import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/slot.dart';
import '../../domain/bloc/slot_bloc.dart';
import '../../domain/utils/utils.dart';

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({super.key});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  final TextEditingController descriptionController = TextEditingController();

  TimeOfDay? selectedStart;
  TimeOfDay? selectedEnd;
  DateTime selectedDate = DateTime.now();
  DateTime initialDate = DateTime.now();
  String? selectedUserId;

  bool isStartTimeValid = true;
  bool isEndTimeValid = true;

  late final String selectedColor;

  final List<String> employees = [
    'Milan',
    'Filip',
    'Ana',
    'Sara',
    'Ivan',
    'Marko',
  ];

  @override
  void initState() {
    super.initState();
    final random = Random(42);
    final colors = List<Color>.from(AppColors.possibleEventColors)
      ..shuffle(random);
    final length = colors.length;
    final eventIndex = random.nextInt(length);
    selectedColor = colors[eventIndex % colors.length].toARGB32().toString();
  }

  String formatTimeOfDay(TimeOfDay t) {
    final hour = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $suffix';
  }

  Future<TimeOfDay?> pickTime(TimeOfDay initialTime) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Select time',
    );
  }

  Future<void> handleSubmit() async {
    if (selectedStart == null || selectedEnd == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Molimo izaberite početak i kraj termina'),
        ),
      );
      setState(() {
        isStartTimeValid = false;
        isEndTimeValid = false;
      });
      return;
    }
    final convertedStartTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedStart!.hour,
      selectedStart!.minute,
    );
    final convertedEndTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedEnd!.hour,
      selectedEnd!.minute,
    );

    if (!convertedEndTime.isAfter(convertedStartTime)) {
      Navigator.of(context).pop();
      return;
    }

    final title = descriptionController.text.trim();

    final slot = Slot(
      title: title,
      startDateTime: convertedStartTime,
      endDateTime: convertedEndTime,
      color: selectedColor,
    );

    getIt<SlotBloc>().add(AddNewSlot(slot));

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initialForPicker = TimeOfDay.now();

    return Scaffold(
      appBar: const CustomAppBar(title: Text('Dodaj termin')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Zaposleni',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: employees.first,
                isExpanded: true,
                borderRadius: BorderRadius.circular(12),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: AppColors.slate200,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                icon: const Icon(Icons.expand_more, color: AppColors.slate800),
                items:
                    employees
                        .map(
                          (employee) => DropdownMenuItem(
                            value: employee,
                            child: Text(employee),
                          ),
                        )
                        .toList(),
                onChanged: (value) => setState(() => selectedUserId = value),
              ),
              const SizedBox(height: 20),
              Text(
                'Datum',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: initialDate,
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                    currentDate: selectedDate,
                  );

                  if (picked != null) {
                    setState(() => selectedDate = picked);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: AppColors.slate200,
                  ),
                  child: Row(
                    spacing: 8,
                    children: [
                      const Icon(
                        Icons.calendar_month,
                        color: AppColors.slate800,
                      ),
                      Text(
                        formatDateLong(selectedDate),
                        style: theme.textTheme.labelMedium,
                      ),
                    ],
                  ),
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
                            if (picked != null &&
                                picked.isBefore(TimeOfDay.now())) {
                              setState(() {
                                isStartTimeValid = false;
                              });
                            } else if (picked != null &&
                                selectedEnd != null &&
                                picked.isAfter(
                                  selectedEnd ?? TimeOfDay.now(),
                                )) {
                              setState(() {
                                isStartTimeValid = false;
                              });
                            } else {
                              setState(() {
                                isStartTimeValid = true;
                              });
                            }
                            setState(() {
                              selectedStart = picked;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.slate200,
                              border:
                                  isStartTimeValid
                                      ? null
                                      : Border.all(color: AppColors.red600),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  selectedStart == null
                                      ? ''
                                      : formatTimeOfDay(selectedStart!),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w400),
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
                            if (picked != null &&
                                picked.isBefore(
                                  selectedStart ?? TimeOfDay.now(),
                                )) {
                              setState(() {
                                isEndTimeValid = false;
                              });
                            } else if (picked != null &&
                                picked.isBefore(TimeOfDay.now())) {
                              setState(() {
                                isEndTimeValid = false;
                              });
                            } else {
                              setState(() {
                                isEndTimeValid = true;
                              });
                            }
                            setState(() {
                              selectedEnd = picked;
                            });
                          },

                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.slate200,
                              border:
                                  isEndTimeValid
                                      ? null
                                      : Border.all(color: AppColors.red600),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  selectedEnd == null
                                      ? ''
                                      : formatTimeOfDay(selectedEnd!),
                                  style: Theme.of(context).textTheme.labelMedium
                                      ?.copyWith(fontWeight: FontWeight.w400),
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

              const SizedBox(height: 12),
              if (!isStartTimeValid || !isEndTimeValid)
                Text(
                  'Vrijeme nije pravilno uneseno. Molimo vas da provjerite početak i kraj termina.',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.red600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              const SizedBox(height: 12),
              Text('Detalji usluge', style: theme.textTheme.labelMedium),
              const SizedBox(height: 8),
              TextField(
                controller: descriptionController,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Unesite detalje usluge...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  fillColor: AppColors.slate200,
                  hintStyle: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.slate500,
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
  }
}
