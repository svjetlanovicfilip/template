import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../../common/di/di_container.dart';
import '../../data/client.dart';
import '../../data/repositories/client_repository.dart';
import '../cubit/client_picker_cubit.dart';

part 'clients_event.dart';
part 'clients_state.dart';

class ClientsBloc extends Bloc<ClientsEvent, ClientsState> {
  ClientsBloc({required this.clientRepository, required this.clientPickerCubit})
    : super(ClientsInitial()) {
    on<ClientsInitListener>(_onInitListener);
    on<ClientsFetchRequested>(_onFetchClients);
    on<ClientAdded>(_onClientAdded);
    on<ClientRemoved>(_onClientRemoved);
    on<ClientUpdated>(_onClientUpdated);
    on<ClientsSearched>(_onClientsSearched);
    on<ClientSelected>(_onClientSelected);
  }

  final ClientRepository clientRepository;

  final ClientPickerCubit clientPickerCubit;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _clientsListener;

  List<Client> get clients => _clients;

  final List<Client> _clients = [];

  Future<void> _onInitListener(
    ClientsInitListener event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsFetching());

    final orgId = appState.organizationId;
    if (orgId == null) {
      return;
    }

    _clientsListener = clientRepository
        .fetchClients(organizationId: orgId)
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final id = change.doc.id;
            final client = Client.fromJson(change.doc.data() ?? {}, id);

            switch (change.type) {
              case DocumentChangeType.added:
                _clients.add(client);
                break;
              case DocumentChangeType.modified:
                final index = _clients.indexWhere((c) => c.id == id);
                if (index != -1) {
                  _clients[index] = client;
                }
                break;
              case DocumentChangeType.removed:
                _clients.removeWhere((c) => c.id == id);
                break;
            }
          }

          add(ClientsFetchRequested());
        });
  }

  Future<void> _onFetchClients(
    ClientsFetchRequested event,
    Emitter<ClientsState> emit,
  ) async => emit(ClientsFetchingSuccess(List.from(_clients)));

  Future<void> _onClientAdded(
    ClientAdded event,
    Emitter<ClientsState> emit,
  ) async {
    emit(ClientsAdding());

    final orgId = appState.organizationId;

    if (orgId == null) {
      return;
    }

    try {
      final clientId = await clientRepository.createClient(event.client, orgId);

      final createdClient = Client(
        id: clientId,
        name: event.client.name,
        phoneNumber: event.client.phoneNumber,
        description: event.client.description,
        createdAt: event.client.createdAt,
        isActive: event.client.isActive,
      );

      //if client is added from appointment, pick it
      if (event.isClientAddedFromAppointment) {
        clientPickerCubit.pickClient(client: createdClient);
      }
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
    emit(ClientsAdding());

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
      // 1) update in databse and listen for changes
      await clientRepository.updateClient(updated, orgId);
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

    try {
      // 1) prvo soft-delete na backendu
      await clientRepository.deleteClient(event.clientId, organizationId);
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
    _clientsListener?.cancel();
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
