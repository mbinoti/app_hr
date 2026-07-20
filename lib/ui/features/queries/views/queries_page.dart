import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/navigation.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/segmented_tabs.dart';
import '../../more/widgets/firebase_warning.dart';
import '../widgets/query_card.dart';
import 'query_result_page.dart';

class QueriesPage extends StatelessWidget {
  const QueriesPage({super.key, required this.useCupertino});

  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final status = context.watch<FirebaseBootstrapStatus>();
    if (!status.isReady) {
      return HrPage(
        useCupertino: useCupertino,
        title: 'Consultas',
        leading: const Icon(CupertinoIcons.line_horizontal_3),
        trailing: const Icon(CupertinoIcons.bell),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
          children: [FirebaseWarning(status: status)],
        ),
      );
    }

    final queryDefinitions = context.watch<HrRepository>().queryDefinitions();

    return HrPage(
      useCupertino: useCupertino,
      title: 'Consultas',
      leading: const Icon(CupertinoIcons.line_horizontal_3),
      trailing: const Icon(CupertinoIcons.bell),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          const SegmentedTabs(
            labels: ['Consultas prontas', 'Minhas consultas'],
          ),
          const SizedBox(height: 12),
          for (final query in queryDefinitions)
            QueryCard(
              query: query,
              useCupertino: useCupertino,
              onTap: () => pushAdaptive(
                context,
                QueryResultPage(definition: query, useCupertino: useCupertino),
                useCupertino,
              ),
            ),
        ],
      ),
    );
  }
}
