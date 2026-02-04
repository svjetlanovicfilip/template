class EmployeeReport {
  EmployeeReport({
    required this.employeeId,
    required this.employeeName,
    required this.employeeEmail,
    required this.totalEarnings,
    required this.totalSlots,
    required this.totalClients,
    required this.totalServices,
  });

  final String employeeId;
  final String employeeName;
  final String employeeEmail;
  final double totalEarnings;
  final int totalSlots;
  final int totalClients;
  final int totalServices;
}
