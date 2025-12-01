import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({required this.authenticationRepository})
    : super(const AuthenticationState()) {
    on<AuthenticationCheckRequested>(_onAuthenticationCheckRequested);
  }

  final AuthenticationRepository authenticationRepository;

  void _onAuthenticationCheckRequested(
    AuthenticationCheckRequested event,
    Emitter<AuthenticationState> emit,
  ) {
    authenticationRepository.isUserAuthenticated().when(
      onSuccess: (user) {
        emit(state.copyWith(status: AuthenticationStatus.authenticated));
      },
      onFailure: (error) {
        emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      },
    );
  }
}
