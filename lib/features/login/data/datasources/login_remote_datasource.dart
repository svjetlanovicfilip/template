import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/models/result.dart';
import '../models/login_exceptions.dart';

class LoginRemoteDatasource {
  const LoginRemoteDatasource({
    required this.firebaseAuth,
    required this.firebaseFirestore,
  });

  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;

  Future<Result<UserCredential, LoginException>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Result.success(user);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return Result.failure(
          const UserNotFoundException(message: 'Nepostojeći korisnik'),
        );
      }
      if (e.code == 'wrong-password') {
        return Result.failure(
          const WrongPasswordException(message: 'Pogrešna lozinka'),
        );
      }
      return Result.failure(const LoginException(message: 'Nepoznata greška'));
    } on Exception catch (e) {
      return Result.failure(LoginException(message: e.toString()));
    }
  }
}
