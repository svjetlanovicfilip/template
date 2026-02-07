import '../../../service/data/models/service_type.dart';
import '../../../settings/data/client.dart';

class SlotDetails {
  const SlotDetails({
    required this.startDateTime,
    required this.endDateTime,
    required this.services,
    required this.earnings,
    this.client,
    this.title,
    this.employeeIds = const [],
  });

  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<ServiceType> services;
  final Client? client;
  final String? title;
  final List<String> employeeIds;
  final double earnings;
}
