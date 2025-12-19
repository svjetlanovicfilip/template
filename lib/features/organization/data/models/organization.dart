class Organization {
  Organization({
    required this.id,
    required this.title,
    required this.isActive,
    this.primaryColor,
    this.secondaryColor,
    this.textColor,
  });

  factory Organization.fromJson(
    Map<String, dynamic> json,
    String organizationId,
  ) {
    return Organization(
      id: organizationId,
      title: json['title'],
      isActive: json['isActive'],
      primaryColor: json['primaryColor'],
      secondaryColor: json['secondaryColor'],
      textColor: json['textColor'],
    );
  }

  final String id;
  final String title;
  final bool isActive;
  final String? primaryColor;
  final String? secondaryColor;
  final String? textColor;
}
