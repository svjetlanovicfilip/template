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

class ClientRemoved extends ClientsEvent {
  const ClientRemoved({required this.clientId});

  final String clientId;

  @override
  List<Object?> get props => [clientId];
}

// sealed class ClientsEvent extends Equatable {
//   const ClientsEvent();

//   @override
//   List<Object> get props => [];
// }

// final class ClientsFetchRequested extends ClientsEvent {}

// class ClientAdded extends ClientsEvent {
//   const ClientAdded({required this.client});
//   final ClientsEvent client;
// }

// class ClientRemoved extends ClientsEvent {
//   const ClientRemoved({required this.clientId});
//   final String clientId;
// }
