import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/modals/delete_dialog.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/search_field.dart';
import '../../domain/bloc/service_bloc.dart';
import '../widgets/service_list_item.dart';

class ServiceListScreen extends StatelessWidget {
  const ServiceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        getIt<ServiceBloc>().add(ClearSearchServices());
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: Text('Cjenovnik')),
        floatingActionButton: PrimaryButton(
          icon: Icons.add,
          title: 'Dodaj uslugu',
          onTap: () {
            context.pushNamed(Routes.addEditServicesScreen);
          },
          borderRadius: BorderRadius.circular(30),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    onChanged: (value) {
                      getIt<ServiceBloc>().add(
                        SearchServices(searchQuery: value),
                      );
                    },
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
              BlocBuilder<ServiceBloc, ServiceState>(
                bloc: getIt<ServiceBloc>(),
                builder: (context, state) {
                  return SliverList.separated(
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return ServiceListItem(
                        service: service,
                        onDelete: () {
                          showDeleteDialog(
                            context: context,
                            title: 'Izbrisi uslugu!',
                            description:
                                'Da li ste sigurni da želite da izbrisete ${service.title}?',
                            onDelete: () {
                              getIt<ServiceBloc>().add(
                                DeleteService(serviceId: service.id ?? ''),
                              );
                              context.pop();
                            },
                          );
                        },
                      );
                    },
                    separatorBuilder:
                        (context, index) => const SizedBox(height: 12),
                    itemCount: state.services.length,
                  );
                },
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 70)),
            ],
          ),
        ),
      ),
    );
  }
}
