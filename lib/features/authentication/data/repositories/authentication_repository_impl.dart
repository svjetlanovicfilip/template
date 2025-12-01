import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/models/result.dart';
import '../datasources/authentication_remote_datasource.dart';
import '../models/authentication_exceptions.dart';
import 'authentication_repository.dart';

class AuthenticationRepositoryImpl extends AuthenticationRepository {
  AuthenticationRepositoryImpl({required this.authenticationRemoteDatasource});

  final AuthenticationRemoteDatasource authenticationRemoteDatasource;

  @override
  Result<User, AuthenticationException> isUserAuthenticated() {
    return authenticationRemoteDatasource.isUserAuthenticated();
  }
}
