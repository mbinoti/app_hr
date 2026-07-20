import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../core/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/adaptive_progress.dart';
import '../../../core/widgets/back_glyph.dart';
import '../../../core/widgets/decorated_icon.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/info_card.dart';

enum SimpleKind { jobs, locations, countries }

class SimpleCollectionPage extends StatelessWidget {
  const SimpleCollectionPage({
    super.key,
    required this.useCupertino,
    required this.kind,
  });

  final bool useCupertino;
  final SimpleKind kind;

  @override
  Widget build(BuildContext context) {
    final config = _config(kind);
    final repository = context.watch<HrRepository>();

    return HrPage(
      useCupertino: useCupertino,
      title: config.title,
      leading: BackGlyph(useCupertino: useCupertino),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: repository.watchSimpleCollection(
          config.collection,
          config.orderBy,
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: AdaptiveProgress());
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            itemCount: snapshot.data!.docs.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = snapshot.data!.docs[index].data();
              return InfoCard(
                child: Row(
                  children: [
                    DecoratedIcon(
                      icon: _simpleIcon(kind),
                      color:
                          AppColors.palette[index % AppColors.palette.length],
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${item[config.titleField] ?? '-'}',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          Text(
                            _simpleSubtitle(kind, item),
                            style: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '${item[config.countField] ?? 0}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

({
  String title,
  String collection,
  String titleField,
  String countField,
  String orderBy,
})
_config(SimpleKind kind) {
  return switch (kind) {
    SimpleKind.jobs => (
      title: 'Cargos',
      collection: 'jobs',
      titleField: 'jobTitle',
      countField: 'employeeCount',
      orderBy: 'jobTitle',
    ),
    SimpleKind.locations => (
      title: 'Localidades',
      collection: 'locations',
      titleField: 'city',
      countField: 'departmentCount',
      orderBy: 'city',
    ),
    SimpleKind.countries => (
      title: 'Paises e Regioes',
      collection: 'countries',
      titleField: 'countryName',
      countField: 'locationCount',
      orderBy: 'countryName',
    ),
  };
}

IconData _simpleIcon(SimpleKind kind) {
  return switch (kind) {
    SimpleKind.jobs => CupertinoIcons.briefcase,
    SimpleKind.locations => CupertinoIcons.location_fill,
    SimpleKind.countries => CupertinoIcons.globe,
  };
}

String _simpleSubtitle(SimpleKind kind, Map<String, dynamic> item) {
  return switch (kind) {
    SimpleKind.jobs =>
      'Min: ${formatMoney(item['minSalary'])}   Max: ${formatMoney(item['maxSalary'])}',
    SimpleKind.locations =>
      '${item['stateProvince'] ?? '-'}, ${item['countryName'] ?? '-'}',
    SimpleKind.countries => '${item['regionName'] ?? '-'}',
  };
}
