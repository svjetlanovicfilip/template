import 'package:equatable/equatable.dart';

class ServiceType extends Equatable {
  const ServiceType({
    required this.title,
    required this.price,
    required this.isActive,
    this.id,
    this.description,
  });

  factory ServiceType.fromJson(Map<String, dynamic> json, String serviceId) {
    return ServiceType(
      id: serviceId,
      title: json['title'],
      description: json['description'],
      price:
          json['price'] is int
              ? (json['price'] as int).toDouble()
              : json['price'] as double,
      isActive: json['isActive'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'isActive': isActive,
    };
  }

  final String? id;
  final String title;
  final String? description;
  final double price;
  final bool isActive;

  @override
  List<Object?> get props => [id, title, price, isActive];
}
