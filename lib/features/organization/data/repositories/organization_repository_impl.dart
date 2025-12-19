import '../../../../common/models/result.dart';
import '../../../login/data/models/user_model.dart';
import '../datasources/organization_remote_datasource.dart';
import '../models/organization.dart';
import 'organization_repository.dart';

class OrganizationRepositoryImpl implements OrganizationRepository {
  OrganizationRepositoryImpl({required this.organizationRemoteDatasource});

  final OrganizationRemoteDatasource organizationRemoteDatasource;

  @override
  Future<Result<Organization, Exception>> getUserOrganization(
    String organizationId,
  ) async {
    final result = await organizationRemoteDatasource.getUserOrganization(
      organizationId,
    );

    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    return Result.success(
      Organization.fromJson(
        result.success?.data() as Map<String, dynamic>? ?? {},
        result.success?.id ?? organizationId,
      ),
    );
  }

  @override
  Future<Result<List<UserModel>, Exception>> getOrganizationUsers(
    String organizationId,
  ) async {
    final result = await organizationRemoteDatasource.getOrganizationUsers(
      organizationId,
    );

    if (result.isFailure) {
      return Result.failure(result.failure as Exception);
    }

    final users =
        result.success?.docs
            .map((doc) => UserModel.fromJson(doc.data(), doc.id))
            .toList() ??
        [];

    return Result.success(users);
  }
}
