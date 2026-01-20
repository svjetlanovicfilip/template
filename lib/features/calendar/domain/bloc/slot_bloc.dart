import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../data/models/slot.dart';
import '../../data/repositories/calendar_repository.dart';

part 'slot_event.dart';
part 'slot_state.dart';

class UserSlotsRange {
  UserSlotsRange({required this.userId, required this.from, required this.to});

  String userId;
  DateTime from;
  DateTime to;
}

class SlotBloc extends Bloc<SlotEvent, SlotState> {
  SlotBloc(this.calendarRepository) : super(const SlotStateInitial()) {
    on<InitListener>(_onInit);
    on<LoadSlots>(_onLoadSlots);
    on<LoadMore>(_onLoadMore);

    on<LoadMoreBackward>(_onLoadMoreBackward);
    on<LoadMoreForward>(_onLoadMoreForward);
    on<UserChanged>(_onUserChanged);
    on<AddNewSlot>(_onAddNewSlot);
    on<UpdateSlot>(_onUpdateSlot);
    on<DeleteSlot>(_onDeleteSlot);
  }

  final CalendarRepository calendarRepository;

  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>>
  _slotsListeners = [];

  final _usersSlots = <String, List<Slot>>{};
  final _usersSlotsRanges = <UserSlotsRange>[];

  void _onLoadMore(LoadMore event, Emitter<SlotState> emit) {
    final userId = appState.currentSelectedUserId ?? '';
    final currentRange = _usersSlotsRanges.firstWhere(
      (e) => e.userId == userId,
    );

    final to = currentRange.to;
    final from = currentRange.from;

    //scroll to right
    if (!to.subtract(const Duration(days: 15)).isAfter(event.date)) {
      final newTo = to.add(const Duration(days: 14));

      currentRange.to = newTo;

      _attachNewSlotListener(userId: userId, from: to, to: newTo);
    }

    //scroll to left
    if (!event.date.isAfter(from.add(const Duration(days: 8)))) {
      final newFrom = from.subtract(const Duration(days: 14));
      currentRange.from = newFrom;

      _attachNewSlotListener(userId: userId, from: newFrom, to: from);
    }
  }

  void _onLoadSlots(LoadSlots event, Emitter<SlotState> emit) {
    emit(const SlotStateInitial());
    final currentRange = _usersSlotsRanges.firstWhere(
      (e) => event.userId == e.userId,
    );

    emit(
      LoadedRangeSlots(
        slots: List.from(_usersSlots[event.userId] ?? []),
        loadedFrom: currentRange.from,
        loadedTo: currentRange.to,
        userId: event.userId,
        changedSlotIds: event.changedSlotIds,
        removedSlotIds: event.removedSlotIds,
      ),
    );
  }

  Future<void> _onInit(_, Emitter<SlotState> emit) async {
    emit(const SlotStateLoading());

    final userId = appState.currentSelectedUserId ?? '';

    final from = DateTime.now().subtract(const Duration(days: 14));
    final to = DateTime.now().add(const Duration(days: 30));

    if (!_usersSlotsRanges.any((e) => e.userId == userId)) {
      _usersSlotsRanges.add(UserSlotsRange(userId: userId, from: from, to: to));
    }

    _attachNewSlotListener(userId: userId, from: from, to: to);
  }

  void _attachNewSlotListener({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) {
    //for every range we need to attach a new listener
    _slotsListeners.add(
      calendarRepository
          .listenForNewChanges(userId: userId, from: from, to: to)
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
                  if (!slot.employeeIds.contains(userId)) {
                    _usersSlots[userId]?.removeWhere((s) => s.id == id);
                    removedSlotIds.add(id);
                    break;
                  }

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

            if (appState.currentSelectedUserId == userId) {
              add(
                LoadSlots(
                  userId: userId,
                  changedSlotIds: changedSlotIds,
                  removedSlotIds: removedSlotIds,
                ),
              );
            }
          }),
    );
  }

  Future<void> _onUserChanged(UserChanged e, Emitter<SlotState> emit) async {
    if (e.userId == appState.currentSelectedUserId) {
      return;
    }

    final currentRange = _usersSlotsRanges.firstWhereOrNull(
      (element) => element.userId == e.userId,
    );

    appState.currentSelectedUserId = e.userId;

    if (currentRange != null) {
      emit(
        LoadedSlotsAfterUserChanged(
          slots: List.from(_usersSlots[e.userId] ?? []),
          loadedFrom: currentRange.from,
          loadedTo: currentRange.to,
          userId: e.userId,
        ),
      );

      if (_usersSlotsRanges.any((element) => element.userId == e.userId)) {
        if (e.currentDisplayedDate.isBefore(currentRange.from)) {
          final desiredFrom = e.currentDisplayedDate.subtract(
            const Duration(days: 14),
          );
          _attachNewSlotListener(
            userId: e.userId,
            from: desiredFrom,
            to: currentRange.from,
          );

          currentRange.from = desiredFrom;
        } else if (e.currentDisplayedDate.isAfter(currentRange.to)) {
          final desiredTo = e.currentDisplayedDate.add(
            const Duration(days: 14),
          );

          _attachNewSlotListener(
            userId: e.userId,
            from: currentRange.to,
            to: desiredTo,
          );

          currentRange.to = desiredTo;
        }
      }
    } else {
      final desiredFrom = e.currentDisplayedDate.subtract(
        const Duration(days: 14),
      );
      final desiredTo = e.currentDisplayedDate.add(const Duration(days: 30));

      _usersSlotsRanges.add(
        UserSlotsRange(userId: e.userId, from: desiredFrom, to: desiredTo),
      );

      _attachNewSlotListener(
        userId: e.userId,
        from: desiredFrom,
        to: desiredTo,
      );
    }
  }

  Future<void> _onLoadMoreForward(
    LoadMoreForward e,
    Emitter<SlotState> emit,
  ) async {
    final userId = appState.currentSelectedUserId ?? '';
    final currentRange = _usersSlotsRanges.firstWhere(
      (e) => e.userId == userId,
    );

    final to = currentRange.to;

    if (to.subtract(const Duration(days: 15)).isAfter(e.currentDisplayedDate)) {
      return;
    }

    final newTo = to.add(Duration(days: e.days));

    currentRange.to = newTo;

    _attachNewSlotListener(userId: userId, from: to, to: newTo);
  }

  Future<void> _onLoadMoreBackward(
    LoadMoreBackward e,
    Emitter<SlotState> emit,
  ) async {
    final userId = appState.currentSelectedUserId ?? '';
    final currentRange = _usersSlotsRanges.firstWhere(
      (e) => e.userId == userId,
    );

    final from = currentRange.from;

    if (e.currentDisplayedDate.isAfter(from.add(const Duration(days: 8)))) {
      return;
    }

    final newFrom = from.subtract(Duration(days: e.days));
    currentRange.from = newFrom;

    _attachNewSlotListener(userId: userId, from: newFrom, to: from);
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

    for (final userId in e.slot.employeeIds) {
      final isOverlapping = await calendarRepository.isSlotOverlapping(
        newStart: e.slot.startDateTime,
        newEnd: e.slot.endDateTime!,
        userId: userId,
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
    }

    final result = await calendarRepository.createSlot(e.slot);
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

    for (final userId in slot.employeeIds) {
      final isOverlapping = await calendarRepository.isSlotOverlapping(
        newStart: slot.startDateTime,
        newEnd: slot.endDateTime!,
        userId: userId,
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
    }

    final result = await calendarRepository.updateSlot(slot);
    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }
  }

  Future<void> _onDeleteSlot(DeleteSlot e, Emitter<SlotState> emit) async {
    final result = await calendarRepository.deleteSlot(e.slotId);
    if (result.isFailure) {
      emit(ErrorLoadingSlots(errorMessage: result.failure?.toString() ?? ''));
      return;
    }
  }

  void clearState() {
    _usersSlots.clear();
    _usersSlotsRanges.clear();
    _slotsListeners.clear();
  }
}
