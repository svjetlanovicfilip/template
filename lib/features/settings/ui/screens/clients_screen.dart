import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/constants/routes.dart';
import '../../../../common/di/di_container.dart';
import '../../../../common/extensions/context_extension.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../common/widgets/primary_button.dart';
import '../../../../common/widgets/search_field.dart';
import '../../domain/bloc/clients_bloc.dart';
import 'client_list_item.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ClientsBloc>(
      create: (_) => getIt<ClientsBloc>()..add(ClientsFetchRequested()),
      child: Scaffold(
        appBar: const CustomAppBar(title: Text('Klijenti')),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: PrimaryButton(
          icon: Icons.add,
          title: 'Dodaj klijenta',
          onTap: () {
            context.pushNamed(Routes.addEditClientsScreen);
          },
          borderRadius: BorderRadius.circular(30),
        ),
        body: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SearchField(
                    onChanged: (value) => setState(() => _query = value),
                    hint: 'Pretraga klijenata...',
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              /// LISTA
              BlocBuilder<ClientsBloc, ClientsState>(
                builder: (context, state) {
                  if (state is ClientsFetching || state is ClientsInitial) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.only(top: 32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    );
                  }

                  if (state is ClientsFetchingSuccess) {
                    final clients = state.clients; // kod tebe se zove clinets

                    final filtered = clients.where((c) {
                      final q = _query.trim().toLowerCase();
                      if (q.isEmpty) return true;

                      return c.name.toLowerCase().contains(q) ||
                          c.phoneNumber.toLowerCase().contains(q);
                    }).toList();

                    if (filtered.isEmpty) {
                      return const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.only(top: 32),
                          child: Center(
                            child: Text('Nema klijenata za prikaz.'),
                          ),
                        ),
                      );
                    }

                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 100),
                      sliver: SliverList.separated(
                        itemCount: filtered.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final c = filtered[index];

                          return ClientListItem(
                            client: c,
                            onDelete: () {
                              // Ovdje kasnije okineš delete event:
                              // context.read<ClientsBloc>().add(ClientRemoved(clientId: c.id ?? ''));
                            },
                          );
                        },
                      ),
                    );
                  }

                  // Ako nemaš Failure state, ovdje stavi fallback
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: Center(child: Text('Greška pri učitavanju klijenata.')),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
