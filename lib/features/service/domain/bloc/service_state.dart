part of 'service_bloc.dart';

enum ServiceStatus { loading, loaded, error }

final class ServiceState extends Equatable {
  const ServiceState({
    this.services = const [],
    this.selectedServices = const [],
    this.status = ServiceStatus.loading,
  });
  final List<ServiceType> services;
  final List<ServiceType> selectedServices;
  final ServiceStatus status;

  @override
  List<Object> get props => [services, selectedServices, status];
}
