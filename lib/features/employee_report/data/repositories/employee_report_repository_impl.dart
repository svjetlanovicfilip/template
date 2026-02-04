import 'package:cloud_firestore/cloud_firestore.dart';

import '../datasources/employee_report_remote_datasource.dart';
import 'employee_report_repository.dart';

class EmployeeReportRepositoryImpl implements EmployeeReportRepository {
  EmployeeReportRepositoryImpl({required this.employeeReportRemoteDatasource});

  final EmployeeReportRemoteDatasource employeeReportRemoteDatasource;

  @override
  Future<QuerySnapshot<Map<String, dynamic>>> getEmployeeMonthlyReport({
    required String employeeId,
    required DateTime from,
    required DateTime to,
  }) async {
    return employeeReportRemoteDatasource.getEmployeeMonthlyReport(
      employeeId: employeeId,
      from: from,
      to: to,
    );
  }
}
