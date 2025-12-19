import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../data/models/slot.dart';
import '../../data/repositories/calendar_repository.dart';

part 'slot_event.dart';
part 'slot_state.dart';

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  SlotBloc(this.calendarRepository) : super(const SlotStateInitial()) {
    on<LoadInitialRange>(_onInitialLoad);
    on<LoadMoreBackward>(_onLoadMoreBackward);
    on<LoadMoreForward>(_onLoadMoreForward);
    on<AddNewSlot>(_onAddNewSlot);
    on<UpdateSlot>(_onUpdateSlot);
  }

  final CalendarRepository calendarRepository;

  final _slots = <Slot>[];
  DateTime _loadedFrom = DateTime.now();
  DateTime _loadedTo = DateTime.now();

  Future<void> _onInitialLoad(
    LoadInitialRange e,
    Emitter<SlotState> emit,
  ) async {
    emit(const SlotStateLoading());

    _loadedFrom = e.weekStart.subtract(
      const Duration(days: 14),
    ); // 2 week before
    _loadedTo = e.weekEnd.add(const Duration(days: 14)); // 2 week after

    final result = await calendarRepository.fetchRangeSlots(
      userId: appState.currentUser?.id ?? '',
      from: _loadedFrom,
      to: _loadedTo,
    );

    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }

    _slots.addAll(result.success ?? []);
    emit(
      LoadedRangeSlots(
        slots: List.from(_slots),
        loadedFrom: _loadedFrom,
        loadedTo: _loadedTo,
      ),
    );
  }

  Future<void> _onLoadMoreForward(
    LoadMoreForward e,
    Emitter<SlotState> emit,
  ) async {
    final end = _loadedTo;

    if (end.subtract(const Duration(days: 8)).isAfter(e.currentDisplayedDate)) {
      return;
    }

    _loadedTo = _loadedTo.add(Duration(days: e.days));
    final result = await calendarRepository.fetchRangeSlots(
      userId: appState.currentUser?.id ?? '',
      from: _loadedTo.add(const Duration(days: 1)),
      to: _loadedTo,
    );

    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }

    _slots.addAll(result.success ?? []);

    emit(
      LoadedRangeSlots(
        slots: List.from(_slots),
        loadedFrom: _loadedFrom,
        loadedTo: _loadedTo,
      ),
    );
  }

  Future<void> _onLoadMoreBackward(
    LoadMoreBackward e,
    Emitter<SlotState> emit,
  ) async {
    _loadedFrom = _loadedFrom.subtract(Duration(days: e.days));
    final result = await calendarRepository.fetchRangeSlots(
      userId: appState.currentUser?.id ?? '',
      from: _loadedFrom,
      to: _loadedTo.subtract(const Duration(days: 1)),
    );

    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }

    _slots.insertAll(0, result.success ?? []);

    emit(
      LoadedRangeSlots(
        slots: List.from(_slots),
        loadedFrom: _loadedFrom,
        loadedTo: _loadedTo,
      ),
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

    final slot = e.slot.copyWith(id: result.success);

    _slots.add(slot);
    emit(NewSlotAdded(slot: slot));
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

    _slots
      ..removeWhere((s) => s.id == slot.id)
      ..add(slot);

    emit(SlotUpdated(slot: slot));

    // onda silently save u Firestore
    await calendarRepository.updateSlot(slot, e.userId);
  }
}
