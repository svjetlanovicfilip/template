import 'package:flutter/material.dart';

import '../../../../config/style/colors.dart';
import '../../data/models/service_type.dart';

class ServiceItem extends StatelessWidget {
  const ServiceItem({
    required this.service,
    required this.onSelected,
    this.isSelected = false,
    super.key,
  });

  final ServiceType service;
  final Function(ServiceType) onSelected;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      checkColor: AppColors.white,
      activeColor: AppColors.amber500,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      value: isSelected,
      onChanged: (value) {
        onSelected(service);
      },
      title: Text(service.title),
    );
  }
}
