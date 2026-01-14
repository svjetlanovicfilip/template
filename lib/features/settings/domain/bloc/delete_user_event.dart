part of 'delete_user_bloc.dart';

sealed class DeleteUserEvent {
  const DeleteUserEvent();
}

class DeleteEmployeeSubmitted extends DeleteUserEvent {
  const DeleteEmployeeSubmitted({
    required this.employeeUid,
  });

  final String employeeUid;
}

