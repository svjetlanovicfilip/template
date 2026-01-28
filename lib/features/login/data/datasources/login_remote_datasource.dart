import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

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
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      if (e.code == 'wrong-password') {
        return Result.failure(
          const WrongPasswordException(message: 'Pogrešna lozinka'),
        );
      }
      return Result.failure(
        const LoginException(message: 'Nepostojeći korisnik'),
      );
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(LoginException(message: e.toString()));
    }
  }

  Future<Result<void, LoginException>> forgotPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return Result.success(null);
    } on FirebaseAuthException catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(
        const UserNotFoundException(message: 'Korisnik nije pronađen'),
      );
    } on Exception catch (e) {
      unawaited(
        FirebaseCrashlytics.instance.recordError(e, StackTrace.current),
      );
      return Result.failure(
        const LoginException(
          message: 'Greška prilikom slanja emaila za resetovanje lozinke',
        ),
      );
    }
  }
}
