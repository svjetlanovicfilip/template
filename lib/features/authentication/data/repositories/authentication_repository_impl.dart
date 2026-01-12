import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/models/result.dart';
import '../../../login/data/models/user_model.dart';
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

  @override
  Future<Result<UserModel, AuthenticationException>> getUserProfile(
    String userId,
  ) async {
    final result = await authenticationRemoteDatasource.getUserProfile(userId);

    if (result.isFailure) {
      return Result.failure(result.failure as AuthenticationException);
    }

    return Result.success(
      UserModel.fromJson(
        (result.success?.data() as Map<String, dynamic>?) ?? {},
        userId,
      ),
    );
  }

  @override
  Future<void> logout() async => authenticationRemoteDatasource.logout();
}
