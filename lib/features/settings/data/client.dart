import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class Client extends Equatable {
  const Client({
    required this.name,
    required this.phoneNumber,
    this.id,
    this.description,
    this.createdAt,
  });

  factory Client.fromJson(Map<String, dynamic> json, String clientId) {
    return Client(
      name: (json['name'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? '') as String,
      id: clientId,
      description: json['description'] as String?,
      createdAt: json['createdAt'] as Timestamp?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'description': description,
      // 'createdAt': createdAt,
      // 'id' ne moraš čuvati u dokumentu, id ti je doc.id
    };
  }

  final String name;
  final String phoneNumber;
  final String? id;
  final String? description;
  final Timestamp? createdAt;

  @override
  List<Object?> get props => [name, phoneNumber, id, description, createdAt];
}
