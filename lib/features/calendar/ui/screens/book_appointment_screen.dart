import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../../users/domain/bloc/users_bloc.dart';
import '../../data/models/slot.dart';
import '../../domain/bloc/slot_bloc.dart';
import '../../domain/utils/utils.dart';
import '../widgets/label.dart';
import '../widgets/service_input_field.dart';
import '../widgets/time_input_field.dart';
import '../widgets/user_picker.dart';

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
  bool isFormSubmitted = false;

  bool isTimeRangeValid = true;
  bool isTitleValid = true;

  late final String selectedColor;

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
    selectedUserId = appState.currentSelectedUserId;
    getIt<ServiceBloc>().add(
      AttachService(serviceIds: widget.args.slot?.serviceIds ?? []),
    );
  }

  Future<TimeOfDay?> pickTime(TimeOfDay initialTime) {
    return showTimePicker(
      context: context,
      initialTime: initialTime,
      helpText: 'Odaberite vrijeme',
      initialEntryMode: TimePickerEntryMode.inputOnly,
      hourLabelText: 'Sat',
      minuteLabelText: 'Minute',
      confirmText: 'Potvrdi',
      cancelText: 'Odustani',
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
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
              if (appState.currentUser?.role == 'ORG_OWNER' && !isEditing)
                BlocBuilder<UsersBloc, UsersState>(
                  bloc: getIt<UsersBloc>(),
                  builder: (context, state) {
                    if (state is UsersFetchingSuccess &&
                        state.users.isNotEmpty) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Label(title: 'Zaposleni'),
                          const SizedBox(height: 8),
                          UserPicker(
                            employees: state.users,
                            onChanged:
                                (userId) =>
                                    setState(() => selectedUserId = userId),
                          ),
                        ],
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              const SizedBox(height: 20),
              const Label(title: 'Datum'),
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _pickDate,
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
                spacing: 16,
                children: [
                  Expanded(
                    child: TimeInputField(
                      isTimeRangeValid: isTimeRangeValid,
                      label: 'Početak',
                      selectedDateTime: selectedStart,
                      onTimeSelected: _onStartTimeSelected,
                    ),
                  ),
                  Expanded(
                    child: TimeInputField(
                      isTimeRangeValid: isTimeRangeValid,
                      label: 'Kraj',
                      selectedDateTime: selectedEnd,
                      onTimeSelected: _onEndTimeSelected,
                    ),
                  ),
                ],
              ),

              if (!isTimeRangeValid) ...[
                const SizedBox(height: 12),
                Text(
                  'Vrijeme nije pravilno uneseno. Molimo vas da provjerite početak i kraj termina.',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.red600,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const Label(title: 'Usluga'),
              const SizedBox(height: 8),
              const ServiceInputField(),
              const SizedBox(height: 20),
              const Label(title: 'Detalji usluge'),
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
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.slate400,
                      width: 2,
                    ),
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
              PrimaryButton(
                onTap: handleSubmit,
                title: 'Potvrdi',
                borderRadius: BorderRadius.circular(12),
                padding: const EdgeInsets.all(10),
              ),
              const SizedBox(height: 12),
              if (isEditing)
                PrimaryButton(
                  onTap: handleDelete,
                  title: 'Izbriši termin',
                  borderRadius: BorderRadius.circular(12),
                  backgroundColor: AppColors.red600,
                  padding: const EdgeInsets.all(10),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: initialDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
      currentDate: selectedDate,
      confirmText: 'Potvrdi',
      cancelText: 'Odustani',
      initialDate: initialDate,
      helpText: 'Odaberi datum',
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
  }

  Future<void> _onStartTimeSelected() async {
    final timeOfDay = TimeOfDay.fromDateTime(selectedStart ?? DateTime.now());
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
  }

  Future<void> _onEndTimeSelected() async {
    final timeOfDay = TimeOfDay.fromDateTime(selectedEnd ?? DateTime.now());

    final picked = await pickTime(timeOfDay);

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
  }

  Future<void> handleSubmit() async {
    setState(() {
      isFormSubmitted = true;
    });

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

    final newSlot = Slot(
      id: widget.args.slot?.id,
      startDateTime: selectedStart ?? DateTime.now(),
      endDateTime: selectedEnd ?? DateTime.now(),
      title: title,
      color: widget.args.slot?.color ?? selectedColor,
      serviceIds:
          getIt<ServiceBloc>().state.selectedServices
              .map((e) => e.id ?? '')
              .toList(),
    );

    if (isEditing) {
      getIt<SlotBloc>().add(UpdateSlot(newSlot, selectedUserId ?? ''));
    } else {
      getIt<SlotBloc>().add(AddNewSlot(newSlot, selectedUserId ?? ''));
    }

    Navigator.of(context).pop();
  }

  void handleDelete() {
    getIt<SlotBloc>().add(
      DeleteSlot(widget.args.slot?.id ?? '', selectedUserId ?? ''),
    );
    Navigator.of(context).pop();
  }

  void _validateTimeRange() {
    if (!isFormSubmitted) return;

    if (selectedStart == null || selectedEnd == null) {
      setState(() {
        isTimeRangeValid = false;
      });
      return;
    } else if (selectedStart != null &&
        selectedStart!.isBefore(DateTime.now())) {
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
        selectedEnd!.isBefore(DateTime.now())) {
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
