import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/models/result.dart';
import '../models/authentication_exceptions.dart';

class AuthenticationRemoteDatasource {
  AuthenticationRemoteDatasource({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  Result<User, AuthenticationException> isUserAuthenticated() {
    try {
      final user = firebaseAuth.currentUser;
      if (user == null) {
        return Result.failure(
          const AuthenticationException(message: 'User not authenticated'),
        );
      }

      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      return Result.failure(
        AuthenticationException(message: e.message ?? 'Unknown error'),
      );
    } on Exception catch (e) {
      return Result.failure(AuthenticationException(message: e.toString()));
    }
  }

  Future<Result<DocumentSnapshot, AuthenticationException>> getUserProfile(
    String userId,
  ) async {
    try {
      final userSnapshot =
          await firebaseFirestore.collection(usersCollection).doc(userId).get();

      if (!userSnapshot.exists) {
        return Result.failure(
          const AuthenticationException(message: 'Korisnik nije pronađen'),
        );
      }

      return Result.success(userSnapshot);
    } on Exception catch (e) {
      return Result.failure(AuthenticationException(message: e.toString()));
    }
  }
}
