import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/slot.dart';
import '../../domain/bloc/slot_bloc.dart';
import '../../domain/utils/utils.dart';
import '../screens/book_appointment_screen.dart';

class CalendarWeekView extends StatelessWidget {
  const CalendarWeekView({required this.weekViewKey, super.key});

  final GlobalKey<WeekViewState> weekViewKey;

  SlotBloc get _slotBloc => getIt<SlotBloc>();

  @override
  Widget build(BuildContext context) {
    return WeekView(
      initialDay: weekViewKey.currentState?.currentDate ?? DateTime.now(),
      key: weekViewKey,
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
        var isEventLessThan30Minutes = false;
        var lines = 1;
        const double padding = 2;
        final title = events.first.title;
        final color = events.first.color;
        const titleStyle = TextStyle(color: AppColors.white, fontSize: 12);

        final duration = endDuration.difference(startDuration);

        if (duration.inMinutes >= 30) {
          final contentHeight = boundary.height - (padding * 2);
          final titleHeight = textSize(title, titleStyle, maxLines: 3).height;

          if (contentHeight >= titleHeight * 3) {
            lines = 3;
          } else if (contentHeight >= titleHeight * 2) {
            lines = 2;
          } else {
            lines = 1;
          }
        } else {
          isEventLessThan30Minutes = true;
        }

        return Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          margin: const EdgeInsets.symmetric(vertical: padding),
          padding: const EdgeInsets.all(padding),
          child:
              isEventLessThan30Minutes
                  ? const SizedBox.shrink()
                  : Text(
                    title,
                    style: titleStyle,
                    maxLines: lines,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
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
        if (date.isAfter(DateTime.now())) {
          _slotBloc.add(
            LoadMoreForward(
              currentDisplayedDate: date.add(const Duration(days: 6)),
            ),
          );
        } else {
          _slotBloc.add(
            LoadMoreBackward(
              currentDisplayedDate: date.subtract(const Duration(days: 6)),
            ),
          );
        }
      },
      onEventTap: (events, date) {
        final event = events.first;
        final eventSlot = event.event as Slot;

        context.pushNamed(
          Routes.bookAppointment,
          arguments: BookAppointmentScreenArguments(slot: eventSlot),
        );
      },
      onDateTap: (date) {
        if (date.isBefore(DateTime.now())) {
          return;
        }

        context.pushNamed(
          Routes.bookAppointment,
          arguments: BookAppointmentScreenArguments(
            slot: Slot(title: '', startDateTime: date),
          ),
        );
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
      onHeaderTitleTap: (date) async {
        final picked = await showDatePicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
          currentDate: date,
          confirmText: 'Potvrdi',
          cancelText: 'Odustani',
          initialDate: date,
          helpText: 'Odaberi datum',
        );
        if (picked == null) return;
        await weekViewKey.currentState?.animateToWeek(
          picked,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
    );
  }
}
