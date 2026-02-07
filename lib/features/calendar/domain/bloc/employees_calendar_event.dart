part of 'employees_calendar_bloc.dart';

sealed class EmployeesCalendarEvent extends Equatable {
  const EmployeesCalendarEvent();
  @override
  List<Object?> get props => [];
}

class EmployeesCalendarDateSet extends EmployeesCalendarEvent {
  const EmployeesCalendarDateSet({required this.date});
  final DateTime date;
}

class EmployeesCalendarExtendForward extends EmployeesCalendarEvent {
  const EmployeesCalendarExtendForward({required this.anchor, this.days = 2});
  final DateTime anchor;
  final int days;
}

class EmployeesCalendarExtendBackward extends EmployeesCalendarEvent {
  const EmployeesCalendarExtendBackward({required this.anchor, this.days = 1});
  final DateTime anchor;
  final int days;
}

class _EmployeesCalendarSnapshotArrived extends EmployeesCalendarEvent {
  const _EmployeesCalendarSnapshotArrived({required this.snapshot});
  final QuerySnapshot<Map<String, dynamic>> snapshot;
}
