import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

import '../../../../common/di/di_container.dart';
import '../../data/models/service_type.dart';
import '../../data/repositories/service_repository.dart';

part 'service_event.dart';
part 'service_state.dart';

class ServiceBloc extends Bloc<ServiceEvent, ServiceState> {
  ServiceBloc(this.serviceRepository) : super(const ServiceState()) {
    on<InitServiceListener>(_onInitServiceListener);
    on<LoadServices>(_onLoadServices);
    on<SearchServices>(_onSearchServices);
    on<SelectService>(_onSelectService);
    on<ClearSearchServices>(_onClearSearchServices);
    on<AttachService>(_onAttachService);
    on<DetachService>(_onDetachService);
    on<ClearSearchQuery>(_onClearSearchQuery);
    on<CreateService>(_onCreateService);
    on<UpdateService>(_onUpdateService);
    on<DeleteService>(_onDeleteService);
  }

  final ServiceRepository serviceRepository;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _serviceListener;

  final List<ServiceType> _services = [];
  final List<ServiceType> _selectedServices = [];

  void _onInitServiceListener(
    InitServiceListener event,
    Emitter<ServiceState> emit,
  ) {
    final organizationId = appState.organizationId;

    if (organizationId == null) {
      return;
    }

    _serviceListener = serviceRepository
        .listenForNewChanges(organizationId)
        .listen((docs) {
          add(LoadServices(docChanges: docs.docChanges));
        });
  }

  void _onLoadServices(LoadServices event, Emitter<ServiceState> emit) {
    for (final change in event.docChanges) {
      final id = change.doc.id;
      final service = ServiceType.fromJson(change.doc.data() ?? {}, id);

      switch (change.type) {
        case DocumentChangeType.added:
          _services.add(service);
          break;
        case DocumentChangeType.modified:
          _services.removeWhere((e) => e.id == id);
          _services.add(service);
          break;
        case DocumentChangeType.removed:
          _services.removeWhere((e) => e.id == id);
          break;
      }
    }

    emit(ServiceState(services: List.from(_services)));
  }

  void _onClearSearchServices(
    ClearSearchServices event,
    Emitter<ServiceState> emit,
  ) {
    emit(ServiceState(services: List.from(_services)));
  }

  void _onSearchServices(SearchServices event, Emitter<ServiceState> emit) {
    if (_services.isEmpty) {
      return;
    }

    if (event.searchQuery.isEmpty) {
      emit(
        ServiceState(
          services: List.from(_services),
          selectedServices: List.from(_selectedServices),
        ),
      );
      return;
    }

    final searchQuery = event.searchQuery;
    final services =
        _services
            .where((service) => service.title.contains(searchQuery))
            .toList();
    emit(
      ServiceState(
        services: List.from(services),
        selectedServices: List.from(_selectedServices),
      ),
    );
  }

  void _onSelectService(SelectService event, Emitter<ServiceState> emit) {
    final service = _services.firstWhere(
      (service) => service.id == event.serviceId,
    );
    if (_selectedServices.contains(service)) {
      _selectedServices.remove(service);
    } else {
      _selectedServices.add(service);
    }

    final services =
        _services
            .where((service) => service.title.contains(event.searchQuery))
            .toList();

    emit(
      ServiceState(
        services: List.from(services),
        selectedServices: List.from(_selectedServices),
      ),
    );
  }

  void _onAttachService(AttachService event, Emitter<ServiceState> emit) {
    _selectedServices
      ..clear()
      ..addAll(
        event.serviceIds.map(
          (id) => _services.firstWhere((service) => service.id == id),
        ),
      );
    emit(
      ServiceState(
        services: List.from(_services),
        selectedServices: List.from(_selectedServices),
      ),
    );
  }

  void _onDetachService(DetachService event, Emitter<ServiceState> emit) {
    _selectedServices.removeWhere((service) => service.id == event.serviceId);
    emit(
      ServiceState(
        services: List.from(_services),
        selectedServices: List.from(_selectedServices),
      ),
    );
  }

  void _onClearSearchQuery(ClearSearchQuery event, Emitter<ServiceState> emit) {
    emit(
      ServiceState(
        services: List.from(_services),
        selectedServices: List.from(_selectedServices),
      ),
    );
  }

  void _onCreateService(CreateService event, _) {
    final organizationId = appState.organizationId;

    if (organizationId == null) {
      return;
    }

    serviceRepository.createService(event.service, organizationId);
  }

  void _onUpdateService(UpdateService event, _) {
    final organizationId = appState.organizationId;

    if (organizationId == null) {
      return;
    }

    serviceRepository.updateService(event.service, organizationId);
  }

  void _onDeleteService(DeleteService event, _) {
    final organizationId = appState.organizationId;

    if (organizationId == null) {
      return;
    }

    serviceRepository.deleteService(event.serviceId, organizationId);
  }

  void clearState() {
    _services.clear();
    _selectedServices.clear();
    _serviceListener?.cancel();
  }
}
