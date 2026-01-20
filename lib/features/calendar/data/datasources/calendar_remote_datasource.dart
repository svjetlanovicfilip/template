import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/models/result.dart';
import '../../../../config/style/colors.dart';
import '../models/slot.dart';

class CalendarRemoteDatasource {
  CalendarRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChanges({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) =>
      firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .where('employeeIds', arrayContains: userId)
          .where('startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .where(
            'endDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from),
          )
          .orderBy('startDateTime')
          .snapshots();

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

  Future<Result<DocumentReference, Exception>> createSlot(Slot slot) async {
    try {
      final result = await firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
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
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .doc(slot.id)
          .update(slot.toJson());

      return Result.success(true);
    } on Exception catch (e) {
      return Result.failure(Exception(e));
    }
  }

  Future<Result<bool, Exception>> deleteSlot(String slotId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .doc(slotId)
          .delete();

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
            .collection(organizationsCollection)
            .doc(appState.organizationId)
            .collection(slotsCollection)
            .where('employeeIds', arrayContains: userId)
            .where('startDateTime', isLessThan: Timestamp.fromDate(newEnd))
            .where('endDateTime', isGreaterThan: Timestamp.fromDate(newStart))
            .orderBy('startDateTime')
            .get();

    final overlappingOthers = snap.docs.where((d) => d.id != excludeSlotId);
    return Result.success(overlappingOthers.isNotEmpty);
  }
}

Future<void> generateTestData() async {
  final slots = <Slot>[];

  final titles = [
    'Sisanje',
    'Fade',
    'Pramenovi',
    'Farbanje',
    'Feniranje',
    'Mini val',
    'Feniranje i sisanje',
    'Brijanje',
    'Farbanje i brijanje',
    'Brijanje i sisanje',
  ];

  final startHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17]..shuffle();

  final durations = [30, 35, 40, 45, 60]..shuffle();
  final now = DateTime.now();

  final random = Random();

  final days = <DateTime>[];

  for (var i = 0; i < 50; i++) {
    final day = now.add(Duration(days: random.nextInt(150)));
    if (!days.contains(day)) {
      days.add(day);
    }
  }

  final colors = List<Color>.from(AppColors.possibleEventColors);

  for (final day in days) {
    titles.shuffle();
    colors.shuffle();
    startHours.shuffle();

    for (var eventIndex = 0; eventIndex < 10; eventIndex++) {
      final startDateTime = DateTime(
        day.year,
        day.month,
        day.day,
        startHours[eventIndex],
      );
      final endDateTime = startDateTime.add(
        Duration(minutes: durations[random.nextInt(durations.length)]),
      );

      slots.add(
        Slot(
          title: titles[eventIndex],
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          color: colors[eventIndex % colors.length].toARGB32().toString(),
        ),
      );
    }
  }

  for (final s in slots) {
    await FirebaseFirestore.instance
        .collection(organizationsCollection)
        .doc(appState.organizationId)
        .collection(slotsCollection)
        .add(s.toJson());
  }

  print('Test data generated');
}

Future<void> example() async {
  final snap =
      await FirebaseFirestore.instance
          .collection('slotsExample')
          .where('userId', arrayContains: 'fsdfdsdfs')
          .where(
            'startDateTime',
            isLessThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .where(
            'endDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()),
          )
          .orderBy('startDateTime')
          .get();

  print(snap.docs.length);
}
