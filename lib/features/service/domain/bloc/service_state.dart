part of 'service_bloc.dart';

final class ServiceState extends Equatable {
  const ServiceState({
    this.services = const [],
    this.selectedServices = const [],
  });
  final List<ServiceType> services;
  final List<ServiceType> selectedServices;

  @override
  List<Object> get props => [services, selectedServices];
}
