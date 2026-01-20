import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../../login/data/models/user_model.dart';
import '../../../organization/data/repositories/organization_repository.dart';
import '../../../settings/data/repositories/user_repository.dart';
import '../../data/client.dart';
import '../../data/repositories/client_repository.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc({required this.clientRepository}) : super(ClientsInitial()) {
    // on<ClientsFetchRequested>(_onClientsFetchRequested);
    on<ClientsFetchRequested>(_onFetchClients);
    on<ClientAdded>(_onClientAdded);
    // on<ClientRemoved>(_onClientRemoved);
  }

  final ClientRepository clientRepository;

  List<Client> _clients = [];

  // Future<void> _onClientsFetchRequested(
  //   ClientsFetchRequested event,
  //   Emitter<ClientsState> emit,
  // ) async {
  //   // Check this
  //   // if (appState.currentUser?.role != 'ORG_OWNER') {
  //   //   return;
  //   // }

  //   emit(ClientsFetching());

  //   final clients = await organizationRepository.getOrganizationUsers(
  //     appState.organizationId!,
  //   );

  //   if (clients.isFailure) {
  //     return;
  //   }

  //   _clients = (clients.success ?? []).where((u) => u.isActive).toList();

  //   emit(ClientsFetchingSuccess(List.from(_clients)));
  // }

  Future<void> _onFetchClients(
    ClientsFetchRequested event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsFetching());

    final orgId = appState.organizationId;
    if (orgId == null) {
      return;
    }

    final result = await clientRepository.fetchClients(organizationId: orgId);

    if (result.isFailure) {
      emit(ClientsFetchingSuccess(List.from(_clients)));
      return;
    }

    _clients
      ..clear()
      ..addAll(result.success ?? []);

    emit(ClientsFetchingSuccess(List.from(_clients)));
  }

  Future<void> _onClientAdded(
    ClientAdded event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsFetching());

    final orgId = appState.organizationId;

    if (orgId == null) {
      return;
    }

    try {
      // 1) create u bazi -> dobijemo docId
      final clientId = await clientRepository.createClient(event.client, orgId);

      // 2) dodaj u lokalnu listu (sa id-jem)
      final createdClient = Client(
        id: clientId,
        name: event.client.name,
        phoneNumber: event.client.phoneNumber,
        description: event.client.description,
        createdAt: event.client.createdAt,
      );

      _clients.add(createdClient);

      // 3) emit success za UI
      emit(ClientsFetchingSuccess(List.from(_clients)));
    } catch (e) {
      // Ako želiš: dodaj ClientsFailure state
      // Za sada možeš bar vratiti prethodno stanje ili prazan:
      emit(ClientsFetchingSuccess(List.from(_clients)));
    }
  }

  void clearState() {
    _clients.clear();
  }
}
