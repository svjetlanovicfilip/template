import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../data/repositories/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({required this.loginRepository}) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginRepository loginRepository;

  void _onEmailChanged(LoginEmailChanged event, Emitter<LoginState> emit) {
    final email = Email.dirty(event.email);
    emit(
      state.copyWith(
        email: email,
        isValid: Formz.validate([state.password, email]),
      ),
    );
  }

  void _onPasswordChanged(
    LoginPasswordChanged event,
    Emitter<LoginState> emit,
  ) {
    final password = Password.dirty(event.password);
    emit(
      state.copyWith(
        password: password,
        isValid: Formz.validate([state.email, password]),
      ),
    );
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    if (!state.isFormSubmitted) {
      emit(state.copyWith(isFormSubmitted: true));
    }

    if (!Formz.validate([state.email, state.password])) {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
      return;
    }

    if (state.isValid) {
      emit(state.copyWith(status: FormzSubmissionStatus.inProgress));

      final result = await loginRepository.login(
        state.email.value,
        state.password.value,
      );
      result.when(
        onSuccess: (user) {
          emit(
            state.copyWith(
              status: FormzSubmissionStatus.success,
              isFormSubmitted: false,
            ),
          );
        },
        onFailure: (error) {
          emit(
            state.copyWith(
              status: FormzSubmissionStatus.failure,
              errorMessage: error.message,
            ),
          );
        },
      );
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }
}
