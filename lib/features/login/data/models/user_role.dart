enum UserRole {
  orgOwner,
  orgEmployee;

  static UserRole fromString(String role) => switch (role) {
    'ORG_OWNER' => UserRole.orgOwner,
    'ORG_EMPLOYEE' => UserRole.orgEmployee,
    _ => throw Exception('Invalid role: $role'),
  };

  @override
  String toString() => switch (this) {
    UserRole.orgOwner => 'ORG_OWNER',
    UserRole.orgEmployee => 'ORG_EMPLOYEE',
  };
}
