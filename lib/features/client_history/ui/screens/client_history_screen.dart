import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/domain/utils/utils.dart';
import '../../../settings/data/client.dart';
import '../../domain/bloc/client_history_bloc.dart';
import '../widgets/client_visit_item.dart';

class ClientHistoryScreen extends StatefulWidget {
  const ClientHistoryScreen({required this.client, super.key});

  final Client client;

  @override
  State<ClientHistoryScreen> createState() => _ClientHistoryScreenState();
}

class _ClientHistoryScreenState extends State<ClientHistoryScreen> {
  final ClientHistoryBloc _clientHistoryBloc = getIt<ClientHistoryBloc>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _clientHistoryBloc.add(
        ClientHistoryFetchRequested(clientId: widget.client.id ?? ''),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Detalji klijenta')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: NotificationListener<ScrollUpdateNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent * 0.8) {
                _clientHistoryBloc.add(
                  ClientHistoryLoadMoreRequested(
                    clientId: widget.client.id ?? '',
                  ),
                );
              }
              return true;
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.amber500, AppColors.amber600],
                      ),
                    ),
                    child: Row(
                      spacing: 16,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          spacing: 16,
                          children: [
                            Row(
                              spacing: 16,
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: AppColors.white,
                                  child: Text(
                                    getInitials(widget.client.name),
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.amber500,
                                      fontSize: 24,
                                    ),
                                  ),
                                ),
                                Text(
                                  widget.client.name,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.white,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                            if (widget.client.phoneNumber.isNotEmpty)
                              Row(
                                spacing: 16,
                                children: [
                                  const Icon(
                                    Icons.phone_outlined,
                                    color: AppColors.white,
                                    size: 24,
                                  ),
                                  Text(
                                    widget.client.phoneNumber,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Container(
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
                          'Klijent od',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.slate400,
                          ),
                        ),
                        Text(
                          formatDateLong(
                            widget.client.createdAt?.toDate() ?? DateTime.now(),
                          ),
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.amber500,
                            fontSize: 16,
                          ),
                        ),
                        const Divider(color: AppColors.slate200),
                        Text(
                          'Napomene',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: AppColors.slate400,
                          ),
                        ),
                        Text(
                          widget.client.description ?? '',
                          style: Theme.of(
                            context,
                          ).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: AppColors.amber500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),

                SliverToBoxAdapter(
                  child: Text(
                    'Posjete',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                BlocBuilder<ClientHistoryBloc, ClientHistoryState>(
                  bloc: _clientHistoryBloc,
                  buildWhen:
                      (previous, current) =>
                          current is ClientHistoryLoaded ||
                          current is ClientHistoryLoading,
                  builder: (context, state) {
                    if (state is ClientHistoryLoaded) {
                      if (state.slots.isEmpty) {
                        return SliverToBoxAdapter(
                          child: SizedBox(
                            height: 200,
                            width: MediaQuery.of(context).size.width / 2,
                            child: Center(
                              child: Text(
                                'Nema posjeta za prikaz.',
                                style: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.copyWith(
                                  fontSize: 16,
                                  color: AppColors.slate400,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }

                      return SliverList.builder(
                        itemCount: state.slots.length,
                        itemBuilder: (context, index) {
                          return ClientVisitItem(
                            clientSlot: state.slots[index],
                          );
                        },
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                BlocBuilder<ClientHistoryBloc, ClientHistoryState>(
                  bloc: _clientHistoryBloc,
                  buildWhen:
                      (previous, current) =>
                          current is ClientHistoryLoadingMore ||
                          current is ClientHistoryLoaded,
                  builder: (context, state) {
                    if (state is ClientHistoryLoadingMore) {
                      return const SliverToBoxAdapter(
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AppColors.amber500,
                          ),
                        ),
                      );
                    }
                    return const SliverToBoxAdapter(child: SizedBox.shrink());
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getInitials(String name) {
    return name.split(' ').map((e) => e.substring(0, 1)).join().toUpperCase();
  }
}
