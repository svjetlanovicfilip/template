import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/slot.dart';
import '../../data/repositories/calendar_repository.dart';

part 'slot_event.dart';
part 'slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  SlotBloc(this.calendarRepository) : super(SlotState.initial()) {
    on<LoadInitialRange>(_onInitialLoad);
    on<LoadMoreBackward>(_onLoadMoreBackward);
    on<LoadMoreForward>(_onLoadMoreForward);
    on<AddNewSlot>(_onAddNewSlot);
  }

  final CalendarRepository calendarRepository;

  Future<void> _onInitialLoad(
    LoadInitialRange e,
    Emitter<SlotState> emit,
  ) async {
    final from = e.weekStart.subtract(const Duration(days: 7)); // 1 week before
    final to = e.weekEnd.add(const Duration(days: 14)); // 2 week after

    final slots = await calendarRepository.fetchRangeSlots(
      organizationId: state.organizationId,
      userId: state.userId,
      from: from,
      to: to,
    );

    slots.when(
      onSuccess:
          (slots) => emit(
            state.copyWith(slots: slots, loadedFrom: from, loadedTo: to),
          ),
      onFailure: (error) => emit(state),
    );
  }

  Future<void> _onLoadMoreForward(
    LoadMoreForward e,
    Emitter<SlotState> emit,
  ) async {
    final end = state.loadedTo;

    if (end.subtract(const Duration(days: 7)).isAfter(e.currentDisplayedDate)) {
      return;
    }

    final newTo = state.loadedTo.add(Duration(days: e.days));
    final result = await calendarRepository.fetchRangeSlots(
      organizationId: state.organizationId,
      userId: state.userId,
      from: state.loadedTo.add(const Duration(days: 1)),
      to: newTo,
    );

    if (result.isFailure) {
      emit(state);
      return;
    }

    final updated = List<Slot>.from(state.slots)..addAll(result.success ?? []);

    emit(state.copyWith(slots: updated, loadedTo: newTo));
  }

  Future<void> _onLoadMoreBackward(
    LoadMoreBackward e,
    Emitter<SlotState> emit,
  ) async {
    final newFrom = state.loadedFrom.subtract(Duration(days: e.days));
    final result = await calendarRepository.fetchRangeSlots(
      organizationId: state.organizationId,
      userId: state.userId,
      from: newFrom,
      to: state.loadedFrom.subtract(const Duration(days: 1)),
    );

    if (result.isFailure) {
      emit(state);
      return;
    }

    final updated = List<Slot>.from(state.slots)
      ..insertAll(0, result.success ?? []);

    emit(state.copyWith(slots: updated, loadedFrom: newFrom));
  }

  Future<void> _onAddNewSlot(AddNewSlot e, Emitter<SlotState> emit) async {
    final isOverlapping = await calendarRepository.isSlotOverlapping(
      e.slot.startDateTime,
      e.slot.endDateTime,
    );

    if ((isOverlapping.success ?? false) || isOverlapping.isFailure) {
      emit(
        state.copyWith(
          errorMessage:
              'Termin se preklapa s drugim terminom. Molimo Vas izaberite drugi termin.',
        ),
      );
      return;
    }

    // optimistic update → prvo dodamo u state da UI bude instant
    final updated = List<Slot>.from(state.slots)..add(e.slot);

    emit(state.copyWith(slots: updated));

    // onda silently save u Firestore
    await calendarRepository.createSlot(e.slot);
  }
}
