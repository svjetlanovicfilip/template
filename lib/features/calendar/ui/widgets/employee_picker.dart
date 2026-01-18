import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../employees/domain/cubit/employees_picker_cubit.dart';
import '../../../login/data/models/user_model.dart';

class EmployeePicker extends StatelessWidget {
  const EmployeePicker({required this.employees, super.key});

  final List<UserModel> employees;

  EmployeesPickerCubit get _employeesPickerCubit =>
      getIt<EmployeesPickerCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EmployeesPickerCubit, Map<String, bool>>(
      bloc: _employeesPickerCubit,
      builder: (context, state) {
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemBuilder:
              (context, index) => CheckboxListTile(
                checkColor: AppColors.white,
                activeColor: AppColors.amber500,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                value: state[employees[index].id ?? ''] ?? false,
                onChanged: (value) {
                  _employeesPickerCubit.pickEmployee(
                    employeeId: employees[index].id ?? '',
                    isPicked: value ?? false,
                  );
                },
                title: Text(
                  '${employees[index].name} ${employees[index].surname}',
                ),
              ),
          itemCount: employees.length,
        );
      },
    );
  }
}
