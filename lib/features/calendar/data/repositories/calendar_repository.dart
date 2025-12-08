import '../../../../common/models/result.dart';
import '../models/slot.dart';

abstract class CalendarRepository {
  Future<Result<List<Slot>, Exception>> fetchRangeSlots({
    required String organizationId,
    required String userId,
    required DateTime from,
    required DateTime to,
  });
  Future<Result<void, Exception>> createSlot(Slot slot);
  // Future<Result<void, Exception>> updateSlot(Slot slot);
  // Future<Result<void, Exception>> deleteSlot(String slotId);
  Future<Result<bool, Exception>> isSlotOverlapping(
    DateTime newStart,
    DateTime newEnd,
  );
}
