import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../domain/bloc/slot_bloc.dart';

class CalendarDayView extends StatelessWidget {
  const CalendarDayView({super.key});

  SlotBloc get _slotBloc => getIt<SlotBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SlotBloc, SlotState>(
      bloc: _slotBloc,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          return;
        } else {
          final newSlots =
              state.slots.map((slot) => slot.toCalendarEventData()).toList();
          CalendarControllerProvider.of(context).controller.addAll(newSlots);
        }
      },
      child: DayView(
        controller: CalendarControllerProvider.of(context).controller,
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
          headerPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
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

          final title = events.first.title;
          final timeRange = '$startStr - $endStr';
          final color = events.first.color;

          const titleStyle = TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          );
          const timeStyle = TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          );

          // Layout constants used both for rendering and measurement
          const double horizontalPadding = 16;
          const double topPadding = 16;
          const double bottomPadding = 12;
          const double verticalSpacing = 4;

          // Available sizes inside the tile (content box)
          final contentHeight = boundary.height - topPadding - bottomPadding;

          // Title: always render, single line, overflow fades
          final titleHeight = _textSize(title, titleStyle).height;
          final timeHeight = _textSize(timeRange, timeStyle).height;

          // Check vertical fit for time: it must fit under title (with spacing)
          final canFitHeightForTime =
              contentHeight >= titleHeight + verticalSpacing + timeHeight;

          return Container(
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.symmetric(vertical: 2).copyWith(right: 6),
            padding: const EdgeInsets.symmetric(
              horizontal: horizontalPadding,
            ).copyWith(top: topPadding, bottom: bottomPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                ),
                if (canFitHeightForTime) ...[
                  const SizedBox(height: verticalSpacing),
                  Text(timeRange, maxLines: 1, style: timeStyle),
                ],
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

        onPageChange: (date, page) {
          _slotBloc.add(LoadMoreForward(currentDisplayedDate: date));
        },

        onEventLongTap: (events, date) {
          print('onEventLongTap: $events, $date');
        },

        onDateTap: (date) {
          print('onDateTap: $date');
        },

        onHeaderTitleTap: (date) async {
          print('onHeaderTitleTap: $date');
        },

        onTimestampTap: (date) {
          print('onTimestampTap: $date');
        },
      ),
    );
  }

  Size _textSize(String text, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 2,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.size;
  }
}
