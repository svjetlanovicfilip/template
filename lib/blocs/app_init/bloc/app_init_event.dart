part of 'app_init_bloc.dart';

sealed class AppInitEvent extends Equatable {
  const AppInitEvent();

  @override
  List<Object> get props => [];
}

class AppInitStarted extends AppInitEvent {}

class AppInitAfterLogin extends AppInitEvent {}
