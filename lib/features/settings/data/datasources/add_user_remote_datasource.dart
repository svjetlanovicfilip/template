import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:template/common/models/result.dart' as app;


class AddUserRemoteDatasource {
  AddUserRemoteDatasource({
    required this.functions,
    required this.firebaseAuth,
  });

  FirebaseFunctions functions;
  final FirebaseAuth firebaseAuth;


  /// Kreira employee preko callable funkcije + pošalje reset password email (bez SMTP)
  Future<app.Result<Map<String, dynamic>, Exception>> createEmployee({
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
      await firebaseAuth.sendPasswordResetEmail(email: email.trim());

      return app.Result.success(data);
    } on FirebaseFunctionsException catch (e) {
      // e.code: unauthenticated, permission-denied, already-exists, internal...
      return app.Result.failure(Exception('${e.code}: ${e.message ?? ''}'));
    } on FirebaseAuthException catch (e) {
      // Ako iz nekog razloga reset email faila
      return app.Result.failure(Exception('${e.code}: ${e.message ?? ''}'));
    } catch (e) {
      return app.Result.failure(Exception(e.toString()));
    }
  }
}
