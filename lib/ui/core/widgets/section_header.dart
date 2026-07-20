import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title, this.action});

  final String title;
  final String? action;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 8, 2, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w900),
            ),
          ),
          if (action != null)
            Text(
              action!,
              style: const TextStyle(fontSize: 11, color: AppColors.brand),
            ),
        ],
      ),
    );
  }
}
