import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';

class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key});

  @override
  Widget build(BuildContext context) {
    return DayView(
      startHour: 6,
      showHalfHours: true,
      heightPerMinute: 2,
      timeLineWidth: 80,
      verticalLineOffset: 0,
      halfHourIndicatorSettings: const HourIndicatorSettings(
        color: AppColors.slate200,
        height: 3,
        lineStyle: LineStyle.dashed,
      ),
      backgroundColor: AppColors.slate50,
      headerStyle: HeaderStyle(
        decoration: const BoxDecoration(color: AppColors.white),
        headerPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        headerTextStyle: Theme.of(context).textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.slate800,
        ),
      ),
      showVerticalLine: false,
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

      eventTileBuilder: (date, events, boundary, startDuration, endDuration) {
        String fmt(int v) => v.toString().padLeft(2, '0');
        final startStr =
            '${fmt(startDuration.hour)}:${fmt(startDuration.minute)}';
        final endStr = '${fmt(endDuration.hour)}:${fmt(endDuration.minute)}';

        final title = events.first.event.toString();
        return Container(
          decoration: BoxDecoration(
            color: AppColors.amber500,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 2).copyWith(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$startStr - $endStr',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },

      onEventDoubleTap: (events, date) {
        print('onEventDoubleTap: $events, $date');
      },

      onEventTap: (events, date) {
        print('onEventTap: $events, $date');
      },

      onEventLongTap: (events, date) {
        print('onEventLongTap: $events, $date');
      },

      onHeaderTitleTap: (date) async {
        print('onHeaderTitleTap: $date');
      },

      onTimestampTap: (date) {
        print('onTimestampTap: $date');
      },
    );
  }
}
