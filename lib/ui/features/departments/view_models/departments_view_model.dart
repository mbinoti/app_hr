import 'package:flutter/foundation.dart';

class DepartmentsViewModel extends ChangeNotifier {
  String search = '';

  void updateSearch(String value) {
    search = value.trim().toLowerCase();
    notifyListeners();
  }
}
