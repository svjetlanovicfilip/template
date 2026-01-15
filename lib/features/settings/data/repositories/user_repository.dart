import '../../../../common/models/result.dart';
import '../../../login/data/models/user_model.dart';

abstract class UserRepository {
  Future<Result<UserModel, Exception>> createEmployee({
    required String name,
    required String lastName,
    required String username,
    required String email,
  });

  Future<Result<Map<String, dynamic>, Exception>> deleteEmployee({
    required String employeeUid,
  });
}
