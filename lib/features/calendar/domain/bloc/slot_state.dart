part of 'slot_bloc.dart';

class SlotState extends Equatable {
  const SlotState({
    required this.slots,
    required this.loadedFrom,
    required this.loadedTo,
    required this.organizationId,
    required this.userId,
    this.errorMessage,
  });

  SlotState.initial()
    : slots = [],
      loadedFrom = DateTime.now(),
      loadedTo = DateTime.now(),
      organizationId = '',
      userId = '',
      errorMessage = null;

  final List<Slot> slots;
  final DateTime loadedFrom;
  final DateTime loadedTo;
  final String organizationId;
  final String userId;
  final String? errorMessage;

  SlotState copyWith({
    List<Slot>? slots,
    DateTime? loadedFrom,
    DateTime? loadedTo,
    String? organizationId,
    String? userId,
    String? errorMessage,
  }) {
    return SlotState(
      slots: slots ?? this.slots,
      loadedFrom: loadedFrom ?? this.loadedFrom,
      loadedTo: loadedTo ?? this.loadedTo,
      organizationId: organizationId ?? this.organizationId,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    slots,
    loadedFrom,
    loadedTo,
    organizationId,
    userId,
    errorMessage,
  ];
}
