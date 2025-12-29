import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../data/models/slot.dart';
import '../../data/repositories/calendar_repository.dart';

part 'slot_event.dart';
part 'slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  SlotBloc(this.calendarRepository) : super(const SlotStateInitial()) {
    on<InitListener>(_onInit);
    on<LoadSlots>(_onLoadSlots);
    on<LoadMoreBackward>(_onLoadMoreBackward);
    on<LoadMoreForward>(_onLoadMoreForward);
    on<UserChanged>(_onUserChanged);
    on<AddNewSlot>(_onAddNewSlot);
    on<UpdateSlot>(_onUpdateSlot);
    on<DeleteSlot>(_onDeleteSlot);
  }

  final CalendarRepository calendarRepository;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _slotsListener;

  final _usersSlots = <String, List<Slot>>{};
  DateTime _loadedFrom = DateTime.now();
  DateTime _loadedTo = DateTime.now();

  void _onLoadSlots(LoadSlots e, Emitter<SlotState> emit) {
    emit(const SlotStateInitial());
    emit(
      LoadedRangeSlots(
        slots: List.from(_usersSlots[e.userId] ?? []),
        loadedFrom: _loadedFrom,
        loadedTo: _loadedTo,
        userId: e.userId,
        changedSlotIds: e.changedSlotIds,
        removedSlotIds: e.removedSlotIds,
      ),
    );
  }

  Future<void> _onInit(InitListener e, Emitter<SlotState> emit) async {
    emit(const SlotStateLoading());

    final userId = appState.currentSelectedUserId ?? '';

    _loadedFrom = DateTime.now().subtract(const Duration(days: 14));
    _loadedTo = DateTime.now().add(const Duration(days: 14));

    _attachSlotsListener(userId);
  }

  void _attachSlotsListener(String userId) {
    _slotsListener?.cancel();
    _slotsListener = calendarRepository
        .listenForNewChanges(userId: userId, from: _loadedFrom, to: _loadedTo)
        .listen((snapshot) {
          final changedSlotIds = <String>[];
          final removedSlotIds = <String>[];

          for (final change in snapshot.docChanges) {
            final id = change.doc.id;
            final slot = Slot.fromJson(change.doc.data() ?? {}, id);

            switch (change.type) {
              case DocumentChangeType.added:
              case DocumentChangeType.modified:
                _usersSlots[userId] ??= [];
                final index = _usersSlots[userId]!.indexWhere(
                  (s) => s.id == slot.id,
                );
                if (index >= 0) {
                  _usersSlots[userId]![index] = slot;
                  changedSlotIds.add(id);
                } else {
                  _usersSlots[userId]!.add(slot);
                }

                break;
              case DocumentChangeType.removed:
                _usersSlots[userId]?.removeWhere((s) => s.id == id);
                removedSlotIds.add(id);
                break;
            }
          }

          add(
            LoadSlots(
              userId: userId,
              changedSlotIds: changedSlotIds,
              removedSlotIds: removedSlotIds,
            ),
          );
        });
  }

  void _extendListenerRange(
    String userId, {
    DateTime? newFrom,
    DateTime? newTo,
  }) {
    var shouldExtend = false;

    if (newFrom != null && newFrom.isBefore(_loadedFrom)) {
      _loadedFrom = newFrom;
      shouldExtend = true;
    }

    if (newTo != null && newTo.isAfter(_loadedTo)) {
      _loadedTo = newTo;
      shouldExtend = true;
    }

    if (shouldExtend) {
      _attachSlotsListener(userId);
    }
  }

  Future<void> _onUserChanged(UserChanged e, Emitter<SlotState> emit) async {
    emit(
      LoadedSlotsAfterUserChanged(
        slots: List.from(_usersSlots[e.userId] ?? []),
        loadedFrom: e.currentDisplayedDate.subtract(const Duration(days: 14)),
        loadedTo: e.currentDisplayedDate.add(const Duration(days: 14)),
        userId: e.userId,
      ),
    );

    appState.currentSelectedUserId = e.userId;

    _loadedFrom = e.currentDisplayedDate.subtract(const Duration(days: 14));
    _loadedTo = e.currentDisplayedDate.add(const Duration(days: 14));

    _attachSlotsListener(e.userId);
  }

  Future<void> _onLoadMoreForward(
    LoadMoreForward e,
    Emitter<SlotState> emit,
  ) async {
    final userId = appState.currentSelectedUserId ?? '';

    final end = _loadedTo;

    if (end.subtract(const Duration(days: 8)).isAfter(e.currentDisplayedDate)) {
      return;
    }

    _extendListenerRange(userId, newTo: end.add(Duration(days: e.days)));
  }

  Future<void> _onLoadMoreBackward(
    LoadMoreBackward e,
    Emitter<SlotState> emit,
  ) async {
    final userId = appState.currentSelectedUserId ?? '';
    final start = _loadedFrom;

    if (e.currentDisplayedDate.isAfter(start.add(const Duration(days: 8)))) {
      return;
    }

    _extendListenerRange(
      userId,
      newFrom: start.subtract(Duration(days: e.days)),
    );
  }

  Future<void> _onAddNewSlot(AddNewSlot e, Emitter<SlotState> emit) async {
    emit(const SlotStateInitial());

    if (e.slot.endDateTime == null) {
      emit(
        const ErrorLoadingSlots(
          errorMessage: 'Molimo Vas izaberite početak i kraj termina.',
        ),
      );
      return;
    }

    final isOverlapping = await calendarRepository.isSlotOverlapping(
      newStart: e.slot.startDateTime,
      newEnd: e.slot.endDateTime!,
      userId: e.userId,
    );

    if ((isOverlapping.success ?? false) || isOverlapping.isFailure) {
      emit(
        const ErrorLoadingSlots(
          errorMessage:
              'Termin se preklapa s drugim terminom. Molimo Vas izaberite drugi termin.',
        ),
      );
      return;
    }

    final result = await calendarRepository.createSlot(e.slot, e.userId);

    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }
  }

  Future<void> _onUpdateSlot(UpdateSlot e, Emitter<SlotState> emit) async {
    emit(const SlotStateInitial());

    final slot = e.slot;

    if (slot.endDateTime == null) {
      emit(
        const ErrorLoadingSlots(
          errorMessage: 'Molimo Vas izaberite početak i kraj termina.',
        ),
      );
      return;
    }

    final isOverlapping = await calendarRepository.isSlotOverlapping(
      newStart: slot.startDateTime,
      newEnd: slot.endDateTime!,
      userId: e.userId,
      excludeSlotId: slot.id,
    );

    if ((isOverlapping.success ?? false) || isOverlapping.isFailure) {
      emit(
        const ErrorLoadingSlots(
          errorMessage:
              'Termin se preklapa s drugim terminom. Molimo Vas izaberite drugi termin.',
        ),
      );
      return;
    }

    await calendarRepository.updateSlot(slot, e.userId);
  }

  Future<void> _onDeleteSlot(DeleteSlot e, Emitter<SlotState> emit) async {
    final result = await calendarRepository.deleteSlot(e.slotId, e.userId);
    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }
  }
}
