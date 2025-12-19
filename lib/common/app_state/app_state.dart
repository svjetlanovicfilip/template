import '../../features/login/data/models/user_model.dart';

class AppState {
  String? organizationId;
  UserModel? currentUser;
  List<UserModel> _organizationUsers = [];

  List<UserModel> get organizationUsers => _organizationUsers;

  void setOrganizationUsers(List<UserModel> users) {
    _organizationUsers = users;
  }
}
