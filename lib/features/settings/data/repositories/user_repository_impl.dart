import '../../../../common/models/result.dart';
import '../datasources/add_user_remote_datasource.dart';
import 'user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({required this.remote});

  final AddUserRemoteDatasource remote;

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
}