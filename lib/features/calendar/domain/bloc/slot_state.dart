part of 'slot_bloc.dart';

sealed class SlotState extends Equatable {
  const SlotState();

  @override
  List<Object?> get props => [];
}

class SlotStateInitial extends SlotState {
  const SlotStateInitial();

  @override
  List<Object?> get props => [];
}

class SlotStateLoading extends SlotState {
  const SlotStateLoading();

  @override
  List<Object?> get props => [];
}

class LoadedRangeSlots extends SlotState {
  const LoadedRangeSlots({
    required this.slots,
    required this.loadedFrom,
    required this.loadedTo,
    required this.userId,
    required this.changedSlotIds,
    required this.removedSlotIds,
  });

  final List<Slot> slots;
  final DateTime loadedFrom;
  final DateTime loadedTo;
  final String userId;
  final List<String> changedSlotIds;
  final List<String> removedSlotIds;

  @override
  List<Object?> get props => [slots, loadedFrom, loadedTo, userId];
}

class ErrorLoadingSlots extends SlotState {
  const ErrorLoadingSlots({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class LoadedSlotsAfterUserChanged extends SlotState {
  const LoadedSlotsAfterUserChanged({
    required this.slots,
    required this.userId,
    required this.loadedFrom,
    required this.loadedTo,
  });

  final List<Slot> slots;
  final String userId;
  final DateTime loadedFrom;
  final DateTime loadedTo;

  @override
  List<Object?> get props => [slots, userId, loadedFrom, loadedTo];
}
