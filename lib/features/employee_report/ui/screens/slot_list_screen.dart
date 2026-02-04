import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../common/di/di_container.dart';
import '../../../../common/widgets/custom_app_bar.dart';
import '../../../../config/style/colors.dart';
import '../../data/models/slot_details.dart';
import '../../domain/bloc/employee_report_bloc.dart';
import '../widgets/slot_details_card.dart';

class SlotListScreen extends StatefulWidget {
  const SlotListScreen({super.key});

  @override
  State<SlotListScreen> createState() => _SlotListScreenState();
}

class _SlotListScreenState extends State<SlotListScreen> {
  final _bloc = getIt<EmployeeReportBloc>();
  final ScrollController _scrollController = ScrollController();

  final List<SlotDetails> _items = [];
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMore(isInitial: true);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (!_hasMore || _isLoading) return;
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  void _loadMore({bool isInitial = false}) {
    setState(() => _isLoading = true);
    _bloc.add(LoadEmployeeSlotsHistory(isInitial: isInitial));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: Text('Istorija termina')),
      body: SafeArea(
        child: BlocListener<EmployeeReportBloc, EmployeeReportState>(
          bloc: _bloc,
          listenWhen:
              (prev, curr) =>
                  curr is EmployeeSlotsHistoryLoaded ||
                  curr is EmployeeSlotsHistoryLoading,
          listener: (context, state) {
            if (state is EmployeeSlotsHistoryLoaded) {
              setState(() {
                _items.addAll(state.slots);
                _hasMore = state.slots.isNotEmpty;
                _isLoading = false;
              });
            }
          },
          child:
              _items.isEmpty && _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(color: AppColors.amber500),
                  )
                  : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _items.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= _items.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.amber500,
                            ),
                          ),
                        );
                      }
                      return SlotDetailsCard(slotDetails: _items[index]);
                    },
                  ),
        ),
      ),
    );
  }
}
