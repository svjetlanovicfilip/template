import '../../../../common/models/result.dart';
import '../models/login_exceptions.dart';
import '../models/user_model.dart';

// ignore: one_member_abstracts
abstract class LoginRepository {
  Future<Result<UserModel, LoginException>> login(
    String email,
    String password,
  );
  Future<Result<void, LoginException>> forgotPassword(String email);
}
