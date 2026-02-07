import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../../login/data/models/user_model.dart';
import '../../../organization/data/repositories/organization_repository.dart';
import '../../../settings/data/repositories/user_repository.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc({
    required this.organizationRepository,
    required this.userRepository,
  }) : super(UsersInitial()) {
    on<UsersFetchRequested>(_onUsersFetchRequested);
    on<UserAdded>(_onUserAdded);
    on<UserRemoved>(_onUserRemoved);
    on<SelectUser>(_onUserSelected);
  }

  final OrganizationRepository organizationRepository;
  final UserRepository userRepository;

  List<UserModel> get users => _users;
  UserModel? _selectedUser;

  List<UserModel> _users = [];

  Future<void> _onUsersFetchRequested(
    UsersFetchRequested event,
    Emitter<UsersState> emit,
  ) async {
    if (_users.isNotEmpty) {
      emit(UsersFetchingSuccess(List.from(_users)));
      return;
    }

    emit(UsersFetching());

    final users = await organizationRepository.getOrganizationUsers(
      appState.organizationId!,
    );

    if (users.isFailure) {
      return;
    }

    _users = (users.success ?? []).where((u) => u.isActive).toList();

    emit(UsersFetchingSuccess(List.from(_users)));
  }

  Future<void> _onUserAdded(UserAdded event, Emitter<UsersState> emit) async {
    emit(UsersAdding());

    final result = await userRepository.createEmployee(
      name: event.user.name ?? '',
      lastName: event.user.surname ?? '',
      username: event.user.username ?? '',
      email: event.user.email,
    );

    if (result.isFailure) {
      return;
    }

    if (result.success != null) {
      _users.add(result.success!);
      emit(UsersFetchingSuccess(List.from(_users)));
    }
  }

  Future<void> _onUserRemoved(
    UserRemoved event,
    Emitter<UsersState> emit,
  ) async {
    _users.removeWhere((user) => user.id == event.userId);

    emit(UsersFetchingSuccess(List.from(_users)));

    final result = await userRepository.deleteEmployee(
      employeeUid: event.userId,
    );

    if (result.isFailure) {
      return;
    }
  }

  void _onUserSelected(SelectUser event, Emitter<UsersState> emit) {
    _selectedUser = _users.firstWhere((user) => user.id == event.userId);
    emit(UserSelected(user: _selectedUser!));
  }

  void clearState() {
    _users.clear();
    _selectedUser = null;
  }
}
