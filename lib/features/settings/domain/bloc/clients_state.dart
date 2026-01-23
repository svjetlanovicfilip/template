part of 'clients_bloc.dart';

sealed class ClientsState extends Equatable {
  const ClientsState();

  @override
  List<Object> get props => [];
}

final class ClientsInitial extends ClientsState {}

class ClientsFetching extends ClientsState {}

class ClientsFetchingSuccess extends ClientsState {
  const ClientsFetchingSuccess(this.clients);
  final List<Client> clients;

  @override
  List<Object> get props => [clients];
}

class ClientsSearchSuccess extends ClientsState {
  const ClientsSearchSuccess(this.clients);
  final List<Client> clients;

  @override
  List<Object> get props => [clients];
}

class ClientsSelectSuccess extends ClientsState {
  const ClientsSelectSuccess(this.client);
  final Client client;
}
