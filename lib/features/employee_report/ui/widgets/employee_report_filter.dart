import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../../../common/di/di_container.dart';
import '../../../../config/style/colors.dart';
import '../../../employees/domain/cubit/employees_picker_cubit.dart';
import '../../../login/data/models/user_model.dart';
import '../../../users/domain/bloc/users_bloc.dart';
import '../../domain/bloc/employee_report_bloc.dart';

class EmployeeReportFilter extends StatefulWidget {
  const EmployeeReportFilter({super.key});

  @override
  State<EmployeeReportFilter> createState() => _EmployeeReportFilterState();
}

class _EmployeeReportFilterState extends State<EmployeeReportFilter> {
  EmployeesPickerCubit get _employeesPickerCubit =>
      getIt<EmployeesPickerCubit>();

  @override
  void initState() {
    super.initState();
    _employeesPickerCubit.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(color: AppColors.slate900),
      child: Row(
        spacing: 16,
        children: [
          const Expanded(flex: 2, child: _EmployeePicker()),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.slate200,
            ),
            child: const Row(
              children: [
                Icon(Icons.calendar_month, color: AppColors.slate400),
                SizedBox(width: 4),
                _MonthPicker(),
                _YearPicker(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _employeesPickerCubit.clear();
  }
}

class _YearPicker extends StatefulWidget {
  const _YearPicker();

  @override
  State<_YearPicker> createState() => _YearPickerState();
}

class _YearPickerState extends State<_YearPicker> {
  late String _selectedYear;
  final GlobalKey _filterIconKey = GlobalKey();
  List<String> years = [
    DateTime.now().year.toString(),
    (DateTime.now().year - 1).toString(),
  ];
  @override
  void initState() {
    super.initState();
    _selectedYear = DateTime.now().year.toString();
    getIt<EmployeeReportBloc>().add(EmployeeYearChanged(year: _selectedYear));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      key: _filterIconKey,
      onTap:
          () => showItemsFilterMenu(
            context: context,
            filterIconKey: _filterIconKey,
            onSelected: (item) {
              setState(() {
                _selectedYear = item;
              });
              getIt<EmployeeReportBloc>().add(EmployeeYearChanged(year: item));
            },
            items: years,
            selectedItem: _selectedYear,
          ),
      child: Text(
        _selectedYear,
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _MonthPicker extends StatefulWidget {
  const _MonthPicker();

  @override
  State<_MonthPicker> createState() => _MonthPickerState();
}

class _MonthPickerState extends State<_MonthPicker> {
  late String _selectedMonth;
  List<String> months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Maj',
    'Jun',
    'Jul',
    'Avg',
    'Sep',
    'Okt',
    'Nov',
    'Dec',
  ];
  final GlobalKey _filterIconKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _selectedMonth = months[DateTime.now().month - 1];
    getIt<EmployeeReportBloc>().add(
      EmployeeMonthChanged(month: months.indexOf(_selectedMonth)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _filterIconKey,
      onTap:
          () => showItemsFilterMenu(
            context: context,
            filterIconKey: _filterIconKey,
            onSelected: (item) {
              setState(() {
                _selectedMonth = item;
              });
              getIt<EmployeeReportBloc>().add(
                EmployeeMonthChanged(month: months.indexOf(item)),
              );
            },
            items: months,
            selectedItem: _selectedMonth,
          ),
      child: Text(
        '$_selectedMonth / ',
        style: Theme.of(context).textTheme.labelMedium,
      ),
    );
  }
}

class _EmployeePicker extends StatefulWidget {
  const _EmployeePicker();

  @override
  State<_EmployeePicker> createState() => __EmployeePickerState();
}

class __EmployeePickerState extends State<_EmployeePicker> {
  late List<UserModel> _employees;
  final GlobalKey _filterIconKey = GlobalKey();
  String _selectedEmployeeId = '';

  String get _selectedEmployeeName {
    final employee = _employees.firstWhereOrNull(
      (employee) => employee.id == _selectedEmployeeId,
    );

    return employee != null ? '${employee.name} ${employee.surname}' : '';
  }

  @override
  void initState() {
    super.initState();
    _employees = getIt<UsersBloc>().users;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _filterIconKey,
      behavior: HitTestBehavior.opaque,
      onTap:
          () => showEmployeePickerMenu(
            context: context,
            filterIconKey: _filterIconKey,
            onSelected: (item) {
              setState(() {
                _selectedEmployeeId = item;
              });
              getIt<EmployeeReportBloc>().add(
                EmployeeChanged(employeeId: item),
              );
            },
            employees: _employees,
            selectedItem: _selectedEmployeeId,
          ),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.slate200,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          spacing: 8,
          children: [
            Text(
              _selectedEmployeeName.isEmpty
                  ? 'Izaberite zaposlenog'
                  : _selectedEmployeeName,
              style: Theme.of(context).textTheme.labelMedium,
              overflow: TextOverflow.ellipsis,
            ),
            const Icon(Icons.expand_more, color: AppColors.slate800),
          ],
        ),
      ),
    );
  }
}

Future<void> showEmployeePickerMenu({
  required BuildContext context,
  required GlobalKey filterIconKey,
  required Function(String) onSelected,
  required List<UserModel> employees,
  required String selectedItem,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final box = filterIconKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final target = Rect.fromPoints(
    box.localToGlobal(const Offset(0, 48), ancestor: overlay),
    box.localToGlobal(
      box.size.bottomLeft(const Offset(10, 0)),
      ancestor: overlay,
    ),
  );
  final position = RelativeRect.fromRect(target, Offset.zero & overlay.size);

  final result = await showMenu<String>(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    items: <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Izaberite zaposlenog',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(height: 8),
      ...employees.map((item) {
        final selected = item.id == selectedItem;
        return PopupMenuItem<String>(
          value: item.id,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.amber500 : null,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.name} ${item.surname}',
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ],
  );

  if (result != null) {
    onSelected(result);
  }
}

Future<void> showItemsFilterMenu({
  required BuildContext context,
  required GlobalKey filterIconKey,
  required Function(String) onSelected,
  required List<String> items,
  required String selectedItem,
}) async {
  final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
  final box = filterIconKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null) return;
  final target = Rect.fromPoints(
    box.localToGlobal(const Offset(0, 48), ancestor: overlay),
    box.localToGlobal(
      box.size.bottomLeft(const Offset(10, 0)),
      ancestor: overlay,
    ),
  );
  final position = RelativeRect.fromRect(target, Offset.zero & overlay.size);

  final result = await showMenu<String>(
    context: context,
    position: position,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    color: Colors.white,
    items: <PopupMenuEntry<String>>[
      const PopupMenuItem<String>(
        enabled: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Izaberite mjesec',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.slate900,
              ),
            ),
          ],
        ),
      ),
      const PopupMenuDivider(height: 8),
      ...items.map((item) {
        final selected = item == selectedItem;
        return PopupMenuItem<String>(
          value: item,
          child: Container(
            decoration: BoxDecoration(
              color: selected ? AppColors.amber500 : null,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.slate900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ],
  );

  if (result != null) {
    onSelected(result);
  }
}
