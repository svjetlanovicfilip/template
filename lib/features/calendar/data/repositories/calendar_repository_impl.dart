import '../../../../common/models/result.dart';
import '../datasources/calendar_remote_datasource.dart';
import '../models/slot.dart';
import 'calendar_repository.dart';

class CalendarRepositoryImpl implements CalendarRepository {
  CalendarRepositoryImpl({required this.calendarRemoteDatasource});

  final CalendarRemoteDatasource calendarRemoteDatasource;

  @override
  Future<Result<List<Slot>, Exception>> fetchRangeSlots({
    required String organizationId,
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final result = await calendarRemoteDatasource.fetchRangeSlots(
      organizationId: organizationId,
      userId: userId,
      from: from,
      to: to,
    );

    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(
      result.success?.docs.map((doc) => Slot.fromJson(doc.data())).toList() ??
          [],
    );
  }

  @override
  Future<Result<String, Exception>> createSlot(Slot slot) async {
    final result = await calendarRemoteDatasource.createSlot(slot);
    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(result.success?.id ?? '');
  }

  @override
  Future<Result<bool, Exception>> isSlotOverlapping(
    DateTime newStart,
    DateTime newEnd,
  ) async {
    final result = await calendarRemoteDatasource.isSlotOverlapping(
      newStart,
      newEnd,
    );
    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(result.success ?? false);
  }
}
