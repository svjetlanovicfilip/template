import 'package:cloud_firestore/cloud_firestore.dart';

class ClientSlot {
  ClientSlot({
    required this.clientId,
    required this.startDateTime,
    required this.endDateTime,
    required this.serviceIds,
    required this.employeeIds,
    this.title,
  });

  factory ClientSlot.fromJson(Map<String, dynamic> json) {
    return ClientSlot(
      clientId: json['clientId'],
      startDateTime: (json['startDateTime'] as Timestamp).toDate(),
      endDateTime: (json['endDateTime'] as Timestamp).toDate(),
      serviceIds:
          (json['serviceIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      employeeIds:
          (json['employeeIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      title: json['title'],
    );
  }

  final String clientId;
  final DateTime startDateTime;
  final DateTime endDateTime;
  final List<String> serviceIds;
  final List<String> employeeIds;
  final String? title;
}
