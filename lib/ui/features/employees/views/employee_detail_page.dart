import 'package:flutter/cupertino.dart';

import '../../../core/formatters.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/back_glyph.dart';
import '../../../core/widgets/detail_widgets.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/segmented_tabs.dart';

class EmployeeDetailPage extends StatelessWidget {
  const EmployeeDetailPage({
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
    return HrPage(
      useCupertino: useCupertino,
      title: 'Detalhe do Funcionario',
      leading: BackGlyph(useCupertino: useCupertino),
      trailing: const Icon(CupertinoIcons.pencil),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 12, 18, 28),
        children: [
          GradientHeader(
            icon: Avatar(name: data['fullName'] ?? '', size: 78),
            title: data['fullName'] ?? '',
            subtitle:
                '${data['jobTitle'] ?? '-'}\n${data['departmentName'] ?? '-'}',
          ),
          Transform.translate(
            offset: const Offset(0, -18),
            child: InfoCard(
              child: Row(
                children: [
                  Expanded(
                    child: MetricColumn(
                      label: 'Salario',
                      value: formatMoney(data['salary']),
                    ),
                  ),
                  Expanded(
                    child: MetricColumn(
                      label: 'Comissao',
                      value: data['commissionPct'] == null
                          ? '-'
                          : '${data['commissionPct']}',
                    ),
                  ),
                  Expanded(
                    child: MetricColumn(
                      label: 'Data de Contratacao',
                      value: formatDate(data['hireDate']),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SegmentedTabs(
            labels: ['Geral', 'Departamento', 'Historico', 'Equipe'],
          ),
          DetailSection(
            title: 'Informacoes Pessoais',
            rows: [
              DetailRowData(CupertinoIcons.number, 'ID do Funcionario', id),
              DetailRowData(
                CupertinoIcons.mail,
                'Email',
                '${data['email'] ?? '-'}',
              ),
              DetailRowData(
                CupertinoIcons.phone,
                'Telefone',
                '${data['phoneNumber'] ?? '-'}',
              ),
              DetailRowData(
                CupertinoIcons.person,
                'ID do Gerente',
                '${data['managerId'] ?? '-'}',
              ),
            ],
          ),
          DetailSection(
            title: 'Informacoes Profissionais',
            rows: [
              DetailRowData(
                CupertinoIcons.briefcase,
                'Cargo',
                '${data['jobTitle'] ?? '-'}',
              ),
              DetailRowData(
                CupertinoIcons.money_dollar_circle,
                'Salario',
                formatMoney(data['salary']),
              ),
              DetailRowData(
                CupertinoIcons.building_2_fill,
                'Departamento',
                '${data['departmentName'] ?? '-'}',
              ),
              DetailRowData(
                CupertinoIcons.location,
                'Local',
                locationLine(data),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
