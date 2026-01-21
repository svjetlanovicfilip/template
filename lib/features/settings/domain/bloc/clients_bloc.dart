import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../data/client.dart';
import '../../data/repositories/client_repository.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc({required this.clientRepository}) : super(ClientsInitial()) {
    on<ClientsFetchRequested>(_onFetchClients);
    on<ClientAdded>(_onClientAdded);
    on<ClientRemoved>(_onClientRemoved);
    on<ClientUpdated>(_onClientUpdated);
  }

  final ClientRepository clientRepository;

  List<Client> _clients = [];

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

  Future<void> _onClientUpdated(
    ClientUpdated event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsFetching());

    final orgId = appState.organizationId;
    if (orgId == null) {
      // nema orgId -> vrati listu kakva je
      emit(ClientsFetchingSuccess(List.from(_clients)));
      return;
    }

    final updated = event.client;
    final updatedId = updated.id;

    if (updatedId == null || updatedId.isEmpty) {
      emit(ClientsFetchingSuccess(List.from(_clients)));
      return;
    }

    try {
      // 1) update u bazi
      await clientRepository.updateClient(updated, orgId);

      // 2) update lokalne liste
      final index = _clients.indexWhere((c) => c.id == updatedId);
      if (index != -1) {
        // zadrži createdAt iz lokalnog (server timestamp je već tamo),
        // osim ako ti baš šalješ novi createdAt (obično ne treba)
        final prev = _clients[index];

        final merged = Client(
          id: updatedId,
          name: updated.name,
          phoneNumber: updated.phoneNumber,
          description: updated.description,
          createdAt: prev.createdAt,
        );

        _clients[index] = merged;
      }

      // 3) emit za UI
      emit(ClientsFetchingSuccess(List.from(_clients)));
    } catch (e) {
      // bez Failure state-a, vraćamo trenutno stanje
      emit(ClientsFetchingSuccess(List.from(_clients)));
    }
  }

  Future<void> _onClientRemoved(
    ClientRemoved event,
    Emitter<ClientsState> emit,
  ) async {
    _clients.removeWhere((client) => client.id == event.clientId);

    emit(ClientsFetchingSuccess(List.from(_clients)));
    final organizationId = appState.organizationId;

    if (organizationId == null) {
      return;
    }
    await clientRepository.deleteClient(event.clientId, organizationId);
  }

  void clearState() {
    _clients.clear();
  }
}
