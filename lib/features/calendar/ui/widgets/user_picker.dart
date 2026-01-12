import 'package:flutter/material.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../login/data/models/user_model.dart';

class UserPicker extends StatefulWidget {
  const UserPicker({
    required this.employees,
    required this.onChanged,
    super.key,
  });

  final List<UserModel> employees;
  final Function(String) onChanged;

  @override
  State<UserPicker> createState() => _UserPickerState();
}

class _UserPickerState extends State<UserPicker> {
  final _employeeFilterKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return
    // GestureDetector(
    //   onTap:
    //       () => showEmployeeFilterMenu(
    //         context,
    //         _employeeFilterKey,
    //         (userId) => getIt<SlotBloc>().add(
    //           UserChanged(
    //             userId: userId,
    //             currentDisplayedDate: selectedDate,
    //           ),
    //         ),
    //       ),
    //   child: Container(
    //     key: _employeeFilterKey,
    //     padding: const EdgeInsets.all(12),
    //     decoration: BoxDecoration(
    //       borderRadius: BorderRadius.circular(12),
    //       color: AppColors.slate200,
    //     ),
    //     child: Row(
    //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //       children: [
    //         Text(
    //           _employees
    //                   .firstWhere(
    //                     (employee) =>
    //                         employee.id ==
    //                         appState.currentSelectedUserId,
    //                   )
    //                   .name ??
    //               '',
    //           style: theme.textTheme.labelMedium,
    //         ),
    //         const Icon(
    //           Icons.expand_more,
    //           color: AppColors.slate800,
    //         ),
    //       ],
    //     ),
    //   ),
    // ),
    DropdownButtonFormField<UserModel>(
      initialValue: widget.employees.firstWhere(
        (employee) => employee.id == appState.currentSelectedUserId,
      ),
      isExpanded: true,
      borderRadius: BorderRadius.circular(12),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.slate200,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
      icon: const Icon(Icons.expand_more, color: AppColors.slate800),
      items:
          widget.employees
              .map(
                (employee) => DropdownMenuItem(
                  value: employee,
                  child: Text('${employee.name} ${employee.surname}'),
                ),
              )
              .toList(),
      onChanged: (value) => widget.onChanged(value?.id ?? ''),
    );
  }
}
