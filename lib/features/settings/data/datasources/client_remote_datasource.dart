import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/constants/routes.dart';
import '../client.dart';

class ClientRemoteDatasource {
  ClientRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Future<QuerySnapshot<Map<String, dynamic>>> fetchClients(
    String organizationId,
  ) async {
    try {
      return await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(clientsCollection)
          .orderBy('createdAt', descending: true)
          .get();
    } on FirebaseException catch (e) {
      throw Exception(e.message ?? 'Firestore error');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  Future<DocumentReference<Map<String, dynamic>>> createClient(
    Client client,
    String organizationId,
  ) async {
    final data = client.toJson();
    data['createdAt'] = FieldValue.serverTimestamp();

    return firebaseFirestore
        .collection(organizationsCollection)
        .doc(organizationId)
        .collection(clientsCollection)
        .add(data);
  }

  Future<void> updateClient(Client client, String organizationId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(clientsCollection)
          .doc(client.id)
          .update(client.toJson());
    } on Exception catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteClient(String clientId, String organizationId) async {
    try {
      await firebaseFirestore
          .collection(organizationsCollection)
          .doc(organizationId)
          .collection(clientsCollection)
          .doc(clientId)
          .delete();
    } on Exception catch (e) {
      throw Exception(e);
    }
  }
}
