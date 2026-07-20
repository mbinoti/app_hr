import 'package:flutter/foundation.dart';

import '../../../../data/repositories/hr_repository.dart';

class EmployeesViewModel extends ChangeNotifier {
  EmployeesViewModel({required this.repository});

  final HrRepository repository;

  String search = '';
  String? department;
  String? job;
  bool salaryDescending = true;

  void updateSearch(String value) {
    search = value.trim().toLowerCase();
    notifyListeners();
  }

  void updateDepartment(String? value) {
    department = value;
    notifyListeners();
  }

  void updateJob(String? value) {
    job = value;
    notifyListeners();
  }

  void toggleSalaryOrder() {
    salaryDescending = !salaryDescending;
    notifyListeners();
  }

  Future<List<String>> loadFilterValues(String field) {
    return repository.distinctEmployeeValues(field);
  }
}
