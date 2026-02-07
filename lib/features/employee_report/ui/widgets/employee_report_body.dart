import 'package:flutter/material.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../data/models/employee_report.dart';
import 'employee_report_card.dart';
import 'total_slots_indicator.dart';

class EmployeeReportBody extends StatelessWidget {
  const EmployeeReportBody({required this.report, super.key});

  final EmployeeReport report;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          TotalSlotsIndicator(totalSlots: report.totalSlots),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ).copyWith(top: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 16,
              children: [
                EmployeeReportCard(
                  title: 'Ukupan prihod',
                  value: '${report.totalEarnings.toStringAsFixed(2)} KM',
                  icon: Icons.attach_money_outlined,
                ),

                EmployeeReportCard(
                  title: 'Jedinstveni klijenti',
                  value: report.totalClients.toString(),
                  icon: Icons.group_outlined,
                ),

                const SizedBox(height: 16),
                PrimaryButton(
                  onTap: () {
                    Navigator.pushNamed(context, Routes.slotListScreen);
                  },
                  title: 'Pogledaj istoriju termina',
                  borderRadius: BorderRadius.circular(12),
                  icon: Icons.list_alt_sharp,
                  width: double.infinity,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
