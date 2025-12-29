import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../../organization/data/repositories/organization_repository.dart';
import '../../data/repositories/authentication_repository.dart';

part 'authentication_event.dart';
part 'authentication_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({
    required this.authenticationRepository,
    required this.organizationRepository,
  }) : super(const AuthenticationState()) {
    on<AuthenticationCheckRequested>(_onAuthenticationCheckRequested);
  }

  final AuthenticationRepository authenticationRepository;
  final OrganizationRepository organizationRepository;

  Future<void> _onAuthenticationCheckRequested(
    AuthenticationCheckRequested event,
    Emitter<AuthenticationState> emit,
  ) async {
    final user = authenticationRepository.isUserAuthenticated();
    if (user.isFailure) {
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      return;
    }

    final userProfile = await authenticationRepository.getUserProfile(
      user.success?.uid ?? '',
    );

    if (userProfile.isFailure) {
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      return;
    }

    if (userProfile.success?.organizationId == null) {
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      return;
    }

    final organization = await organizationRepository.getUserOrganization(
      userProfile.success!.organizationId!,
    );

    if (organization.isFailure) {
      emit(state.copyWith(status: AuthenticationStatus.unauthenticated));
      return;
    }

    appState
      ..currentUser = userProfile.success!
      ..currentSelectedUserId = userProfile.success!.id
      ..organizationId = userProfile.success!.organizationId
      ..userOrganization = organization.success;

    if (appState.currentUser?.role == 'ORG_OWNER') {
      final organizationUsers = await organizationRepository
          .getOrganizationUsers(userProfile.success!.organizationId!);

      if (organizationUsers.isFailure) {
        return;
      }

      appState.setOrganizationUsers(organizationUsers.success!);
    }

    emit(state.copyWith(status: AuthenticationStatus.authenticated));
  }
}
