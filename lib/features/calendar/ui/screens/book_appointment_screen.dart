import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../../login/data/models/user_model.dart';
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

  bool isTimeRangeValid = true;
  bool isTitleValid = true;

  late final String selectedColor;

  late List<UserModel> _employees;

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
    _employees = appState.organizationUsers;
    selectedUserId = appState.currentUser?.id;
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
              if (appState.currentUser?.role == 'ORG_OWNER')
                DropdownButtonFormField<UserModel>(
                  initialValue: _employees.firstWhere(
                    (employee) => employee.id == appState.currentUser?.id,
                  ),
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
                  icon: const Icon(
                    Icons.expand_more,
                    color: AppColors.slate800,
                  ),
                  items:
                      _employees
                          .map(
                            (employee) => DropdownMenuItem(
                              value: employee,
                              child: Text(
                                '${employee.name} ${employee.surname}',
                              ),
                            ),
                          )
                          .toList(),
                  onChanged:
                      (value) => setState(() => selectedUserId = value?.id),
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
                    setState(() {
                      selectedDate = picked;
                      if (selectedStart != null) {
                        selectedStart = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedStart!.hour,
                          selectedStart!.minute,
                        );
                      }
                      if (selectedEnd != null) {
                        selectedEnd = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedEnd!.hour,
                          selectedEnd!.minute,
                        );
                      }
                    });
                    _validateTimeRange();
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

                            selectedStart = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              picked.hour,
                              picked.minute,
                            );

                            _validateTimeRange();
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.slate200,
                              border:
                                  isTimeRangeValid
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

                            setState(() {
                              selectedEnd = DateTime(
                                selectedDate.year,
                                selectedDate.month,
                                selectedDate.day,
                                picked.hour,
                                picked.minute,
                              );
                            });

                            _validateTimeRange();
                          },

                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: AppColors.slate200,
                              border:
                                  isTimeRangeValid
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
              if (!isTimeRangeValid)
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
                onChanged:
                    (value) => setState(() => isTitleValid = value.isNotEmpty),
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
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.red600),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.red600),
                  ),
                  errorText:
                      isTitleValid ? null : 'Molimo unesite detalje usluge',
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

  Future<void> handleSubmit() async {
    _validateTimeRange();

    final title = titleController.text.trim();

    if (title.isEmpty) {
      setState(() {
        isTitleValid = false;
      });
    }

    if (!isTimeRangeValid || !isTitleValid) {
      return;
    }

    final slot = Slot(
      title: title,
      startDateTime: selectedStart!,
      endDateTime: selectedEnd!,
      color: widget.args.slot?.color ?? selectedColor,
      id: widget.args.slot?.id,
    );

    if (isEditing) {
      getIt<SlotBloc>().add(UpdateSlot(slot, selectedUserId ?? ''));
    } else {
      getIt<SlotBloc>().add(AddNewSlot(slot, selectedUserId ?? ''));
    }

    Navigator.of(context).pop();
  }

  void _validateTimeRange() {
    if (selectedStart == null || selectedEnd == null) {
      setState(() {
        isTimeRangeValid = false;
      });
      return;
    } else if (selectedStart != null && selectedStart!.isBefore(selectedDate)) {
      setState(() {
        isTimeRangeValid = false;
      });
    } else if (selectedEnd != null &&
        selectedStart != null &&
        selectedStart!.isAfter(selectedEnd!)) {
      setState(() {
        isTimeRangeValid = false;
      });
    } else if (selectedEnd != null &&
        selectedStart != null &&
        selectedEnd!.isBefore(selectedStart!)) {
      setState(() {
        isTimeRangeValid = false;
      });
    } else {
      setState(() {
        isTimeRangeValid = true;
      });
    }
  }
}
