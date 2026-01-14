import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/repositories/user_repository.dart';


part 'delete_user_event.dart';
part 'delete_user_state.dart';

class DeleteUserBloc extends Bloc<DeleteUserEvent, DeleteUserState> {
  DeleteUserBloc(this.repository) : super(const DeleteUserInitial()) {
    on<DeleteEmployeeSubmitted>(_onDeleteEmployeeSubmitted);
  }

  final UserRepository repository;

  Future<void> _onDeleteEmployeeSubmitted(
    DeleteEmployeeSubmitted e,
    Emitter<DeleteUserState> emit,
  ) async {
    emit(const DeleteUserSubmitting());

    final result = await repository.deleteEmployee(
      employeeUid: e.employeeUid
    );

    if (result.isFailure) {
      emit(DeleteUserFailure(result.failure?.toString() ?? 'Unknown error'));
      return;
    }

    final employeeUid = result.success != null && result.success!.isNotEmpty ? result.success!['employeeUid'] : null;

    emit(DeleteUserSuccess(employeeUid ?? ''));
  }
}

