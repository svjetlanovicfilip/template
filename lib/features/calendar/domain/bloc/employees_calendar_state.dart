part of 'employees_calendar_bloc.dart';

sealed class EmployeesCalendarState extends Equatable {
  const EmployeesCalendarState();
  @override
  List<Object?> get props => [];
}

final class EmployeesCalendarInitial extends EmployeesCalendarState {}

final class EmployeesCalendarLoading extends EmployeesCalendarState {}

final class EmployeesCalendarLoaded extends EmployeesCalendarState {
  const EmployeesCalendarLoaded({required this.slots});
  final List<Slot> slots;
  @override
  List<Object?> get props => [slots];
}
