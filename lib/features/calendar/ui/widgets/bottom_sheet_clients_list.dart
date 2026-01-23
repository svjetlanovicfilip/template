import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../settings/data/client.dart';
import '../../../settings/domain/cubit/client_picker_cubit.dart';

class BottomSheetClientsList extends StatelessWidget {
  const BottomSheetClientsList({required this.clients, super.key});

  final List<Client> clients;

  ClientPickerCubit get _clientPickerCubit => getIt<ClientPickerCubit>();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemBuilder:
          (context, index) => BlocBuilder<ClientPickerCubit, Client?>(
            bloc: _clientPickerCubit,
            builder: (context, state) {
              return RadioGroup<String>(
                groupValue: state != null ? state.id ?? '' : null,
                onChanged: (value) {
                  if (value == null) return;
                  final client = clients.firstWhere(
                    (client) => client.id == value,
                  );
                  _clientPickerCubit.pickClient(client: client);
                },
                child: RadioListTile<String>(
                  activeColor: AppColors.amber500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  value: clients[index].id ?? '',
                  title: Text(clients[index].name),
                ),
              );
            },
          ),
      itemCount: clients.length,
    );
  }
}
