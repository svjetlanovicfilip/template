import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../config/style/colors.dart';
import '../../features/calendar/data/models/calendar_type_enum.dart';
import '../constants/routes.dart';
import '../cubits/calendar_type_view/calendar_type_view_cubit.dart';
import '../di/di_container.dart';
import '../extensions/context_extension.dart';
import 'toggle_button_group.dart';
import 'user_avatar.dart';

class MainAppBar extends StatelessWidget {
  const MainAppBar({super.key});

  CalendarTypeViewCubit get _calendarTypeViewCubit =>
      getIt<CalendarTypeViewCubit>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.amber500,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.calendar_month,
                  size: 28,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text('Tefter', style: Theme.of(context).textTheme.headlineSmall),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.slate700,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.person),
                  color: AppColors.white,
                  onPressed: () {
                    context.pushNamed(Routes.settings);
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          BlocBuilder<CalendarTypeViewCubit, CalendarType>(
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
          const SizedBox(height: 16),
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 16,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                UserAvatar(name: 'Filip Svjetlanovic', initials: 'FS'),
                UserAvatar(name: 'Vladimir Lazarevic', initials: 'VL'),
                UserAvatar(name: 'Milan Tukic', initials: 'MT'),
                UserAvatar(name: 'Milan Tukic', initials: 'MT'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
