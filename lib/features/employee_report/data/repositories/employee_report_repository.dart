import 'package:cloud_firestore/cloud_firestore.dart';

// ignore: one_member_abstracts
abstract class EmployeeReportRepository {
  Future<QuerySnapshot<Map<String, dynamic>>> getEmployeeMonthlyReport({
    required String employeeId,
    required DateTime from,
    required DateTime to,
  });
}
