import '../../features/login/data/models/user_model.dart';
import '../../features/organization/data/models/organization.dart';

class AppState {
  String? organizationId;
  UserModel? currentUser;
  String? currentSelectedUserId;
  List<UserModel> _organizationUsers = [];
  Organization? userOrganization;

  List<UserModel> get organizationUsers => _organizationUsers;

  void setOrganizationUsers(List<UserModel> users) {
    _organizationUsers = users;
  }
}
