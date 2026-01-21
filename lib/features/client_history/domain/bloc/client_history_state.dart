part of 'client_history_bloc.dart';

sealed class ClientHistoryState extends Equatable {
  const ClientHistoryState();

  @override
  List<Object> get props => [];
}

final class ClientHistoryInitial extends ClientHistoryState {}

final class ClientHistoryLoading extends ClientHistoryState {}

final class ClientHistoryLoaded extends ClientHistoryState {
  const ClientHistoryLoaded({required this.slots});
  final List<ClientSlot> slots;

  @override
  List<Object> get props => [slots];
}

final class ClientHistoryLoadingMore extends ClientHistoryState {}

final class ClientHistoryError extends ClientHistoryState {
  const ClientHistoryError({required this.error});
  final Exception error;

  @override
  List<Object> get props => [error];
}
