import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../config/style/colors.dart';

class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return WeekView(
      startHour: 6,
      timeLineWidth: 80,
      backgroundColor: AppColors.slate50,
      weekDayBuilder:
          (weekDay) => Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Text(
                DateFormat('E').format(weekDay),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.slate800,
                  fontSize: 12,
                ),
              ),
              Text(
                weekDay.day.toString(),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppColors.slate800,
                  fontSize: 12,
                ),
              ),
            ],
          ),
      headerStyle: HeaderStyle(
        decoration: const BoxDecoration(color: AppColors.white),
        headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        headerTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.slate800,
        ),
      ),
      hourIndicatorSettings: const HourIndicatorSettings(
        color: AppColors.slate200,
        height: 3,
      ),
      liveTimeIndicatorSettings: const LiveTimeIndicatorSettings(height: 3),
      timeLineBuilder: (date) {
        return Transform.translate(
          offset: const Offset(0, -7.5),
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Text(
              '${date.hour < 10 ? '0${date.hour}' : date.hour}:${date.minute == 0 ? '00' : date.minute}',
              style: const TextStyle(color: AppColors.slate500),
            ),
          ),
        );
      },
    );
  }
}
