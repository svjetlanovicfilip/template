import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/client_slot.dart';
import '../../data/repositories/client_history_repository.dart';

part 'client_history_event.dart';
part 'client_history_state.dart';

class ClientHistoryBloc extends Bloc<ClientHistoryEvent, ClientHistoryState> {
  ClientHistoryBloc({required this.clientHistoryRepository})
    : super(ClientHistoryInitial()) {
    on<ClientHistoryFetchRequested>(_onClientHistoryFetchRequested);
    on<ClientHistoryLoadMoreRequested>(_onClientHistoryLoadMoreRequested);
  }

  final ClientHistoryRepository clientHistoryRepository;

  final List<ClientSlot> _slots = [];
  DocumentSnapshot<Map<String, dynamic>>? _lastDocument;
  bool _hasMore = true;
  final int _pageSize = 5;
  bool _isLoading = false;

  Future<void> _onClientHistoryFetchRequested(
    ClientHistoryFetchRequested event,
    Emitter<ClientHistoryState> emit,
  ) async {
    emit(ClientHistoryLoading());

    final result = await clientHistoryRepository.getClientSlots(event.clientId);

    if (result.isFailure) {
      emit(ClientHistoryError(error: result.failure!));
      return;
    }

    if (result.success?.isEmpty ?? true) {
      emit(const ClientHistoryLoaded(slots: []));
      return;
    }

    _lastDocument = result.success?.last;
    _hasMore = result.success?.length == _pageSize;

    final slots =
        result.success?.map((e) => ClientSlot.fromJson(e.data())).toList();

    _slots.addAll(slots ?? []);

    emit(ClientHistoryLoaded(slots: List.from(_slots)));
  }

  Future<void> _onClientHistoryLoadMoreRequested(
    ClientHistoryLoadMoreRequested event,
    Emitter<ClientHistoryState> emit,
  ) async {
    if (_lastDocument == null || !_hasMore) {
      return;
    }

    if (_isLoading) {
      return;
    }

    _isLoading = true;
    emit(ClientHistoryLoadingMore());

    final result = await clientHistoryRepository.getClientSlots(
      event.clientId,
      lastDocument: _lastDocument,
    );

    if (result.isFailure) {
      emit(ClientHistoryError(error: result.failure!));
      return;
    }

    _hasMore = result.success?.length == _pageSize;
    _lastDocument = result.success?.last;
    _isLoading = false;

    final slots =
        result.success?.map((e) => ClientSlot.fromJson(e.data())).toList();
    _slots.addAll(slots ?? []);

    emit(ClientHistoryLoaded(slots: List.from(_slots)));
  }
}
