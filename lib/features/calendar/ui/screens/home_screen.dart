import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/cubits/calendar_type_view/calendar_type_view_cubit.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/logo_widget.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/toggle_button_group.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/calendar_type_enum.dart';
import '../../data/models/slot.dart';
import '../../domain/bloc/slot_bloc.dart';
import '../widgets/calendar_day_view.dart';
import '../widgets/calendar_week_view.dart';
import 'book_appointment_screen.dart';

class HomeScreenArguments {
  const HomeScreenArguments({required this.slots});

  final List<Slot> slots;
}

class ExtractHomeScreenArguments extends StatelessWidget {
  const ExtractHomeScreenArguments({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as HomeScreenArguments;

    return HomeScreen(args: args);
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({required this.args, super.key});

  final HomeScreenArguments args;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  CalendarTypeViewCubit get _calendarTypeViewCubit =>
      getIt<CalendarTypeViewCubit>();

  SlotBloc get _slotBloc => getIt<SlotBloc>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newSlots =
        widget.args.slots.map((slot) => slot.toCalendarEventData()).toList();
    CalendarControllerProvider.of(context).controller.addAll(newSlots);
    print(
      'Length of events: ${CalendarControllerProvider.of(context).controller.allEvents.length}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SlotBloc, SlotState>(
      bloc: _slotBloc,

      listener: (context, state) {
        if (state is ErrorLoadingSlots) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage)));
          return;
        } else if (state is NewSlotAdded) {
          final newSlot = state.slot.toCalendarEventData();
          CalendarControllerProvider.of(context).controller.add(newSlot);
          print(
            'Length of events: ${CalendarControllerProvider.of(context).controller.allEvents.length}',
          );
        } else if (state is SlotUpdated) {
          print(
            'Length of events: ${CalendarControllerProvider.of(context).controller.allEvents.length}',
          );
          final updatedSlot = state.slot.toCalendarEventData();
          CalendarControllerProvider.of(context).controller.removeWhere(
            (event) => (event.event as Slot).id == state.slot.id,
          );
          CalendarControllerProvider.of(context).controller.add(updatedSlot);
          print(
            'Length of events: ${CalendarControllerProvider.of(context).controller.allEvents.length}',
          );
        }
      },
      builder: (context, state) {
        if (state is SlotStateLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.amber500),
            ),
            backgroundColor: AppColors.white,
          );
        }

        return Scaffold(
          appBar: CustomAppBar(
            title: const Row(
              spacing: 8,
              children: [LogoWidget(), Text('Tefter')],
            ),
            actions: [
              GestureDetector(
                onTap: () => context.pushNamed(Routes.settings),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.slate700,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    size: 24,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.slate900,
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
          floatingActionButton: PrimaryButton(
            icon: Icons.add,
            onTap: () {
              context.pushNamed(
                Routes.bookAppointment,
                arguments: const BookAppointmentScreenArguments(),
              );
            },
            borderRadius: BorderRadius.circular(30),
          ),
          body: SafeArea(
            child: CustomScrollView(
              physics: const NeverScrollableScrollPhysics(),
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: BlocBuilder<CalendarTypeViewCubit, CalendarType>(
                      bloc: _calendarTypeViewCubit,
                      builder: (context, state) {
                        return ToggleButtonGroup(
                          onSelectionChanged: (value) {
                            _calendarTypeViewCubit.toggleCalendarType(value);
                          },
                          selectedCalendarType: state,
                        );
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
                BlocBuilder<CalendarTypeViewCubit, CalendarType>(
                  bloc: _calendarTypeViewCubit,
                  builder: (context, state) {
                    return SliverFillRemaining(
                      child:
                          state == CalendarType.day
                              ? const CalendarDayView()
                              : const CalendarWeekView(),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
