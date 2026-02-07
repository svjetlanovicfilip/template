import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../employees/domain/cubit/employees_picker_cubit.dart';
import '../../../login/data/models/user_model.dart';
import '../../../users/domain/bloc/users_bloc.dart';
import 'employee_picker.dart';

class SelectedEmployeesList extends StatelessWidget {
  const SelectedEmployeesList({
    required this.anyEmployeeSelected,
    this.disabled = false,
    super.key,
  });

  final bool anyEmployeeSelected;
  final bool disabled;

  EmployeesPickerCubit get _employeesPickerCubit =>
      getIt<EmployeesPickerCubit>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      bloc: getIt<UsersBloc>()..add(UsersFetchRequested()),
      buildWhen:
          (previous, current) =>
              current is UsersFetchingSuccess || current is UsersFetching,
      builder: (context, state) {
        if (state is UsersFetchingSuccess && state.users.isNotEmpty) {
          return GestureDetector(
            onTap:
                disabled
                    ? null
                    : () => showEmployeePickerBottomSheet(
                      context: context,
                      employees: state.users,
                    ),

            child: BlocBuilder<EmployeesPickerCubit, Map<String, bool>>(
              bloc: _employeesPickerCubit,
              builder: (context, employeesState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppColors.slate200,
                        border:
                            anyEmployeeSelected
                                ? null
                                : Border.all(color: AppColors.red600),
                      ),
                      child: Wrap(
                        alignment: WrapAlignment.spaceBetween,
                        children: [
                          Text(
                            getSelectedEmployees(employeesState, state.users),
                            style: Theme.of(context).textTheme.labelMedium,
                          ),
                          const Icon(
                            Icons.expand_more,
                            color: AppColors.slate800,
                          ),
                        ],
                      ),
                    ),
                    if (!anyEmployeeSelected) ...[
                      const SizedBox(height: 12),
                      Text(
                        'Molimo vas da izaberete zaposlenog.',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: AppColors.red600,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String getSelectedEmployees(
    Map<String, bool> employees,
    List<UserModel> users,
  ) {
    final selectedEmployeeIds = employees.keys.where(
      (id) => employees[id] ?? false,
    );

    return selectedEmployeeIds.isEmpty
        ? 'Izaberite zaposlenog'
        : selectedEmployeeIds
            .map((id) => users.firstWhere((user) => user.id == id))
            .map((user) => '${user.name} ${user.surname}')
            .join(', ');
  }
}

void showEmployeePickerBottomSheet({
  required BuildContext context,
  required List<UserModel> employees,
}) {
  showModalBottomSheet(
    context: context,
    builder: (context) => EmployeePicker(employees: employees),
  );
}
