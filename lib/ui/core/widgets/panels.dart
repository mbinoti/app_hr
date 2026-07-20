import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'info_card.dart';

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.muted),
        ),
      ),
    );
  }
}

class ErrorPanel extends StatelessWidget {
  const ErrorPanel({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: InfoCard(
        child: Text(message, style: const TextStyle(color: AppColors.rose)),
      ),
    );
  }
}
