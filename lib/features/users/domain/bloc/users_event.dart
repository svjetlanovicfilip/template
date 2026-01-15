part of 'users_bloc.dart';

sealed class UsersEvent extends Equatable {
  const UsersEvent();

  @override
  List<Object> get props => [];
}

final class UsersFetchRequested extends UsersEvent {}

class UserAdded extends UsersEvent {
  const UserAdded({required this.user});
  final UserModel user;
}

class UserRemoved extends UsersEvent {
  const UserRemoved({required this.userId});
  final String userId;
}
