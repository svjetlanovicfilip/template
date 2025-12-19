import '../../../../common/models/result.dart';
import '../../../login/data/models/user_model.dart';
import '../models/organization.dart';

// ignore: one_member_abstracts
abstract class OrganizationRepository {
  Future<Result<Organization, Exception>> getUserOrganization(
    String organizationId,
  );

  Future<Result<List<UserModel>, Exception>> getOrganizationUsers(
    String organizationId,
  );
}
