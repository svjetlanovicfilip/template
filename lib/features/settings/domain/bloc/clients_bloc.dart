import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../../common/di/di_container.dart';
import '../../data/client.dart';
import '../../data/repositories/client_repository.dart';
import '../cubit/client_picker_cubit.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc({required this.clientRepository, required this.clientPickerCubit}) : super(ClientsInitial()) {
    on<ClientsFetchRequested>(_onFetchClients);
    on<ClientAdded>(_onClientAdded);
    on<ClientRemoved>(_onClientRemoved);
    on<ClientUpdated>(_onClientUpdated);
    on<ClientsSearched>(_onClientsSearched);
    on<ClientSelected>(_onClientSelected);
  }

  final ClientRepository clientRepository;

  final ClientPickerCubit clientPickerCubit;

  List<Client> get clients => _clients;

  final List<Client> _clients = [];

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
        isActive: event.client.isActive,
      );

      _clients.add(createdClient);

      if(event.isClientAddedFromAppointment){
        clientPickerCubit.pickClient(client: createdClient);
      }
      // 3) emit success za UI
      emit(ClientsFetchingSuccess(List.from(_clients)));
    } on Exception catch (_) {
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
          isActive: updated.isActive,
        );

        _clients[index] = merged;
      }

      // 3) emit za UI
      emit(ClientsFetchingSuccess(List.from(_clients)));
    } on Exception catch (_) {
      // bez Failure state-a, vraćamo trenutno stanje
      emit(ClientsFetchingSuccess(List.from(_clients)));
    }
  }

  Future<void> _onClientRemoved(
    ClientRemoved event,
    Emitter<ClientsState> emit,
  ) async {
    final organizationId = appState.organizationId;
    if (organizationId == null) return;

    // opcionalno: prikaži loader
    emit(ClientsFetching());

    try {
      // 1) prvo soft-delete na backendu
      await clientRepository.deleteClient(event.clientId, organizationId);

      // 2) tek onda lokalno markiraj isActive=false
      final index = _clients.indexWhere((c) => c.id == event.clientId);
      if (index != -1) {
        final old = _clients[index];

        _clients[index] = Client(
          id: old.id,
          name: old.name,
          phoneNumber: old.phoneNumber,
          description: old.description,
          createdAt: old.createdAt,
          isActive: false,
        );
      }

      emit(ClientsFetchingSuccess(List.from(_clients)));
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      // ako imaš Failure state, emituj njega; u suprotnom vrati listu kakva je bila
      emit(ClientsFetchingSuccess(List.from(_clients)));
    }
  }

  void clearState() {
    _clients.clear();
  }

  void _onClientsSearched(ClientsSearched event, Emitter<ClientsState> emit) {
    if (_clients.isEmpty) {
      return;
    }

    final searchQuery = event.searchQuery;
    if (searchQuery.isEmpty) {
      emit(ClientsFetchingSuccess(List.from(_clients)));
      return;
    }

    final clients =
        _clients
            .where(
              (client) =>
                  client.name.toLowerCase().contains(searchQuery.toLowerCase()),
            )
            .toList();

    emit(ClientsSearchSuccess(List.from(clients)));
  }

  void _onClientSelected(ClientSelected event, Emitter<ClientsState> emit) {
    if (event.clientId == null) {
      return;
    }

    final client = _clients.firstWhere((client) => client.id == event.clientId);
    emit(ClientsSelectSuccess(client));
  }
}
