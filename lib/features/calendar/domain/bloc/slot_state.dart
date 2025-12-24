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
  });

  final List<Slot> slots;
  final DateTime loadedFrom;
  final DateTime loadedTo;

  @override
  List<Object?> get props => [slots, loadedFrom, loadedTo];
}

class ErrorLoadingSlots extends SlotState {
  const ErrorLoadingSlots({required this.errorMessage});

  final String errorMessage;

  @override
  List<Object?> get props => [errorMessage];
}

class NewSlotAdded extends SlotState {
  const NewSlotAdded({required this.slot});

  final Slot slot;

  @override
  List<Object?> get props => [slot];
}

class SlotUpdated extends SlotState {
  const SlotUpdated({required this.slot});

  final Slot slot;

  @override
  List<Object?> get props => [slot];
}

class SlotDeleted extends SlotState {
  const SlotDeleted({required this.slotId});

  final String slotId;

  @override
  List<Object?> get props => [slotId];
}
// class SlotState extends Equatable {
//   const SlotState({
//     required this.slots,
//     required this.loadedFrom,
//     required this.loadedTo,
//     required this.organizationId,
//     required this.userId,
//     this.errorMessage,
//     this.isEdited = false,
//   });

//   SlotState.initial()
//     : slots = [],
//       loadedFrom = DateTime.now(),
//       loadedTo = DateTime.now(),
//       organizationId = '',
//       userId = '',
//       errorMessage = null,
//       isEdited = false;

//   final List<Slot> slots;
//   final DateTime loadedFrom;
//   final DateTime loadedTo;
//   final String organizationId;
//   final String userId;
//   final String? errorMessage;
//   final bool isEdited;

//   SlotState copyWith({
//     List<Slot>? slots,
//     DateTime? loadedFrom,
//     DateTime? loadedTo,
//     String? organizationId,
//     String? userId,
//     String? errorMessage,
//     bool isEdited = false,
//   }) {
//     return SlotState(
//       slots: slots ?? this.slots,
//       loadedFrom: loadedFrom ?? this.loadedFrom,
//       loadedTo: loadedTo ?? this.loadedTo,
//       organizationId: organizationId ?? this.organizationId,
//       userId: userId ?? this.userId,
//       errorMessage: errorMessage,
//       isEdited: isEdited,
//     );
//   }

//   @override
//   List<Object?> get props => [
//     slots,
//     loadedFrom,
//     loadedTo,
//     organizationId,
//     userId,
//     errorMessage,
//   ];
// }
