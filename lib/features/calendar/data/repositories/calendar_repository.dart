import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/models/result.dart';
import '../models/slot.dart';

abstract class CalendarRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChanges({
    required String userId,
    required DateTime from,
    required DateTime to,
  });
  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChangesByDateRange({
    required DateTime from,
    required DateTime to,
  });
  Future<Result<String, Exception>> createSlot(Slot slot);
  Future<Result<bool, Exception>> updateSlot(Slot slot);
  Future<Result<bool, Exception>> deleteSlot(String slotId);
  Future<Result<bool, Exception>> isSlotOverlapping({
    required DateTime newStart,
    required DateTime newEnd,
    required String userId,
    String? excludeSlotId,
  });
}
