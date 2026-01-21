import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../../service/ui/widgets/service_list.dart';

class SelectedServicesList extends StatelessWidget {
  const SelectedServicesList({required this.anyServiceSelected, super.key});

  final bool anyServiceSelected;

  ServiceBloc get _serviceBloc => getIt<ServiceBloc>();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<ServiceBloc, ServiceState>(
      bloc: _serviceBloc,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
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
                  border:
                      anyServiceSelected
                          ? null
                          : Border.all(color: AppColors.red600),
                ),

                child:
                    state.selectedServices.isNotEmpty
                        ? Wrap(
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
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
              ),
            ),

            if (!anyServiceSelected) ...[
              const SizedBox(height: 12),
              Text(
                'Molimo vas da izaberete uslugu.',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.red600,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Future<void> _showBottomSheet(BuildContext context) async {
    await showModalBottomSheet<List<String>>(
      context: context,
      builder:
          (context) => Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: const ServiceList(),
          ),
      useSafeArea: true,
      isScrollControlled: true,
    );

    _serviceBloc.add(ClearSearchQuery());
  }
}
