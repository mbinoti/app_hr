import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/navigation.dart';
import '../../../core/widgets/adaptive_progress.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/panels.dart';
import '../../../core/widgets/search_field.dart';
import '../view_models/employees_view_model.dart';
import '../widgets/employee_tile.dart';
import '../widgets/filter_chip_button.dart';
import 'employee_detail_page.dart';
import '../../more/widgets/firebase_warning.dart';

class EmployeesPage extends StatelessWidget {
  const EmployeesPage({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<FirebaseBootstrapStatus>();
    if (!status.isReady) {
      return HrPage(
        useCupertino: useCupertino,
        title: 'Funcionarios',
        leading: const Icon(CupertinoIcons.line_horizontal_3),
        trailing: const Icon(CupertinoIcons.bell),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [FirebaseWarning(status: status)],
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (context) =>
          EmployeesViewModel(repository: context.read<HrRepository>()),
      child: _EmployeesView(useCupertino: useCupertino),
    );
  }
}

class _EmployeesView extends StatelessWidget {
  const _EmployeesView({required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<HrRepository>();
    final viewModel = context.watch<EmployeesViewModel>();

    return HrPage(
      useCupertino: useCupertino,
      title: 'Funcionarios',
      leading: const Icon(CupertinoIcons.line_horizontal_3),
      trailing: const Icon(CupertinoIcons.bell),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
            child: Column(
              children: [
                SearchField(
                  hint: 'Buscar funcionario...',
                  onChanged: viewModel.updateSearch,
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChipButton(
                        label: viewModel.department ?? 'Departamento',
                        onTap: () =>
                            _pickField(context, 'departmentName', true),
                      ),
                      FilterChipButton(
                        label: viewModel.job ?? 'Cargo',
                        onTap: () => _pickField(context, 'jobTitle', false),
                      ),
                      FilterChipButton(
                        label: viewModel.salaryDescending
                            ? 'Maior salario'
                            : 'Menor salario',
                        onTap: viewModel.toggleSalaryOrder,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: repository.watchEmployees(
                department: viewModel.department,
                job: viewModel.job,
                salaryDescending: viewModel.salaryDescending,
              ),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorPanel(
                    message: _employeeErrorMessage(snapshot.error),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: AdaptiveProgress());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  if (viewModel.search.isEmpty) return true;
                  final text =
                      '${doc['fullName']} ${doc['jobTitle']} ${doc['departmentName']} ${doc['email']}'
                          .toLowerCase();
                  return text.contains(viewModel.search);
                }).toList();
                if (docs.isEmpty) {
                  return const EmptyPanel(
                    text: 'Nenhum funcionario encontrado.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    return EmployeeTile(
                      employee: doc.data(),
                      onTap: () => pushAdaptive(
                        context,
                        EmployeeDetailPage(
                          id: doc.id,
                          data: doc.data(),
                          useCupertino: useCupertino,
                        ),
                        useCupertino,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickField(
    BuildContext context,
    String field,
    bool department,
  ) async {
    final viewModel = context.read<EmployeesViewModel>();
    final values = await viewModel.loadFilterValues(field);
    if (!context.mounted) return;
    final selected = await showModalBottomSheet<String?>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Todos'),
              onTap: () => Navigator.pop(context),
            ),
            for (final value in values)
              ListTile(
                title: Text(value),
                onTap: () => Navigator.pop(context, value),
              ),
          ],
        ),
      ),
    );
    if (!context.mounted) return;
    if (department) {
      viewModel.updateDepartment(selected);
    } else {
      viewModel.updateJob(selected);
    }
  }
}

String _employeeErrorMessage(Object? error) {
  if (error is FirebaseException &&
      error.plugin == 'cloud_firestore' &&
      error.code == 'failed-precondition' &&
      (error.message?.contains('requires an index') ?? false)) {
    return 'Esta combinacao de filtros precisa de um indice composto no Firestore. '
        'Use o link exibido no console ou publique os indices do arquivo firestore.indexes.json.';
  }
  return 'Nao foi possivel carregar os funcionarios. Tente novamente em instantes.';
}
