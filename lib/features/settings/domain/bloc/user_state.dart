part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class EmployeeInitial extends UserState {
  const EmployeeInitial();
}

class EmployeeSubmitting extends UserState {
  const EmployeeSubmitting();
}

class EmployeeSuccess extends UserState {
  const EmployeeSuccess(this.data);
  final Map<String, dynamic> data;

  @override
  List<Object?> get props => [data];
}

class EmployeeFailure extends UserState {
  const EmployeeFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}
