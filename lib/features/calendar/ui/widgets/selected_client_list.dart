import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/search_field.dart';
import '../../../../config/style/colors.dart';
import '../../../settings/data/client.dart';
import '../../../settings/domain/bloc/clients_bloc.dart';
import '../../../settings/domain/cubit/client_picker_cubit.dart';
import 'bottom_sheet_clients_list.dart';

class SelectedClientList extends StatelessWidget {
  const SelectedClientList({this.disabled = false, super.key});

  final bool disabled;

  ClientPickerCubit get _clientPickerCubit => getIt<ClientPickerCubit>();
  ClientsBloc get _clientsBloc => getIt<ClientsBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClientPickerCubit, Client?>(
      bloc: _clientPickerCubit,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: disabled ? null : () => _showBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: AppColors.slate200,
                ),

                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    BlocBuilder<ClientPickerCubit, Client?>(
                      bloc: _clientPickerCubit,
                      builder: (context, state) {
                        if (state != null) {
                          return Text(
                            state.name,
                            style: Theme.of(context).textTheme.labelMedium,
                          );
                        }

                        return Text(
                          'Izaberite klijenta',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            color: AppColors.slate500,
                            fontWeight: FontWeight.w400,
                          ),
                        );
                      },
                    ),
                    const Icon(Icons.expand_more, color: AppColors.slate800),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
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
              children: [
                SearchField(
                  onChanged: (value) {
                    _clientsBloc.add(ClientsSearched(searchQuery: value));
                  },
                  hint: 'Pretraga klijenata...',
                ),
                Expanded(
                  child: BlocBuilder<ClientsBloc, ClientsState>(
                    bloc: _clientsBloc,
                    buildWhen:
                        (_, current) =>
                            current is ClientsSearchSuccess ||
                            current is ClientsFetchingSuccess,
                    builder: (context, state) {
                      if (state is ClientsSearchSuccess) {
                        final clients =
                            state.clients
                                .where((client) => client.isActive)
                                .toList();
                        return BottomSheetClientsList(clients: clients);
                      } else if (state is ClientsFetchingSuccess) {
                        final clients =
                            state.clients
                                .where((client) => client.isActive)
                                .toList();
                        return BottomSheetClientsList(clients: clients);
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
