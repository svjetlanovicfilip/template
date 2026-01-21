import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../common/models/result.dart';

// ignore: one_member_abstracts
abstract class ClientHistoryRepository {
  Future<Result<List<QueryDocumentSnapshot<Map<String, dynamic>>>, Exception>>
  getClientSlots(
    String clientId, {
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
    int limit = 10,
  });
}
