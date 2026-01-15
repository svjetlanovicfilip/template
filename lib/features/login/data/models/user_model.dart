class UserModel {
  UserModel({
    required this.email,
    this.id,
    this.isActive = true,
    this.name,
    this.surname,
    this.username,
    this.organizationId,
    this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String userId) {
    return UserModel(
      id: userId,
      email: json['email'],
      isActive: json['isActive'],
      name: json['name'],
      surname: json['surname'],
      username: json['username'],
      organizationId: json['orgId'],
      role: json['role'],
    );
  }

  final String? id;
  final String email;
  final bool isActive;
  final String? name;
  final String? surname;
  final String? username;
  final String? organizationId;
  final String? role;
}
