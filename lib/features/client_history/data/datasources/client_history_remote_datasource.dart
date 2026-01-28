import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/models/result.dart';

class ClientHistoryRemoteDatasource {
  ClientHistoryRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Future<Result<List<QueryDocumentSnapshot<Map<String, dynamic>>>, Exception>>
  getClientSlots(
    String clientId, {
    required int limit,
    DocumentSnapshot<Map<String, dynamic>>? lastDocument,
  }) async {
    try {
      var query = firebaseFirestore
          .collection(organizationsCollection)
          .doc(appState.organizationId)
          .collection(slotsCollection)
          .where('clientId', isEqualTo: clientId)
          .orderBy('startDateTime', descending: true)
          .orderBy(FieldPath.documentId, descending: true)
          .limit(limit);

      if (lastDocument != null) {
        query = query.startAfterDocument(lastDocument);
      }

      final snapshot = await query.get();

      return Result.success(snapshot.docs);
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(e);
    }
  }
}
