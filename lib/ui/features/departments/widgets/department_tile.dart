import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/decorated_icon.dart';
import '../../../core/widgets/info_card.dart';

class DepartmentTile extends StatelessWidget {
  const DepartmentTile({
    super.key,
    required this.data,
    required this.color,
    required this.onTap,
  });

  final Map<String, dynamic> data;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: ListSurface(
        child: Row(
          children: [
            DecoratedIcon(icon: CupertinoIcons.building_2_fill, color: color),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${data['departmentName'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  Text(
                    'Gerente: ${data['managerName'] ?? '-'}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    'Funcionarios: ${data['employeeCount'] ?? 0}',
                    style: const TextStyle(
                      color: AppColors.muted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              CupertinoIcons.person_2,
              color: AppColors.brand,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
