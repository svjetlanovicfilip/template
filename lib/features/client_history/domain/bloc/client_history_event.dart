part of 'client_history_bloc.dart';

sealed class ClientHistoryEvent extends Equatable {
  const ClientHistoryEvent();

  @override
  List<Object> get props => [];
}

class ClientHistoryFetchRequested extends ClientHistoryEvent {
  const ClientHistoryFetchRequested({required this.clientId});
  final String clientId;
}

class ClientHistoryLoadMoreRequested extends ClientHistoryEvent {
  const ClientHistoryLoadMoreRequested({required this.clientId});

  final String clientId;
}
