import '../../../../common/models/result.dart';
import '../models/slot.dart';

abstract class CalendarRepository {
  Future<Result<List<Slot>, Exception>> fetchRangeSlots({
    required String organizationId,
    required String userId,
    required DateTime from,
    required DateTime to,
  });
  Future<Result<String, Exception>> createSlot(Slot slot);
  Future<Result<bool, Exception>> updateSlot(Slot slot);
  // Future<Result<void, Exception>> deleteSlot(String slotId);
  Future<Result<bool, Exception>> isSlotOverlapping(
    DateTime newStart,
    DateTime newEnd, {
    String? excludeSlotId,
  });
}
