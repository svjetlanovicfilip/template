import '../../../../common/models/result.dart';
import '../models/login_exceptions.dart';
import '../models/user_model.dart';

abstract class LoginRepository {
  Future<Result<UserModel, LoginException>> login(
    String email,
    String password,
  );

  Future<void> logout();
}
