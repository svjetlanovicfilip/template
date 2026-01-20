import '../../../../common/models/result.dart';
import '../client.dart';

abstract class ClientRepository {
   Future<Result<List<Client>, Exception>> fetchClients({
    required String organizationId,
  });

  Future<String> createClient(Client client, String organizationId);
  Future<void> updateClient(Client client, String organizationId);
  Future<void> deleteClient(String clientId, String organizationId);
}
