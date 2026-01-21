import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../../calendar/domain/utils/utils.dart';
import '../../../service/data/models/service_type.dart';
import '../../../service/domain/bloc/service_bloc.dart';
import '../../../settings/data/client.dart';
import '../../data/models/client_slot.dart';
import '../../domain/bloc/client_history_bloc.dart';

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
                                    widget.client.name.substring(0, 2),
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
                        Container(
                          padding: const EdgeInsets.all(8),
                          margin: const EdgeInsets.only(top: 8),
                          decoration: BoxDecoration(
                            color: AppColors.amber400.withValues(alpha: 0.4),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: AppColors.white),
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
}

class ClientVisitItem extends StatelessWidget {
  const ClientVisitItem({required this.clientSlot, super.key});

  final ClientSlot clientSlot;

  List<ServiceType> get _services =>
      clientSlot.serviceIds
          .map(
            (id) => getIt<ServiceBloc>().state.services.firstWhere(
              (service) => service.id == id,
            ),
          )
          .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            formatDateLong(clientSlot.startDateTime),
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          ClientVisitInfo(
            title: formatDateRange(
              clientSlot.startDateTime,
              clientSlot.endDateTime,
            ),
            icon: Icons.access_time_outlined,
          ),
          if (_services.isNotEmpty) ...[
            ClientVisitInfo(
              title: _services.map((service) => service.title).join('\n'),
              icon: Icons.local_offer_outlined,
            ),
          ],
          if (clientSlot.title != null && clientSlot.title!.isNotEmpty)
            ClientVisitInfo(title: clientSlot.title!, icon: Icons.note),
        ],
      ),
    );
  }
}

class ClientVisitInfo extends StatelessWidget {
  const ClientVisitInfo({required this.title, required this.icon, super.key});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Icon(icon, color: AppColors.amber500, size: 18),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.amber500,
            ),
          ),
        ),
      ],
    );
  }
}

class ClientProperty extends StatelessWidget {
  const ClientProperty({required this.title, required this.value, super.key});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      spacing: 16,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppColors.amber500,
            ),
            textAlign: TextAlign.justify,
          ),
        ),
      ],
    );
  }
}
