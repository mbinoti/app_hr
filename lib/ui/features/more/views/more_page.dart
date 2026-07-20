import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/hr_repository.dart';
import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/navigation.dart';
import '../../../core/widgets/hr_page.dart';
import '../view_models/more_view_model.dart';
import '../widgets/firebase_warning.dart';
import '../widgets/more_action.dart';
import 'simple_collection_page.dart';

class MorePage extends StatelessWidget {
  const MorePage({super.key, required this.status, required this.useCupertino});

  final FirebaseBootstrapStatus status;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          MoreViewModel(repository: context.read<HrRepository>()),
      child: _MoreView(status: status, useCupertino: useCupertino),
    );
  }
}

class _MoreView extends StatelessWidget {
  const _MoreView({required this.status, required this.useCupertino});

  final FirebaseBootstrapStatus status;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<MoreViewModel>();

    return HrPage(
      useCupertino: useCupertino,
      title: 'Mais',
      leading: const Icon(CupertinoIcons.line_horizontal_3),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
        children: [
          FirebaseWarning(status: status),
          const SizedBox(height: 12),
          if (status.isReady) ...[
            MoreAction(
              icon: CupertinoIcons.briefcase,
              title: 'Cargos',
              subtitle: 'Faixas salariais e quantidade por cargo',
              onTap: () => pushAdaptive(
                context,
                SimpleCollectionPage(
                  useCupertino: useCupertino,
                  kind: SimpleKind.jobs,
                ),
                useCupertino,
              ),
            ),
            MoreAction(
              icon: CupertinoIcons.location,
              title: 'Localidades',
              subtitle: 'Cidades, paises e departamentos',
              onTap: () => pushAdaptive(
                context,
                SimpleCollectionPage(
                  useCupertino: useCupertino,
                  kind: SimpleKind.locations,
                ),
                useCupertino,
              ),
            ),
            MoreAction(
              icon: CupertinoIcons.globe,
              title: 'Paises e Regioes',
              subtitle: 'Mapa organizacional por regiao',
              onTap: () => pushAdaptive(
                context,
                SimpleCollectionPage(
                  useCupertino: useCupertino,
                  kind: SimpleKind.countries,
                ),
                useCupertino,
              ),
            ),
          ],
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: status.isReady && !viewModel.isImporting
                ? viewModel.importHrData
                : null,
            icon: viewModel.isImporting
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.cloud_upload_outlined),
            label: Text(
              viewModel.isImporting
                  ? 'Importando...'
                  : 'Importar HR para Firestore',
            ),
          ),
          if (viewModel.message != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(viewModel.message!, textAlign: TextAlign.center),
            ),
        ],
      ),
    );
  }
}
