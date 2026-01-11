part of 'user_bloc.dart';

sealed class UserEvent {
  const UserEvent();
}

class CreateEmployeeSubmitted extends UserEvent {
  const CreateEmployeeSubmitted({
    required this.name,
    required this.lastName,
    required this.username,
    required this.email,
  });

  final String name;
  final String lastName;
  final String username;
  final String email;
}
