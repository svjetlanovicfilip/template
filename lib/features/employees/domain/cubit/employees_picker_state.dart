part of 'employees_picker_cubit.dart';

sealed class EmployeesPickerState extends Equatable {
  const EmployeesPickerState();

  @override
  List<Object> get props => [];
}

final class EmployeesPickerInitial extends EmployeesPickerState {}
