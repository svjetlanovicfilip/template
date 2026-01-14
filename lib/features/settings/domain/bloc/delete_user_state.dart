part of 'delete_user_bloc.dart';

sealed class DeleteUserState extends Equatable {
  const DeleteUserState();

  @override
  List<Object?> get props => [];
}

class DeleteUserInitial extends DeleteUserState {
  const DeleteUserInitial();
}

class DeleteUserSubmitting extends DeleteUserState {
  const DeleteUserSubmitting();
}


class DeleteUserSuccess extends DeleteUserState {
  const DeleteUserSuccess(this.employeeUid);
  final String employeeUid;

  @override
  List<Object?> get props => [employeeUid];
}


class DeleteUserFailure extends DeleteUserState {
  const DeleteUserFailure(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

