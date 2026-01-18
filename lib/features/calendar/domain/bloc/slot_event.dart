part of 'slot_bloc.dart';

sealed class SlotEvent {
  const SlotEvent();
}

class InitListener extends SlotEvent {}

class LoadSlots extends SlotEvent {
  const LoadSlots({
    required this.userId,
    required this.changedSlotIds,
    required this.removedSlotIds,
  });
  final String userId;
  final List<String> changedSlotIds;
  final List<String> removedSlotIds;
}

class LoadMoreForward extends SlotEvent {
  const LoadMoreForward({required this.currentDisplayedDate, this.days = 14});
  final int days;
  final DateTime currentDisplayedDate;
}

class LoadMoreBackward extends SlotEvent {
  const LoadMoreBackward({required this.currentDisplayedDate, this.days = 14});
  final DateTime currentDisplayedDate;
  final int days;
}

class JumpToDate extends SlotEvent {
  const JumpToDate({required this.date});
  final DateTime date;
}

class LoadMore extends SlotEvent {
  const LoadMore({required this.date});
  final DateTime date;
}

class UserChanged extends SlotEvent {
  const UserChanged({required this.userId, required this.currentDisplayedDate});
  final String userId;
  final DateTime currentDisplayedDate;
}

class AddNewSlot extends SlotEvent {
  const AddNewSlot(this.slot);
  final Slot slot;
}

class UpdateSlot extends SlotEvent {
  const UpdateSlot(this.slot);
  final Slot slot;
}

class DeleteSlot extends SlotEvent {
  const DeleteSlot(this.slotId);
  final String slotId;
}
