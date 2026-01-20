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

  Future<void> addTestData(String organizationId) async {
    const List<ServiceType> serviceTypes = const [
      ServiceType(title: 'Muško šišanje', price: 20),
      ServiceType(title: 'Žensko šišanje', price: 25),
      ServiceType(title: 'Dječije šišanje', price: 20),
      ServiceType(title: 'Fen frizura – kratka kosa', price: 22),
      ServiceType(title: 'Fen frizura – srednja kosa', price: 25),
      ServiceType(title: 'Fen frizura – duga kosa', price: 30),
      ServiceType(title: 'Pranje kose', price: 20),
      ServiceType(title: 'Peglanje kose', price: 28),
      ServiceType(title: 'Uvijanje kose', price: 28),
      ServiceType(title: 'Svečana frizura', price: 45),

      ServiceType(title: 'Farbanje kose – kratka kosa', price: 35),
      ServiceType(title: 'Farbanje kose – srednja kosa', price: 40),
      ServiceType(title: 'Farbanje kose – duga kosa', price: 50),
      ServiceType(title: 'Pramenovi – kratka kosa', price: 45),
      ServiceType(title: 'Pramenovi – srednja kosa', price: 48),

      ServiceType(title: 'Balayage', price: 50),
      ServiceType(title: 'Ombre', price: 48),
      ServiceType(title: 'Tretman za oštećenu kosu', price: 30),
      ServiceType(title: 'Keratin tretman', price: 50),
      ServiceType(title: 'Botox za kosu', price: 45),

      ServiceType(title: 'Manikir – klasični', price: 20),
      ServiceType(title: 'Manikir – trajni lak', price: 30),
      ServiceType(title: 'Manikir – gel', price: 35),
      ServiceType(title: 'Pedikir – klasični', price: 25),
      ServiceType(title: 'Pedikir – spa', price: 40),

      ServiceType(title: 'Čišćenje lica – osnovno', price: 30),
      ServiceType(title: 'Čišćenje lica – dubinsko', price: 45),
      ServiceType(title: 'Hidratantni tretman lica', price: 35),
      ServiceType(title: 'Anti-age tretman lica', price: 50),
      ServiceType(title: 'Piling lica', price: 25),

      ServiceType(title: 'Depilacija obrva', price: 20),
      ServiceType(title: 'Depilacija nausnica', price: 20),
      ServiceType(title: 'Depilacija nogu – pola', price: 30),
      ServiceType(title: 'Depilacija nogu – cijele', price: 45),
      ServiceType(title: 'Depilacija ruku', price: 25),

      ServiceType(title: 'Oblikovanje obrva', price: 20),
      ServiceType(title: 'Farbanje obrva', price: 22),
      ServiceType(title: 'Farbanje trepavica', price: 22),
      ServiceType(title: 'Lash lift', price: 35),
      ServiceType(title: 'Šminkanje – dnevno', price: 30),
      ServiceType(title: 'Šminkanje – večernje', price: 45),
    ];

    for (final service in serviceTypes) {
      await createService(service, organizationId);
    }
  }
}
