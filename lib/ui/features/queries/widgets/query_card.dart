import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/hr_query_definition.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/decorated_icon.dart';

class QueryCard extends StatelessWidget {
  const QueryCard({
    super.key,
    required this.query,
    required this.useCupertino,
    required this.onTap,
  });

  final HrQueryDefinition query;
  final bool useCupertino;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.line),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(11),
                child: DecoratedIcon(
                  icon: query.icon,
                  color: query.color,
                  small: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      query.title,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    Text(
                      query.subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 18,
                color: AppColors.muted,
              ),
              const SizedBox(width: 12),
            ],
          ),
        ),
      ),
    );
  }
}
