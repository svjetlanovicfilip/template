part of 'slot_bloc.dart';

sealed class SlotEvent {
  const SlotEvent();
}

class LoadInitialRange extends SlotEvent {
  const LoadInitialRange(this.weekStart, this.weekEnd);
  final DateTime weekStart;
  final DateTime weekEnd;
}

class LoadMoreForward extends SlotEvent {
  const LoadMoreForward({required this.currentDisplayedDate, this.days = 14});
  final int days;
  final DateTime currentDisplayedDate;
}

class LoadMoreBackward extends SlotEvent {
  const LoadMoreBackward({this.days = 14});
  final int days;
}

class AddNewSlot extends SlotEvent {
  const AddNewSlot(this.slot);
  final Slot slot;
}
