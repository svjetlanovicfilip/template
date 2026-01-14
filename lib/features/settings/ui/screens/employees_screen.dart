import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../login/data/models/user_model.dart';
import '../../domain/bloc/delete_user_bloc.dart';

class EmployeesScreen extends StatefulWidget {
  const EmployeesScreen({super.key});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  final deleteUserBloc = getIt<DeleteUserBloc>();

  late List<UserModel> _employees;

  @override
  void initState() {
    super.initState();
    _employees = List<UserModel>.from(appState.organizationUsers);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<DeleteUserBloc, DeleteUserState>(
      bloc: deleteUserBloc,
      listener: (context, state) {
        if (state is DeleteUserSuccess) {
          setState(() {
            _employees.removeWhere((u) => u.id == state.employeeUid);
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Zaposleni je deaktiviran.')),
          );
        } else if (state is DeleteUserFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: PrimaryButton(
          icon: Icons.add,
          title: 'Dodaj zaposlenog',
          onTap: () {
            context.pushNamed(Routes.addEditmployeesScreen);
          },
          borderRadius: BorderRadius.circular(30),
        ),
        backgroundColor: Colors.white,
        appBar: const CustomAppBar(title: Text('Zaposleni')),
        body: SafeArea(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
            itemCount: _employees.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = _employees[index];
              final fullName =
                  '${user.name ?? ''} ${user.surname ?? ''}'.trim();

              return _EmployeeItem(
                name: fullName.isEmpty ? 'Bez imena' : fullName,
                onDelete: () {
                  final uid = user.id.trim();
                  if (uid.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Nedostaje ID korisnika.')),
                    );
                    return;
                  }

                  showDeleteDialog(context, employeeUid: uid);
                },
              );
            },
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
                    deleteUserBloc.add(
                      DeleteEmployeeSubmitted(employeeUid: employeeUid),
                    );

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
  const _EmployeeItem({required this.name, required this.onDelete});

  final String name;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  name,
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
            color: Colors.redAccent,
          ),
        ],
      ),
    );
  }
}
