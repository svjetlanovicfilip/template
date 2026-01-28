import 'dart:async';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import '../../../../common/models/result.dart' as app;

import '../../../login/data/models/user_model.dart';

class UserRemoteDatasource {
  UserRemoteDatasource({required this.functions, required this.firebaseAuth});

  FirebaseFunctions functions;
  final FirebaseAuth firebaseAuth;

  /// Kreira employee preko callable funkcije + pošalje reset password email (bez SMTP)
  Future<app.Result<UserModel, Exception>> createEmployee({
    required String name,
    required String lastName,
    required String username,
    required String email,
  }) async {
    try {
      functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final callable = functions.httpsCallable('createEmployee');

      final res = await callable.call(<String, dynamic>{
        'email': email.trim(),
        'name': name.trim(),
        'surname': lastName.trim(),
        'username': username.trim(),
      });

      final data = Map<String, dynamic>.from(res.data as Map);

      // Pošalji reset email (Firebase šalje)
      // await firebaseAuth.sendPasswordResetEmail(email: email.trim());

      return app.Result.success(
        UserModel.fromJson(
          Map<String, dynamic>.from(data['user'] as Map),
          data['uid'],
        ),
      );
    } on FirebaseFunctionsException catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      // e.code: unauthenticated, permission-denied, already-exists, internal...
      return app.Result.failure(Exception('${e.code}: ${e.message ?? ''}'));
    } on FirebaseAuthException catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      // Ako iz nekog razloga reset email faila
      return app.Result.failure(Exception('${e.code}: ${e.message ?? ''}'));
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return app.Result.failure(Exception(e.toString()));
    }
  }

  /// Soft delete employee:
  /// - Cloud Function disable-uje Auth user-a
  /// - Firestore users/{uid} postavlja isActive=false
  Future<app.Result<Map<String, dynamic>, Exception>> deleteEmployee({
    required String employeeUid,
  }) async {
    try {
      functions = FirebaseFunctions.instanceFor(region: 'europe-west1');
      final callable = functions.httpsCallable('deleteEmployee');

      final res = await callable.call(<String, dynamic>{
        'employeeUid': employeeUid.trim(),
      });

      final data = Map<String, dynamic>.from(res.data as Map);
      return app.Result.success(data);
    } on FirebaseFunctionsException catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      // e.code: unauthenticated, permission-denied, not-found, internal...
      return app.Result.failure(Exception('${e.code}: ${e.message ?? ''}'));
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return app.Result.failure(Exception(e.toString()));
    }
  }
}
