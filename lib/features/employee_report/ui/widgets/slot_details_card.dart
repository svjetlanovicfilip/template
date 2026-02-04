import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';
import '../../../calendar/domain/utils/utils.dart';
import '../../../client_history/ui/widgets/client_visit_info.dart';
import '../../data/models/slot_details.dart';

class SlotDetailsCard extends StatelessWidget {
  const SlotDetailsCard({required this.slotDetails, super.key});

  final SlotDetails slotDetails;

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
            formatDateLong(slotDetails.startDateTime),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          ClientVisitInfo(
            title: formatDateRange(
              slotDetails.startDateTime,
              slotDetails.endDateTime,
            ),
            icon: Icons.access_time_outlined,
          ),
          if (slotDetails.services.isNotEmpty) ...[
            ClientVisitInfo(
              title: slotDetails.services
                  .map(
                    (service) =>
                        '${service.title} - ${service.price.toStringAsFixed(2)} KM',
                  )
                  .join('\n'),
              icon: Icons.local_offer_outlined,
            ),
          ],
          if (slotDetails.title != null && slotDetails.title!.isNotEmpty)
            ClientVisitInfo(title: slotDetails.title!, icon: Icons.note),
          if (slotDetails.client != null)
            ClientVisitInfo(
              title: slotDetails.client!.name,
              icon: Icons.person_outline,
            ),
        ],
      ),
    );
  }
}
