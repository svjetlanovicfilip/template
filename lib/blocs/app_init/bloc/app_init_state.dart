part of 'app_init_bloc.dart';

sealed class AppInitState extends Equatable {
  const AppInitState();

  @override
  List<Object> get props => [];
}

final class AppInitInitial extends AppInitState {}

final class AppInitLoading extends AppInitState {}

final class AppInitUnauthenticated extends AppInitState {}

final class AppInitReady extends AppInitState {
  const AppInitReady({required this.slots});
  final List<Slot> slots;

  @override
  List<Object> get props => [slots];
}
