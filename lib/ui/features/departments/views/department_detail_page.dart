import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../core/formatters.dart';
import '../../../core/navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_progress.dart';
import '../../../core/widgets/back_glyph.dart';
import '../../../core/widgets/decorated_icon.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/panels.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../employees/views/employee_detail_page.dart';
import '../../employees/widgets/employee_tile.dart';

class DepartmentDetailPage extends StatelessWidget {
  const DepartmentDetailPage({
    super.key,
    required this.id,
    required this.data,
    required this.useCupertino,
  });

  final String id;
  final Map<String, dynamic> data;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<HrRepository>();

    return HrPage(
      useCupertino: useCupertino,
      title: 'Detalhe do Departamento',
      leading: BackGlyph(useCupertino: useCupertino),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          GradientHeader(
            icon: const DecoratedIcon(
              icon: CupertinoIcons.desktopcomputer,
              color: AppColors.brand,
            ),
            title: '${data['departmentName'] ?? '-'}',
            subtitle: '${data['regionName'] ?? 'Organizacao'}',
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: InfoCard(
              child: Wrap(
                runSpacing: 18,
                children: [
                  SizedBox(
                    width: 160,
                    child: MetricColumn(
                      label: 'Gerente',
                      value: '${data['managerName'] ?? '-'}',
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: MetricColumn(
                      label: 'Local',
                      value: departmentLocation(data),
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: MetricColumn(
                      label: 'Funcionarios',
                      value: '${data['employeeCount'] ?? 0}',
                    ),
                  ),
                  SizedBox(
                    width: 160,
                    child: MetricColumn(label: 'ID do Departamento', value: id),
                  ),
                ],
              ),
            ),
          ),
          const SegmentedTabs(
            labels: ['Funcionarios', 'Localizacao', 'Informacoes'],
          ),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: repository.watchDepartmentEmployees(data['departmentId']),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: AdaptiveProgress()),
                );
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return const EmptyPanel(text: 'Departamento sem funcionarios.');
              }
              return Column(
                children: docs
                    .map(
                      (doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: EmployeeTile(
                          employee: doc.data(),
                          compact: true,
                          onTap: () => pushAdaptive(
                            context,
                            EmployeeDetailPage(
                              id: doc.id,
                              data: doc.data(),
                              useCupertino: useCupertino,
                            ),
                            useCupertino,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
