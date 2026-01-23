import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../config/style/colors.dart';
import '../../../users/domain/bloc/users_bloc.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  UsersBloc get _usersBloc => getIt<UsersBloc>();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      bloc: _usersBloc,
      buildWhen:
          (previous, current) =>
              current is UsersFetchingSuccess || current is UsersFetching,
      builder:
          (context, state) => Scaffold(
            floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
            floatingActionButton: PrimaryButton(
              icon: Icons.add,
              title: 'Dodaj zaposlenog',
              onTap: () {
                context.pushNamed(Routes.addEditEmployeesScreen);
              },
              borderRadius: BorderRadius.circular(30),
            ),
            appBar: const CustomAppBar(title: Text('Zaposleni')),
            body:
                state is UsersFetchingSuccess
                    ? SafeArea(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),

                        itemCount: state.users.length,
                        separatorBuilder:
                            (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final user = state.users[index];
                          final fullName =
                              '${user.name ?? ''} ${user.surname ?? ''}'.trim();

                          return _EmployeeItem(
                            name: fullName.isEmpty ? 'Bez imena' : fullName,
                            onDelete:
                                user.id != null &&
                                        appState.currentUser?.id == user.id
                                    ? null
                                    : () {
                                      final uid = user.id ?? '';
                                      if (uid.isEmpty) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Nedostaje ID korisnika.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      showDeleteDialog(
                                        context,
                                        employeeUid: uid,
                                      );
                                    },
                          );
                        },
                      ),
                    )
                    : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.amber500,
                      ),
                    ),
          ),
    );
  }

  /// Dialog: ovdje direktno dispatch-aš delete event na klik "Izbrisi"
  Future<void> showDeleteDialog(
    BuildContext context, {
    required String employeeUid,
  }) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            'Izbrisi zaposlenog!',
            style: Theme.of(
              dialogContext,
            ).textTheme.titleLarge?.copyWith(color: Colors.black),
          ),
          content: Text(
            'Da li ste sigurni da želite da izbrisete zaposlenog?',
            style: Theme.of(
              dialogContext,
            ).textTheme.titleMedium?.copyWith(color: Colors.black),
          ),
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Odustani'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    // 1) dispatch delete
                    // deleteUserBloc.add(
                    //   DeleteEmployeeSubmitted(employeeUid: employeeUid),
                    // );

                    _usersBloc.add(UserRemoved(userId: employeeUid));

                    // 2) close dialog
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Izbrisi'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _EmployeeItem extends StatelessWidget {
  const _EmployeeItem({required this.name, this.onDelete});

  final String name;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: AppColors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                name,
                style: const TextStyle(fontSize: 16, color: Colors.black),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.red50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline,
                  color: AppColors.red600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
