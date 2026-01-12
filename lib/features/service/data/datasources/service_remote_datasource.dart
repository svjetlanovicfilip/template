import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/constants/routes.dart';
import '../models/service_type.dart';

class ServiceRemoteDatasource {
  ServiceRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> listenForNewChanges(
    String organizationId,
  ) {
    return firebaseFirestore
        .collection(organizationsCollection)
        .doc(organizationId)
        .collection(servicesCollection)
        .snapshots();
  }

  Future<void> createService(ServiceType service, String organizationId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(servicesCollection)
          .add(service.toJson());
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateService(ServiceType service, String organizationId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(servicesCollection)
          .doc(service.id)
          .update(service.toJson());
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteService(String serviceId, String organizationId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(servicesCollection)
          .doc(serviceId)
          .delete();
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
