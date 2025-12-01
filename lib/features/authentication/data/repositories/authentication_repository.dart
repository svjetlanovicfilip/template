import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/models/result.dart';
import '../models/authentication_exceptions.dart';

// ignore: one_member_abstracts
abstract class AuthenticationRepository {
  Result<User, AuthenticationException> isUserAuthenticated();
}
