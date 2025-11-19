import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/cubits/calendar_type_view/calendar_type_view_cubit.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/main_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/calendar_type_enum.dart';
import '../modals/book_appointment_modal.dart';
import '../widgets/calendar_day_view.dart';
import '../widgets/calendar_week_view.dart';

class CalendarManagementScreen extends StatelessWidget {
  const CalendarManagementScreen({super.key});

  CalendarTypeViewCubit get _calendarTypeViewCubit =>
      getIt<CalendarTypeViewCubit>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: PrimaryButton(
        icon: Icons.add,
        title: 'Dodaj termin',
        onTap: () {
          showBookAppointmentModal(context);
        },
        borderRadius: BorderRadius.circular(30),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.slate900, AppColors.slate800],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            physics: const NeverScrollableScrollPhysics(),
            slivers: [
              const SliverToBoxAdapter(child: MainAppBar()),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
      ),
    );
  }
}
