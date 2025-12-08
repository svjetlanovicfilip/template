import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';
import '../../domain/utils/utils.dart';

class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({super.key});

  @override
  Widget build(BuildContext context) {
    return WeekView(
      startHour: 6,
      timeLineWidth: 80,
      backgroundColor: AppColors.slate50,
      headerStringBuilder:
          (date, {secondaryDate}) =>
              '${date.day}.${date.month}.${date.year} - ${secondaryDate?.day}.${secondaryDate?.month}.${secondaryDate?.year}',
      weekDayBuilder: (weekDay) {
        final weekday = formatWeekday(weekDay.weekday - 1);

        return Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Text(
              weekday.substring(0, 3),
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
        );
      },
      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        final title = events.first.title;
        final color = events.first.color;
        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2),
          padding: const EdgeInsets.symmetric(
            horizontal: 2,
          ).copyWith(top: 2, bottom: 2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ],
          ),
        );
      },
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
      onPageChange: (date, page) {
        print('onPageChange: $date, $page');
      },
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
