import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/models/result.dart';
import '../models/slot.dart';

const String organizationsCollection = 'organizations';
const String usersCollection = 'users';
const String slotsCollection = 'slots';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Future<Result<QuerySnapshot<Map<String, dynamic>>, Exception>>
  fetchRangeSlots({
    required String organizationId,
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final slotQuerySnapshots =
          await firebaseFirestore
              .collection(organizationsCollection)
              .doc('HQXD4zXjkrzrNK1SCYJq')
              .collection(usersCollection)
              .doc('mdxSNtPbH5tRFtbfU37o')
              .collection(slotsCollection)
              .where(
                'startDateTime',
                isLessThanOrEqualTo: Timestamp.fromDate(to),
              )
              .where(
                'endDateTime',
                isGreaterThanOrEqualTo: Timestamp.fromDate(from),
              )
              .orderBy('startDateTime')
              .get();

      return Result.success(slotQuerySnapshots);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<DocumentReference, Exception>> createSlot(Slot slot) async {
    // List<Slot> slots = [];

    //GENERATING TEST DATA
    // final random = Random(42);
    // final now = DateTime.now().add(Duration(days: 1));
    // final currentDay = DateTime(now.year, now.month, now.day);

    // // Generate 10 events on a single day
    // // Prepare a balanced, randomized color cycle for the day
    // final colors = List<Color>.from(AppColors.possibleEventColors)
    //   ..shuffle(random);

    // for (var eventIndex = 0; eventIndex < 10; eventIndex++) {
    //   final startHour = 8 + eventIndex; // 08:00 .. 17:00
    //   final startMinute = random.nextBool() ? 0 : 30; // :00 or :30
    //   final startDateTime = DateTime(
    //     currentDay.year,
    //     currentDay.month,
    //     currentDay.day,
    //     startHour,
    //     startMinute,
    //   );
    //   // Duration between 30 and 120 minutes (increments of 15), never > 2h
    //   final durationMinutes = (2 + random.nextInt(7)) * 15; // 30..120
    //   final endDateTime = startDateTime.add(Duration(minutes: durationMinutes));

    //   // final selectedColor = colors[eventIndex % colors.length];
    //   // final colorHex =
    //   //     '0x${(selectedColor as dynamic).value.toRadixString(16).padLeft(8, '0')}';

    //   slots.add(
    //     Slot(
    //       title: 'Slot ${eventIndex + 1}',
    //       startDateTime: startDateTime,
    //       endDateTime: endDateTime,
    //       color: colors[eventIndex % colors.length].toARGB32().toString(),
    //     ),
    //   );
    // }
    // for (var s in slots) {
    //   await firebaseFirestore
    //       .collection(organizationsCollection)
    //       .doc('HQXD4zXjkrzrNK1SCYJq')
    //       .collection(usersCollection)
    //       .doc('mdxSNtPbH5tRFtbfU37o')
    //       .collection(slotsCollection)
    //       .add(s.toJson());
    // }

    // throw Exception('test');
    try {
      final result = await firebaseFirestore
          .collection(organizationsCollection)
          .doc('HQXD4zXjkrzrNK1SCYJq')
          .collection(usersCollection)
          .doc('mdxSNtPbH5tRFtbfU37o')
          .collection(slotsCollection)
          .add(slot.toJson());

      return Result.success(result);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<bool, Exception>> updateSlot(Slot slot) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc('HQXD4zXjkrzrNK1SCYJq')
          .collection(usersCollection)
          .doc('mdxSNtPbH5tRFtbfU37o')
          .collection(slotsCollection)
          .doc(slot.id)
          .update(slot.toJson());

      return Result.success(true);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<bool, Exception>> isSlotOverlapping(
    DateTime newStart,
    DateTime newEnd, {
    String? excludeSlotId,
  }) async {
    final snap =
        await FirebaseFirestore.instance
            .collection(organizationsCollection)
            .doc('HQXD4zXjkrzrNK1SCYJq')
            .collection(usersCollection)
            .doc('mdxSNtPbH5tRFtbfU37o')
            .collection(slotsCollection)
            .where('startDateTime', isLessThan: Timestamp.fromDate(newEnd))
            .where('endDateTime', isGreaterThan: Timestamp.fromDate(newStart))
            .orderBy('startDateTime')
            .get();

    final overlappingOthers = snap.docs.where((d) => d.id != excludeSlotId);
    return Result.success(overlappingOthers.isNotEmpty);
  }
}
