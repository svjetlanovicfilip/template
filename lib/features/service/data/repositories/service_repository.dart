import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/service_type.dart';

abstract class ServiceRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChanges(
    String organizationId,
  );
  Future<void> createService(ServiceType service, String organizationId);
  Future<void> updateService(ServiceType service, String organizationId);
  Future<void> deleteService(String serviceId, String organizationId);
}
