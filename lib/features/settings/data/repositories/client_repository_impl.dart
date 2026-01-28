import '../../../../common/models/result.dart';
import '../client.dart';
import '../datasources/client_remote_datasource.dart';
import 'client_repository.dart';

class ClientRepositoryImpl implements ClientRepository {
  ClientRepositoryImpl({required this.clientRemoteDatasource});

  final ClientRemoteDatasource clientRemoteDatasource;

  @override
  Future<Result<List<Client>, Exception>> fetchClients({
    required String organizationId,
  }) async {
    try {
      final qs = await clientRemoteDatasource.fetchClients(organizationId);

      final clients =
          qs.docs.map((doc) => Client.fromJson(doc.data(), doc.id)).toList();

      return Result.success(clients);
    } on Exception catch (e) {
      return Result.failure(Exception(e.toString()));
    }
  }

  @override
  Future<String> createClient(Client client, String organizationId) async {
    final docRef = await clientRemoteDatasource.createClient(
      client,
      organizationId,
    );
    return docRef.id;
  }

  @override
  Future<void> deleteClient(String serviceId, String organizationId) async {
    await clientRemoteDatasource.deleteClient(serviceId, organizationId);
  }

  @override
  Future<void> updateClient(Client client, String organizationId) async {
    await clientRemoteDatasource.updateClient(client, organizationId);
  }
}
