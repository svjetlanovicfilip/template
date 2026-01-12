import '../../../../common/models/result.dart';

abstract class UserRepository {
  Future<Result<Map<String, dynamic>, Exception>> createEmployee({
    required String name,
    required String lastName,
    required String username,
    required String email,
  });
}