part of 'authentication_bloc.dart';

enum AuthenticationStatus { authenticated, unauthenticated }

class AuthenticationState extends Equatable {
  const AuthenticationState({
    this.status = AuthenticationStatus.unauthenticated,
  });

  final AuthenticationStatus status;

  AuthenticationState copyWith({AuthenticationStatus? status}) {
    return AuthenticationState(status: status ?? this.status);
  }

  @override
  List<Object> get props => [status];
}
