import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/service_remote_datasource.dart';
import '../models/service_type.dart';
import 'service_repository.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  ServiceRepositoryImpl({required this.serviceRemoteDatasource});

  final ServiceRemoteDatasource serviceRemoteDatasource;

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChanges(
    String organizationId,
  ) {
    return serviceRemoteDatasource.listenForNewChanges(organizationId);
  }

  @override
  Future<void> createService(ServiceType service, String organizationId) async {
    await serviceRemoteDatasource.createService(service, organizationId);
  }

  @override
  Future<void> deleteService(String serviceId, String organizationId) async {
    await serviceRemoteDatasource.deleteService(serviceId, organizationId);
  }

  @override
  Future<void> updateService(ServiceType service, String organizationId) async {
    await serviceRemoteDatasource.updateService(service, organizationId);
  }
}
