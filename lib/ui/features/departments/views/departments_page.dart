import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_progress.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/panels.dart';
import '../../../core/widgets/search_field.dart';
import '../view_models/departments_view_model.dart';
import '../widgets/department_tile.dart';
import 'department_detail_page.dart';
import '../../more/widgets/firebase_warning.dart';

class DepartmentsPage extends StatelessWidget {
  const DepartmentsPage({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<FirebaseBootstrapStatus>();
    if (!status.isReady) {
      return HrPage(
        useCupertino: useCupertino,
        title: 'Departamentos',
        leading: const Icon(CupertinoIcons.line_horizontal_3),
        trailing: const Icon(CupertinoIcons.bell),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [FirebaseWarning(status: status)],
        ),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => DepartmentsViewModel(),
      child: _DepartmentsView(useCupertino: useCupertino),
    );
  }
}

class _DepartmentsView extends StatelessWidget {
  const _DepartmentsView({required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<HrRepository>();
    final viewModel = context.watch<DepartmentsViewModel>();

    return HrPage(
      useCupertino: useCupertino,
      title: 'Departamentos',
      leading: const Icon(CupertinoIcons.line_horizontal_3),
      trailing: const Icon(CupertinoIcons.bell),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 10),
            child: SearchField(
              hint: 'Buscar departamento...',
              onChanged: viewModel.updateSearch,
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: repository.watchDepartments(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorPanel(message: '${snapshot.error}');
                }
                if (!snapshot.hasData) {
                  return const Center(child: AdaptiveProgress());
                }
                final docs = snapshot.data!.docs.where((doc) {
                  if (viewModel.search.isEmpty) return true;
                  final text =
                      '${doc['departmentName']} ${doc['managerName']} ${doc['city']}'
                          .toLowerCase();
                  return text.contains(viewModel.search);
                }).toList();
                if (docs.isEmpty) {
                  return const EmptyPanel(
                    text: 'Nenhum departamento encontrado.',
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
                  itemCount: docs.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 9),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    return DepartmentTile(
                      data: data,
                      color:
                          AppColors.palette[index % AppColors.palette.length],
                      onTap: () => pushAdaptive(
                        context,
                        DepartmentDetailPage(
                          id: docs[index].id,
                          data: data,
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
}
