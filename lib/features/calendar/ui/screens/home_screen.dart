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
import '../../domain/bloc/slot_bloc.dart';
import '../widgets/calendar_day_view.dart';
import '../widgets/calendar_week_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  CalendarTypeViewCubit get _calendarTypeViewCubit =>
      getIt<CalendarTypeViewCubit>();

  SlotBloc get _slotBloc => getIt<SlotBloc>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: const Row(spacing: 8, children: [LogoWidget(), Text('Tefter')]),
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
              child: const Icon(Icons.person, size: 24, color: AppColors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.slate900,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: PrimaryButton(
        icon: Icons.add,
        onTap: () {
          context.pushNamed(Routes.bookAppointment);
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
                          ? BlocListener<SlotBloc, SlotState>(
                            bloc: _slotBloc,
                            listener: (context, state) {
                              CalendarControllerProvider.of(
                                context,
                              ).controller.addAll(
                                state.slots
                                    .map((slot) => slot.toCalendarEventData())
                                    .toList(),
                              );
                            },
                            child:
                                state == CalendarType.day
                                    ? const CalendarDayView()
                                    : const CalendarWeekView(),
                          )
                          : const CalendarWeekView(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
