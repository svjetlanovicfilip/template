part of 'users_bloc.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

final class UsersInitial extends UsersState {}

class UsersFetching extends UsersState {}

class UsersFetchingSuccess extends UsersState {
  const UsersFetchingSuccess(this.users);
  final List<UserModel> users;

  @override
  List<Object> get props => [users];
}
