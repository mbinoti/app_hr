import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/formatters.dart';
import '../../../core/navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/section_header.dart';
import '../../more/widgets/firebase_warning.dart';
import '../../queries/views/query_result_page.dart';
import '../../queries/widgets/query_card.dart';
import '../widgets/dashboard_hero.dart';
import '../widgets/stat_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final repository = context.watch<HrRepository>();
    final status = context.watch<FirebaseBootstrapStatus>();
    final queryDefinitions = status.isReady
        ? repository.queryDefinitions()
        : const [];
    final body = Material(
      color: AppColors.pageBg,
      child: SafeArea(
        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream: status.isReady ? repository.watchOrganizationSummary() : null,
          builder: (context, snapshot) {
            final data = snapshot.data?.data() ?? const <String, dynamic>{};
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                const DashboardHero(
                  title: 'Schema HR no Firestore',
                  subtitle: 'Uma exploração do modelo HR da Oracle em NoSQL',
                ),
                const SizedBox(height: 16),
                if (!status.isReady) FirebaseWarning(status: status),
                SectionHeader(
                  title: 'Visao Geral',
                  action: snapshot.hasData ? 'Atualizado agora' : null,
                ),
                GridView.count(
                  crossAxisCount: MediaQuery.sizeOf(context).width > 560
                      ? 3
                      : 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.28,
                  children: [
                    StatTile(
                      icon: CupertinoIcons.person,
                      label: 'Funcionarios',
                      value: formatInt(data['totalEmployees']),
                      tint: AppColors.brand,
                    ),
                    StatTile(
                      icon: CupertinoIcons.building_2_fill,
                      label: 'Departamentos',
                      value: formatInt(data['totalDepartments']),
                      tint: AppColors.mint,
                    ),
                    StatTile(
                      icon: CupertinoIcons.money_dollar_circle,
                      label: 'Media Salarial',
                      value: formatMoney(data['averageSalary']),
                      tint: AppColors.amber,
                    ),
                    StatTile(
                      icon: CupertinoIcons.scope,
                      label: 'Maior Salario',
                      value: formatMoney(data['highestSalary']),
                      tint: AppColors.mint,
                    ),
                    StatTile(
                      icon: CupertinoIcons.briefcase,
                      label: 'Cargos',
                      value: formatInt(data['totalJobs']),
                      tint: AppColors.rose,
                    ),
                    StatTile(
                      icon: CupertinoIcons.globe,
                      label: 'Paises',
                      value: formatInt(data['totalCountries']),
                      tint: AppColors.brand,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const SectionHeader(
                  title: 'Consultas rapidas',
                  action: 'Ver todas',
                ),
                ...queryDefinitions
                    .take(4)
                    .map(
                      (query) => QueryCard(
                        query: query,
                        useCupertino: useCupertino,
                        onTap: () => pushAdaptive(
                          context,
                          QueryResultPage(
                            definition: query,
                            useCupertino: useCupertino,
                          ),
                          useCupertino,
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );

    if (useCupertino) {
      return CupertinoPageScaffold(child: body);
    }

    return Scaffold(body: body);
  }
}
