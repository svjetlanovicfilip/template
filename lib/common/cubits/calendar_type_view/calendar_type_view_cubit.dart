import 'package:bloc/bloc.dart';

import '../../../features/calendar/data/models/calendar_type_enum.dart';

class CalendarTypeViewCubit extends Cubit<CalendarType> {
  CalendarTypeViewCubit() : super(CalendarType.day);

  void toggleCalendarType(CalendarType calendarType) {
    emit(calendarType);
  }

  void clear() {
    emit(CalendarType.day);
  }
}
