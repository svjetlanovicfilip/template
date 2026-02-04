import '../../../service/data/models/service_type.dart';
import '../../../settings/data/client.dart';

class SlotDetails {
  const SlotDetails({
    required this.startDateTime,
    required this.endDateTime,
    required this.services,
    this.client,
    this.title,
  });

  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<ServiceType> services;
  final Client? client;
  final String? title;
}
