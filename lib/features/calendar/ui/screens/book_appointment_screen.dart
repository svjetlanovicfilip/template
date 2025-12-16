import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/slot.dart';
import '../../domain/bloc/slot_bloc.dart';
import '../../domain/utils/utils.dart';

class BookAppointmentScreenArguments {
  const BookAppointmentScreenArguments({this.slot});

  final Slot? slot;
}

class ExtractBookAppointmentArgumentsScreen extends StatelessWidget {
  const ExtractBookAppointmentArgumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments
            as BookAppointmentScreenArguments;

    return BookAppointmentScreen(args: args);
  }
}

class BookAppointmentScreen extends StatefulWidget {
  const BookAppointmentScreen({required this.args, super.key});

  final BookAppointmentScreenArguments args;

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  late TextEditingController titleController;

  late DateTime selectedDate;
  DateTime? selectedStart;
  DateTime? selectedEnd;
  DateTime initialDate = DateTime.now();
  String? selectedUserId;
  bool isEditing = false;

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
    isEditing = widget.args.slot?.title.isNotEmpty ?? false;
    final random = Random();
    final colors = List<Color>.from(AppColors.possibleEventColors)
      ..shuffle(random);
    final length = colors.length;
    final eventIndex = random.nextInt(length);
    selectedColor = colors[eventIndex % colors.length].toARGB32().toString();
    selectedStart = widget.args.slot?.startDateTime;
    selectedEnd = widget.args.slot?.endDateTime;
    selectedDate = widget.args.slot?.startDateTime ?? DateTime.now();
    titleController = TextEditingController(text: widget.args.slot?.title);
  }

  String formatTimeOfDay(DateTime t) {
    final hour = t.hour;
    final minute = t.minute.toString().padLeft(2, '0');
    final suffix = hour > 12 ? 'PM' : 'AM';
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
    if (selectedEnd == null) {
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

    final title = titleController.text.trim();

    final slot = Slot(
      title: title,
      startDateTime: convertedStartTime,
      endDateTime: convertedEndTime,
      color: widget.args.slot?.color ?? selectedColor,
      id: widget.args.slot?.id,
    );

    if (isEditing) {
      getIt<SlotBloc>().add(UpdateSlot(slot));
    } else {
      getIt<SlotBloc>().add(AddNewSlot(slot));
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
                // initialValue: employees.first,
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
                            final timeOfDay = TimeOfDay.fromDateTime(
                              selectedStart ?? DateTime.now(),
                            );
                            final picked = await pickTime(timeOfDay);

                            if (picked == null) return;

                            final selectedStartDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute,
                            );

                            if (selectedStartDateTime.isBefore(selectedDate)) {
                              setState(() {
                                isStartTimeValid = false;
                              });
                            } else if (selectedEnd != null &&
                                selectedStartDateTime.isAfter(
                                  selectedEnd ?? selectedDate,
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
                              selectedStart = selectedStartDateTime;
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
                                  selectedStart != null
                                      ? formatTimeOfDay(selectedStart!)
                                      : '',
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
                            final picked = await pickTime(TimeOfDay.now());

                            if (picked == null) return;

                            final selectedStartDateTime = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute,
                            );
                            if (selectedStartDateTime.isBefore(
                              selectedStart ?? DateTime.now(),
                            )) {
                              setState(() {
                                isEndTimeValid = false;
                              });
                            } else if (selectedStartDateTime.isBefore(
                              selectedDate,
                            )) {
                              setState(() {
                                isEndTimeValid = false;
                              });
                            } else {
                              setState(() {
                                isEndTimeValid = true;
                              });
                            }
                            setState(() {
                              selectedEnd = selectedStartDateTime;
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
                controller: titleController,
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
