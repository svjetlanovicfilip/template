import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/models/result.dart';
import '../../../../config/style/colors.dart';
import '../models/slot.dart';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Future<Result<QuerySnapshot<Map<String, dynamic>>, Exception>>
  fetchRangeSlots({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      final slotQuerySnapshots =
          await firebaseFirestore
              .collection(usersCollection)
              .doc(userId)
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

  Future<Result<DocumentReference, Exception>> createSlot(
    Slot slot,
    String userId,
  ) async {
    // List<Slot> slots = [];

    // final titles = [
    //   'Sisanje',
    //   'Fade',
    //   'Pramenovi',
    //   'Farbanje',
    //   'Feniranje',
    //   'Mini val',
    //   'Feniranje i sisanje',
    //   'Brijanje',
    //   'Farbanje i brijanje',
    //   'Brijanje i sisanje',
    // ]..shuffle();

    // final startHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17]..shuffle();

    // // GENERATING TEST DATA
    // final random = Random();
    // final now = DateTime.now().add(Duration(days: 2));
    // final currentDay = DateTime(now.year, now.month, now.day);

    // // Generate 10 events on a single day
    // // Prepare a balanced, randomized color cycle for the day
    // final colors = List<Color>.from(AppColors.possibleEventColors)
    //   ..shuffle(random);

    // for (var eventIndex = 0; eventIndex < 10; eventIndex++) {
    //   final startDateTime = DateTime(
    //     currentDay.year,
    //     currentDay.month,
    //     currentDay.day,
    //     startHours[eventIndex],
    //   );
    //   // Duration between 30 and 120 minutes (increments of 15), never > 2h
    //   final endDateTime = startDateTime.add(Duration(minutes: 30));

    //   // final selectedColor = colors[eventIndex % colors.length];
    //   // final colorHex =
    //   //     '0x${(selectedColor as dynamic).value.toRadixString(16).padLeft(8, '0')}';

    //   slots.add(
    //     Slot(
    //       title: titles[eventIndex],
    //       startDateTime: startDateTime,
    //       endDateTime: endDateTime,
    //       color: colors[eventIndex % colors.length].toARGB32().toString(),
    //     ),
    //   );
    // }
    // for (final s in slots) {
    //   await firebaseFirestore
    //       .collection(usersCollection)
    //       .doc(userId)
    //       .collection(slotsCollection)
    //       .add(s.toJson());
    // }

    // throw Exception('test');
    try {
      final result = await firebaseFirestore
          .collection(usersCollection)
          .doc(userId)
          .collection(slotsCollection)
          .add(slot.toJson());

      return Result.success(result);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<bool, Exception>> updateSlot(Slot slot, String userId) async {
    try {
      await firebaseFirestore
          .collection(usersCollection)
          .doc(userId)
          .collection(slotsCollection)
          .doc(slot.id)
          .update(slot.toJson());

      return Result.success(true);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<bool, Exception>> isSlotOverlapping({
    required DateTime newStart,
    required DateTime newEnd,
    required String userId,
    String? excludeSlotId,
  }) async {
    final snap =
        await FirebaseFirestore.instance
            .collection(usersCollection)
            .doc(userId)
            .collection(slotsCollection)
            .where('startDateTime', isLessThan: Timestamp.fromDate(newEnd))
            .where('endDateTime', isGreaterThan: Timestamp.fromDate(newStart))
            .orderBy('startDateTime')
            .get();

    final overlappingOthers = snap.docs.where((d) => d.id != excludeSlotId);
    return Result.success(overlappingOthers.isNotEmpty);
  }
}
