import '../../../../common/models/result.dart';
import '../datasources/login_remote_datasource.dart';
import '../models/login_exceptions.dart';
import '../models/user_model.dart';
import 'login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  LoginRepositoryImpl({required this.loginRemoteDatasource});

  final LoginRemoteDatasource loginRemoteDatasource;

  @override
  Future<Result<UserModel, LoginException>> login(
    String email,
    String password,
  ) async {
    final result = await loginRemoteDatasource.login(email, password);
    if (result.isSuccess) {
      return Result.success(
        UserModel(
          id: result.success?.user?.uid ?? '',
          email: result.success?.user?.email ?? '',
        ),
      );
    } else {
      return Result.failure(result.failure as LoginException);
    }
  }

  @override
  Future<Result<void, LoginException>> forgotPassword(String email) async =>
      loginRemoteDatasource.forgotPassword(email);
}
