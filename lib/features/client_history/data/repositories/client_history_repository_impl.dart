import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/models/result.dart';
import '../datasources/client_history_remote_datasource.dart';
import 'client_history_repository.dart';

class ClientHistoryRepositoryImpl implements ClientHistoryRepository {
  ClientHistoryRepositoryImpl({required this.clientHistoryRemoteDatasource});

  final ClientHistoryRemoteDatasource clientHistoryRemoteDatasource;

  @override
  Future<Result<List<QueryDocumentSnapshot<Map<String, dynamic>>>, Exception>>
  getClientSlots(
    String clientId, {
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 5,
  }) async {
    return clientHistoryRemoteDatasource.getClientSlots(
      clientId,
      lastDocument: lastDocument,
      limit: limit,
    );
  }
}
