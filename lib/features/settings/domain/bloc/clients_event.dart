part of 'clients_bloc.dart';

sealed class ClientsEvent extends Equatable {
  const ClientsEvent();

  @override
  List<Object?> get props => [];
}

final class ClientsFetchRequested extends ClientsEvent {}

class ClientAdded extends ClientsEvent {
  const ClientAdded({required this.client});

  final Client client;

  @override
  List<Object?> get props => [client];
}

class ClientUpdated extends ClientsEvent {
  const ClientUpdated({required this.client});

  final Client client;

  @override
  List<Object?> get props => [client];
}

class ClientRemoved extends ClientsEvent {
  const ClientRemoved({required this.clientId});

  final String clientId;

  @override
  List<Object?> get props => [clientId];
}

class ClientsSearched extends ClientsEvent {
  const ClientsSearched({required this.searchQuery});

  final String searchQuery;

  @override
  List<Object?> get props => [searchQuery];
}

class ClientSelected extends ClientsEvent {
  const ClientSelected({this.clientId});

  final String? clientId;

  @override
  List<Object?> get props => [clientId];
}
