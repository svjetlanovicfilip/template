import '../../../../common/models/result.dart';
import '../datasources/user_remote_datasource.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.remote});

  final UserRemoteDatasource remote;

  @override
  Future<Result<Map<String, dynamic>, Exception>> createEmployee({
    required String name,
    required String lastName,
    required String username,
    required String email,
  }) {
    return remote.createEmployee(
      name: name,
      lastName: lastName,
      username: username,
      email: email,
    );
  }

  @override
  Future<Result<Map<String, dynamic>, Exception>> deleteEmployee({
    required String employeeUid,
  }) {
    return remote.deleteEmployee(employeeUid: employeeUid);
  }
}
