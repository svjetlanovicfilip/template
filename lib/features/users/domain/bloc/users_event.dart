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

class SelectUser extends UsersEvent {
  const SelectUser({required this.userId});
  final String userId;
}


/// NOVO: reorder event
class UsersReordered extends UsersEvent {
  const UsersReordered({required this.oldIndex, required this.newIndex});

final int oldIndex;
final int newIndex;

  @override
  List<Object> get props => [oldIndex, newIndex];
}