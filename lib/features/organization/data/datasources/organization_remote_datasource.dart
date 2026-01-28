import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/models/result.dart';

class OrganizationRemoteDatasource {
  OrganizationRemoteDatasource({required this.firebaseFirestore});

  final FirebaseFirestore firebaseFirestore;

  Future<Result<DocumentSnapshot, Exception>> getUserOrganization(
    String organizationId,
  ) async {
    try {
      final organizationSnapshot =
          await firebaseFirestore
              .collection(organizationsCollection)
              .doc(organizationId)
              .get();

      if (!organizationSnapshot.exists) {
        return Result.failure(Exception('Organization not found'));
      }

      return Result.success(organizationSnapshot);
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(Exception(e));
    }
  }

  Future<Result<QuerySnapshot<Map<String, dynamic>>, Exception>>
  getOrganizationUsers(String organizationId) async {
    try {
      final usersSnapshot =
          await firebaseFirestore
              .collection(usersCollection)
              .where('orgId', isEqualTo: organizationId)
              .get();

      return Result.success(usersSnapshot);
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(Exception(e));
    }
  }
}
