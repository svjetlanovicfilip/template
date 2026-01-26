import 'package:flutter/material.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/domain/utils/utils.dart';
import '../../../service/data/models/service_type.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../data/models/client_slot.dart';
import 'client_visit_info.dart';

class ClientVisitItem extends StatelessWidget {
  const ClientVisitItem({required this.clientSlot, super.key});

  final ClientSlot clientSlot;

  List<ServiceType> get _services =>
      clientSlot.serviceIds
          .map(
            (id) => getIt<ServiceBloc>().state.services.firstWhere(
              (service) => service.id == id,
            ),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
      ),
      child: Column(
        spacing: 8,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            formatDateLong(clientSlot.startDateTime),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          ClientVisitInfo(
            title: formatDateRange(
              clientSlot.startDateTime,
              clientSlot.endDateTime,
            ),
            icon: Icons.access_time_outlined,
          ),
          if (_services.isNotEmpty) ...[
            ClientVisitInfo(
              title: _services.map((service) => service.title).join('\n'),
              icon: Icons.local_offer_outlined,
            ),
          ],
          if (clientSlot.title != null && clientSlot.title!.isNotEmpty)
            ClientVisitInfo(title: clientSlot.title!, icon: Icons.note),
        ],
      ),
    );
  }
}
