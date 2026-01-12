import 'package:flutter/material.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../authentication/domain/bloc/authentication_bloc.dart';
import '../../../calendar/domain/bloc/slot_bloc.dart';
import '../../../service/domain/bloc/service_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Vaša podešavanja',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: false,
        // actions: [
        //   TextButton(
        //     onPressed: () {
        //       // TODO: ovdje dodaj logout logiku
        //     },
        //     child: const Text(
        //       'Odjavite se',
        //       style: TextStyle(
        //         color: Colors.white,
        //       ),
        //     ),
        //   ),
        // ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _SettingsMenuItem(
                label: 'Upravljanje zaposlenima',
                onTap: () {
                  context.pushNamed(Routes.employeesScreen);
                },
              ),
              _SettingsDivider(),

              _SettingsMenuItem(
                label: 'Postavite vaš naziv',
                onTap: () {
                  context.pushNamed(Routes.changeTitleScreen);
                },
              ),
              _SettingsDivider(),

              _SettingsMenuItem(
                label: 'Cjenovnik',
                onTap: () {
                  context.pushNamed(Routes.serviceListScreen);
                },
              ),
              _SettingsDivider(),

              _SettingsMenuItem(
                label: 'Promjena lozinke',
                onTap: () {
                  context.pushNamed(Routes.changePasswordScreen);
                },
              ),
              _SettingsDivider(),

              _SettingsMenuItem(
                label: 'Odjavite se',
                onTap: () {
                  showLogoutDialog(context);
                  // TODO: Test
                },
              ),
              _SettingsDivider(),
            ],
          ),
        ),
      ),
    );
  }
}

Future<bool> showLogoutDialog(BuildContext context) async {
  void logout() {
    getIt<AuthenticationBloc>().add(AuthenticationLogoutRequested());
    appState.clearState();
    getIt<SlotBloc>().clearState();
    getIt<ServiceBloc>().clearState();
    context.pushReplacementNamed(Routes.login);
  }

  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(
          'Odjava!',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: Colors.black),
        ),
        content: Text(
          'Da li ste sigurni da želite da se odjavite?',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: Colors.black),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text('Odustani'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: logout, child: const Text('Odjavi se')),
            ],
          ),
        ],
      );
    },
  );

  return result ?? false;
}

class _SettingsMenuItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SettingsMenuItem({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            label,
            style: const TextStyle(fontSize: 16, color: Colors.black),
          ),
        ),
      ),
    );
  }
}

class _SettingsDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 0,
      thickness: 1,
      color: Colors.black12,
      indent: 16,
      endIndent: 16,
    );
  }
}
