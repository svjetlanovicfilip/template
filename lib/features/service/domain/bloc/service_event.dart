part of 'service_bloc.dart';

sealed class ServiceEvent extends Equatable {
  const ServiceEvent();

  @override
  List<Object> get props => [];
}

class InitServiceListener extends ServiceEvent {}

class LoadServices extends ServiceEvent {
  const LoadServices({required this.docChanges});
  final List<DocumentChange<Map<String, dynamic>>> docChanges;
}

class SearchServices extends ServiceEvent {
  const SearchServices({required this.searchQuery});
  final String searchQuery;
}

class ClearSearchServices extends ServiceEvent {}

class SelectService extends ServiceEvent {
  const SelectService({required this.serviceId, required this.searchQuery});
  final String serviceId;
  final String searchQuery;
}

class AttachService extends ServiceEvent {
  const AttachService({required this.serviceIds});
  final List<String> serviceIds;
}

class DetachService extends ServiceEvent {
  const DetachService({required this.serviceId});
  final String serviceId;
}

class ClearSearchQuery extends ServiceEvent {}

class CreateService extends ServiceEvent {
  const CreateService({required this.service});
  final ServiceType service;
}

class DeleteService extends ServiceEvent {
  const DeleteService({required this.serviceId});
  final String serviceId;
}

class UpdateService extends ServiceEvent {
  const UpdateService({required this.service});
  final ServiceType service;
}
