import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/models/result.dart';
import '../../../../config/style/colors.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../../settings/domain/bloc/clients_bloc.dart';
import '../../../users/domain/bloc/users_bloc.dart';
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

  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChangesByDateRange({
    required DateTime from,
    required DateTime to,
  }) =>
      firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .where('startDateTime', isLessThanOrEqualTo: Timestamp.fromDate(to))
          .where(
            'endDateTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(from),
          )
          .orderBy('startDateTime')
          .snapshots();

  Future<Result<DocumentReference, Exception>> createSlot(Slot slot) async {
    try {
      final result = await firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .add(slot.toJson());

      return Result.success(result);
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
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
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
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
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
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

  final services = getIt<ServiceBloc>().state.services;
  final employees = getIt<UsersBloc>().users;
  final clients = getIt<ClientsBloc>().clients;

  final startHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17]..shuffle();

  final durations = [30, 35, 40, 45, 60]..shuffle();
  final now = DateTime.now();

  final random = Random();

  final days = <DateTime>[];

  for (var i = 0; i < 20; i++) {
    final day = now.add(Duration(days: random.nextInt(20)));
    if (!days.contains(day)) {
      days.add(day);
    }
  }

  final colors = List<Color>.from(AppColors.possibleEventColors);

  for (final day in days) {
    services.shuffle();
    colors.shuffle();
    startHours.shuffle();
    clients.shuffle();
    employees.shuffle();

    for (var eventIndex = 0; eventIndex < 10; eventIndex++) {
      final randomService = [services[random.nextInt(services.length)]];
      final randomClient = clients[random.nextInt(clients.length)];
      final randomEmployee = employees[random.nextInt(employees.length)];

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
          title: 'Termin ${eventIndex + 1}',
          serviceIds: randomService.map((e) => e.id ?? '').toList(),
          startDateTime: startDateTime,
          endDateTime: endDateTime,
          color: colors[eventIndex % colors.length].toARGB32().toString(),
          employeeIds: [randomEmployee.id!],
          clientId: randomClient.id!,
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
