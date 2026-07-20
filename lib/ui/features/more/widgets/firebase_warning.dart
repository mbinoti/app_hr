import 'package:flutter/cupertino.dart';

import '../../../../firebase/firebase_bootstrap.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/info_card.dart';

class FirebaseWarning extends StatelessWidget {
  const FirebaseWarning({super.key, required this.status});

  final FirebaseBootstrapStatus status;

  @override
  Widget build(BuildContext context) {
    if (status.isReady) {
      return const InfoCard(
        child: Row(
          children: [
            Icon(CupertinoIcons.cloud, color: AppColors.brand),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Firebase conectado. Use a importacao se a base estiver vazia.',
              ),
            ),
          ],
        ),
      );
    }

    return InfoCard(
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: AppColors.rose,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text('Firebase nao configurado: ${status.message}')),
        ],
      ),
    );
  }
}
