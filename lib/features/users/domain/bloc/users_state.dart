part of 'users_bloc.dart';

sealed class UsersState extends Equatable {
  const UsersState();

  @override
  List<Object> get props => [];
}

final class UsersInitial extends UsersState {}

class UsersFetching extends UsersState {}

class UsersAdding extends UsersState {}

class UsersFetchingSuccess extends UsersState {
  const UsersFetchingSuccess(this.users, {this.shouldRefreshUsersList = true});
  final List<UserModel> users;
  final bool shouldRefreshUsersList;
  @override
  List<Object> get props => [users, shouldRefreshUsersList];
}

class UserSelected extends UsersState {
  const UserSelected({required this.user});
  final UserModel user;

  @override
  List<Object> get props => [user];
}
