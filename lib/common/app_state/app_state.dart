import '../../features/login/data/models/user_model.dart';
import '../../features/organization/data/models/organization.dart';

class AppState {
  String? organizationId;
  UserModel? currentUser;
  String? currentSelectedUserId;
  Organization? userOrganization;

  void clearState() {
    organizationId = null;
    currentUser = null;
    currentSelectedUserId = null;
    userOrganization = null;
  }
}
