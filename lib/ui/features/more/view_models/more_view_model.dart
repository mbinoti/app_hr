import 'package:flutter/foundation.dart';

import '../../../../data/repositories/hr_repository.dart';

class MoreViewModel extends ChangeNotifier {
  MoreViewModel({required this.repository});

  final HrRepository repository;

  bool isImporting = false;
  String? message;

  Future<void> importHrData() async {
    isImporting = true;
    message = 'Importando dados HR para o Firestore...';
    notifyListeners();

    try {
      final result = await repository.importHrData();
      message =
          'Importacao concluida: ${result.employees} funcionarios, ${result.departments} departamentos e ${result.totalDocuments} documentos gravados.';
    } on Object catch (error) {
      message = 'Erro ao importar: $error';
    } finally {
      isImporting = false;
      notifyListeners();
    }
  }
}
