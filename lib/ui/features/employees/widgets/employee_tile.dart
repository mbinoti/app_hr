import 'package:flutter/material.dart';

import '../../../core/formatters.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/avatar.dart';
import '../../../core/widgets/info_card.dart';

class EmployeeTile extends StatelessWidget {
  const EmployeeTile({
    super.key,
    required this.employee,
    required this.onTap,
    this.compact = false,
  });

  final Map<String, dynamic> employee;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ListSurface(
        child: Row(
          children: [
            Avatar(
              name: '${employee['fullName'] ?? ''}',
              size: compact ? 38 : 46,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${employee['fullName'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${employee['jobTitle'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: compact ? 12 : 13,
                      color: AppColors.muted,
                    ),
                  ),
                  Text(
                    '${employee['departmentName'] ?? '-'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.brand,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              formatMoney(employee['salary']),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
