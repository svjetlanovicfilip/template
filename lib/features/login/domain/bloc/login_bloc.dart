import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:formz/formz.dart';

import '../../../../common/di/di_container.dart';
import '../../../authentication/data/repositories/authentication_repository.dart';
import '../../../organization/data/repositories/organization_repository.dart';
import '../../data/repositories/login_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc({
    required this.loginRepository,
    required this.authenticationRepository,
    required this.organizationRepository,
  }) : super(const LoginState()) {
    on<LoginEmailChanged>(_onEmailChanged);
    on<LoginPasswordChanged>(_onPasswordChanged);
    on<LoginSubmitted>(_onLoginSubmitted);
  }

  final LoginRepository loginRepository;
  final AuthenticationRepository authenticationRepository;
  final OrganizationRepository organizationRepository;

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

      if (result.isFailure) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: result.failure?.message,
          ),
        );
        return;
      }

      final isUserProfileAndOrganizationValid =
          await _getUserProfileAndOrganization(result.success?.id ?? '');

      if (!isUserProfileAndOrganizationValid) {
        emit(
          state.copyWith(
            status: FormzSubmissionStatus.failure,
            errorMessage: 'User profile and organization are not valid',
          ),
        );
        return;
      }

      emit(
        state.copyWith(
          status: FormzSubmissionStatus.success,
          isFormSubmitted: false,
        ),
      );
    } else {
      emit(state.copyWith(status: FormzSubmissionStatus.failure));
    }
  }

  Future<bool> _getUserProfileAndOrganization(String userId) async {
    final userProfile = await authenticationRepository.getUserProfile(userId);

    if (userProfile.isFailure) {
      return false;
    }

    if (userProfile.success?.organizationId == null) {
      return false;
    }

    final organization = await organizationRepository.getUserOrganization(
      userProfile.success!.organizationId!,
    );

    if (organization.isFailure) {
      return false;
    }

    appState
      ..currentUser = userProfile.success!
      ..organizationId = userProfile.success!.organizationId
      ..userOrganization = organization.success;

    if (appState.currentUser?.role == 'ORG_OWNER') {
      final organizationUsers = await organizationRepository
          .getOrganizationUsers(userProfile.success!.organizationId!);

      if (organizationUsers.isFailure) {
        return false;
      }

      appState.setOrganizationUsers(organizationUsers.success!);
    }

    return true;
  }
}
