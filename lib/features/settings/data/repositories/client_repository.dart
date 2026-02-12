import 'package:cloud_firestore/cloud_firestore.dart';

import '../client.dart';

abstract class ClientRepository {
  Stream<QuerySnapshot<Map<String, dynamic>>> fetchClients({
    required String organizationId,
  });

  Future<String> createClient(Client client, String organizationId);
  Future<void> updateClient(Client client, String organizationId);
  Future<void> deleteClient(String clientId, String organizationId);
}
