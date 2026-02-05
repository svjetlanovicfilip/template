import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../data/models/slot.dart';
import '../../data/repositories/calendar_repository.dart';

part 'employees_calendar_event.dart';
part 'employees_calendar_state.dart';

class EmployeesCalendarBloc
    extends Bloc<EmployeesCalendarEvent, EmployeesCalendarState> {
  EmployeesCalendarBloc({required this.calendarRepository})
    : super(EmployeesCalendarInitial()) {
    on<EmployeesCalendarDateSet>(_onDateSet);
    on<EmployeesCalendarExtendForward>(_onExtendForward);
    on<EmployeesCalendarExtendBackward>(_onExtendBackward);
    on<_EmployeesCalendarSnapshotArrived>(_onSnapshotArrived);
  }

  final CalendarRepository calendarRepository;
  final List<StreamSubscription<QuerySnapshot<Map<String, dynamic>>>> _subs =
      [];

  final List<Slot> _slots = [];
  DateTime? _loadedStart;
  DateTime? _loadedEnd;
  bool get _hasLoadedWindow => _loadedStart != null && _loadedEnd != null;

  Future<void> _onDateSet(
    EmployeesCalendarDateSet event,
    Emitter<EmployeesCalendarState> emit,
  ) async {
    // Ako nikad nismo učitali prozor, inicijalizuj ga 3-dnevnim prozorom oko datuma.
    // Ako već imamo prozor, NE otkazuj postojeće subove; samo provjeri treba li proširenje
    // (npr. skok na dalek datum) i u tom slučaju resetuj i otvori novi prozor.
    final targetStart = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    ).subtract(const Duration(days: 1));
    final targetEnd = DateTime(
      event.date.year,
      event.date.month,
      event.date.day,
    ).add(const Duration(days: 2)); // inclusive end of next day

    if (_loadedStart == null || _loadedEnd == null) {
      emit(EmployeesCalendarLoading());
      _subscribeWindow(targetStart, targetEnd);
      return;
    }

    final currentSpan = _loadedEnd!.difference(_loadedStart!).inDays;
    // Ako je novi raspon daleko izvan postojećeg (npr. skok preko više dana),
    // resetuj prozor i subove (hard reset).
    final farJump =
        event.date.isAfter(_loadedEnd!.add(Duration(days: currentSpan))) ||
        event.date.isBefore(
          _loadedStart!.subtract(Duration(days: currentSpan)),
        );
    if (farJump) {
      for (final s in _subs) {
        await s.cancel();
      }
      _subs.clear();
      _slots.clear();
      _loadedStart = null;
      _loadedEnd = null;
      emit(EmployeesCalendarLoading());
      _subscribeWindow(targetStart, targetEnd);
      return;
    }

    // U suprotnom, samo osiguraj da imamo 3‑dnevni prozor oko nove tačke.
    // Ako treba, proširi naprijed ili nazad bez otkazivanja postojećih subova.
    if (targetStart.isBefore(_loadedStart!)) {
      _subscribeWindow(targetStart, _loadedStart!);
    }
    if (targetEnd.isAfter(_loadedEnd!)) {
      _subscribeWindow(_loadedEnd!, targetEnd);
    }
  }

  void _subscribeWindow(DateTime from, DateTime to) {
    // Merge windows
    if (_loadedStart == null || from.isBefore(_loadedStart!)) {
      _loadedStart = from;
    }
    if (_loadedEnd == null || to.isAfter(_loadedEnd!)) {
      _loadedEnd = to;
    }
    final sub = calendarRepository
        .listenForNewChangesByDateRange(from: from, to: to)
        .listen((snapshot) {
          add(_EmployeesCalendarSnapshotArrived(snapshot: snapshot));
        });
    _subs.add(sub);
  }

  Future<void> _onExtendForward(
    EmployeesCalendarExtendForward event,
    Emitter<EmployeesCalendarState> emit,
  ) async {
    // extend only if needed
    final anchor = DateTime(
      event.anchor.year,
      event.anchor.month,
      event.anchor.day,
    );
    final needMore =
        !_hasLoadedWindow ||
        anchor.isAfter(_loadedEnd!.subtract(const Duration(days: 1)));
    if (!needMore) return;
    final from = (_loadedEnd ?? anchor).add(Duration.zero);
    final to = from.add(Duration(days: event.days));
    _subscribeWindow(from, to);
  }

  Future<void> _onExtendBackward(
    EmployeesCalendarExtendBackward event,
    Emitter<EmployeesCalendarState> emit,
  ) async {
    final anchor = DateTime(
      event.anchor.year,
      event.anchor.month,
      event.anchor.day,
    );
    final needMore =
        !_hasLoadedWindow ||
        anchor.isBefore(_loadedStart!.add(const Duration(days: 1)));
    if (!needMore) return;
    final to = _loadedStart ?? anchor;
    final from = to.subtract(Duration(days: event.days));
    _subscribeWindow(from, to);
  }

  void _onSnapshotArrived(
    _EmployeesCalendarSnapshotArrived event,
    Emitter<EmployeesCalendarState> emit,
  ) {
    for (final change in event.snapshot.docChanges) {
      final slot = Slot.fromJson(change.doc.data() ?? {}, change.doc.id);
      switch (change.type) {
        case DocumentChangeType.added:
        case DocumentChangeType.modified:
          final idx = _slots.indexWhere((s) => s.id == slot.id);
          if (idx >= 0) {
            _slots[idx] = slot;
          } else {
            _slots.add(slot);
          }
          break;
        case DocumentChangeType.removed:
          _slots.removeWhere((s) => s.id == slot.id);
          break;
      }
    }
    emit(EmployeesCalendarLoaded(slots: List.unmodifiable(_slots)));
  }

  @override
  Future<void> close() async {
    for (final s in _subs) {
      await s.cancel();
    }
    return super.close();
  }
}
