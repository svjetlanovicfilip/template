import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/user_repository.dart';


part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this.repository) : super(const EmployeeInitial()) {
    on<CreateEmployeeSubmitted>(_onCreateEmployeeSubmitted);
  }

  final UserRepository repository;

  Future<void> _onCreateEmployeeSubmitted(
    CreateEmployeeSubmitted e,
    Emitter<UserState> emit,
  ) async {
    emit(const EmployeeSubmitting());

    final result = await repository.createEmployee(
      name: e.name,
      lastName: e.lastName,
      username: e.username,
      email: e.email,
    );

    if (result.isFailure) {
      emit(EmployeeFailure(result.failure?.toString() ?? 'Unknown error'));
      return;
    }

    emit(EmployeeSuccess(result.success ?? const {}));
  }
}

