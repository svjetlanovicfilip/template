import '../../../../common/models/result.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../models/slot.dart';
import 'calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({required this.calendarRemoteDatasource});

  final CalendarRemoteDatasource calendarRemoteDatasource;

  @override
  Future<Result<List<Slot>, Exception>> fetchRangeSlots({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await calendarRemoteDatasource.fetchRangeSlots(
      userId: userId,
      from: from,
      to: to,
    );

    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(
      result.success?.docs
              .map((doc) => Slot.fromJson(doc.data(), doc.id))
              .toList() ??
          [],
    );
  }

  @override
  Future<Result<String, Exception>> createSlot(Slot slot, String userId) async {
    final result = await calendarRemoteDatasource.createSlot(slot, userId);
    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(result.success?.id ?? '');
  }

  @override
  Future<Result<bool, Exception>> updateSlot(Slot slot, String userId) async {
    final result = await calendarRemoteDatasource.updateSlot(slot, userId);
    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(result.success ?? false);
  }

  @override
  Future<Result<bool, Exception>> isSlotOverlapping({
    required DateTime newStart,
    required DateTime newEnd,
    required String userId,
    String? excludeSlotId,
  }) async {
    final result = await calendarRemoteDatasource.isSlotOverlapping(
      newStart: newStart,
      newEnd: newEnd,
      userId: userId,
      excludeSlotId: excludeSlotId,
    );
    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(result.success ?? false);
  }
}
