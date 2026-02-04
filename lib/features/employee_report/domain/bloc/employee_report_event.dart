part of 'employee_report_bloc.dart';

sealed class EmployeeReportEvent extends Equatable {
  const EmployeeReportEvent();

  @override
  List<Object> get props => [];
}

class EmployeeChanged extends EmployeeReportEvent {
  const EmployeeChanged({required this.employeeId});
  final String employeeId;
}

class EmployeeMonthChanged extends EmployeeReportEvent {
  const EmployeeMonthChanged({required this.month});
  final int month;
}

class EmployeeYearChanged extends EmployeeReportEvent {
  const EmployeeYearChanged({required this.year});
  final String year;
}

final class EmployeeReportFetchRequested extends EmployeeReportEvent {}

final class LoadEmployeeSlotsHistory extends EmployeeReportEvent {
  const LoadEmployeeSlotsHistory({this.isInitial = true});
  final bool isInitial;
}
