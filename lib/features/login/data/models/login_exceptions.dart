import 'package:equatable/equatable.dart';

class LoginException extends Equatable {
  const LoginException({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

class UserNotFoundException extends LoginException {
  const UserNotFoundException({required super.message});
}

class WrongPasswordException extends LoginException {
  const WrongPasswordException({required super.message});
}
