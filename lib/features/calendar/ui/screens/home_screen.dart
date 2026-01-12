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
import '../modals/employee_dropdown_menu.dart';
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
        ModalRoute.of(context)!.settings.arguments is HomeScreenArguments
            ? ModalRoute.of(context)!.settings.arguments as HomeScreenArguments
            : const HomeScreenArguments(slots: []);

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

  final SlotBloc _slotBloc = getIt<SlotBloc>();
  final _dayViewKey = GlobalKey<DayViewState>();
  final _weekViewKey = GlobalKey<WeekViewState>();
  final _filterIconKey = GlobalKey();
  bool _initializedFromArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedFromArgs) return;

    final newSlots =
        widget.args.slots.map((slot) => slot.toCalendarEventData()).toList();

    // Defer controller updates until after the first frame to avoid
    // setState/markNeedsBuild during build of ancestor widgets.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      CalendarControllerProvider.of(context).controller.addAll(newSlots);
    });

    _initializedFromArgs = true;
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
        } else if (state is LoadedRangeSlots) {
          final newSlots =
              state.slots.map((slot) => slot.toCalendarEventData()).toList();

          final controller = CalendarControllerProvider.of(context).controller;

          // snapshot prevents ConcurrentModificationError
          final oldSlots = List.of(controller.allEvents);

          controller
            ..removeAll(oldSlots)
            ..addAll(newSlots);
        } else if (state is LoadedSlotsAfterUserChanged) {
          final newSlots =
              state.slots.map((slot) => slot.toCalendarEventData()).toList();

          final controller = CalendarControllerProvider.of(context).controller;

          // snapshot prevents ConcurrentModificationError
          final oldSlots = List.of(controller.allEvents);

          controller
            ..removeAll(oldSlots)
            ..addAll(newSlots);
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
            automaticallyImplyLeading: false,
            title: Row(
              spacing: 8,
              children: [
                const LogoWidget(),
                Text(appState.userOrganization?.title ?? 'Tefter'),
              ],
            ),
            actions: [
              GestureDetector(
                onTap:
                    () => showEmployeeFilterMenu(
                      context,
                      _filterIconKey,
                      (userId) => getIt<SlotBloc>().add(
                        UserChanged(
                          userId: userId,
                          currentDisplayedDate:
                              _dayViewKey.currentState?.currentDate ??
                              _weekViewKey.currentState?.currentDate ??
                              DateTime.now(),
                        ),
                      ),
                    ),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: const BoxDecoration(
                    color: AppColors.slate700,
                    shape: BoxShape.circle,
                  ),
                  key: _filterIconKey,
                  child: const Icon(
                    Icons.filter_list,
                    size: 24,
                    color: AppColors.white,
                  ),
                ),
              ),
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
                              ? CalendarDayView(dayViewKey: _dayViewKey)
                              : CalendarWeekView(weekViewKey: _weekViewKey),
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
