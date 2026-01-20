import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/search_field.dart';
import '../../../../config/style/colors.dart';
import '../../domain/bloc/service_bloc.dart';
import 'service_item.dart';

class ServiceList extends StatefulWidget {
  const ServiceList({super.key});

  @override
  State<ServiceList> createState() => _ServiceListState();
}

class _ServiceListState extends State<ServiceList> {
  late ServiceBloc serviceBloc;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    serviceBloc = getIt<ServiceBloc>();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        spacing: 16,
        children: [
          SearchField(
            controller: _searchController,
            onChanged:
                (value) => serviceBloc.add(SearchServices(searchQuery: value)),
                hint: 'Pretraga usluga...',
          ),
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              bloc: serviceBloc,
              builder: (context, state) {
                final services = state.services;
                final selectedServices = state.selectedServices;

                if (services.isEmpty) {
                  return Center(
                    child: Text(
                      'Nema usluga',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  );
                }

                return ListView(
                  children: [
                    ...services.map(
                      (service) => ServiceItem(
                        service: service,
                        isSelected: selectedServices.contains(service),
                        onSelected: (service) {
                          serviceBloc.add(
                            SelectService(
                              serviceId: service.id ?? '',
                              searchQuery: _searchController.text,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
