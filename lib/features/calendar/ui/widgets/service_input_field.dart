import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../../service/ui/widgets/service_list.dart';

class ServiceInputField extends StatelessWidget {
  const ServiceInputField({super.key});

  ServiceBloc get _serviceBloc => getIt<ServiceBloc>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ServiceBloc, ServiceState>(
      bloc: _serviceBloc,
      builder: (context, state) {
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => _showBottomSheet(context),
          child: Container(
            padding:
                state.selectedServices.isNotEmpty
                    ? const EdgeInsets.symmetric(horizontal: 12)
                    : const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.slate200,
            ),

            child:
                state.selectedServices.isNotEmpty
                    ? Row(
                      spacing: 8,
                      children:
                          state.selectedServices
                              .map(
                                (service) => Chip(
                                  padding: EdgeInsets.zero,
                                  label: Text(service.title),
                                  labelStyle: theme.textTheme.labelMedium
                                      ?.copyWith(color: AppColors.white),
                                  deleteIcon: const Icon(
                                    Icons.close,
                                    color: AppColors.white,
                                  ),
                                  onDeleted: () {
                                    _serviceBloc.add(
                                      DetachService(
                                        serviceId: service.id ?? '',
                                      ),
                                    );
                                  },
                                  backgroundColor: AppColors.amber500,
                                  side: const BorderSide(
                                    color: AppColors.amber500,
                                  ),
                                ),
                              )
                              .toList(),
                    )
                    : Text(
                      'Izaberi uslugu',
                      style: theme.textTheme.labelMedium,
                    ),
          ),
        );
      },
    );
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    await showModalBottomSheet<List<String>>(
      context: context,
      builder: (context) => const ServiceList(),
      useSafeArea: true,
      isScrollControlled: true,
    );

    _serviceBloc.add(ClearSearchQuery());
  }
}
