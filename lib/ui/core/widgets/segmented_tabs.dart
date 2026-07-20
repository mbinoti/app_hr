import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({super.key, required this.labels});

  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: i == 0
                          ? AppColors.brand
                          : Colors.black.withValues(alpha: .06),
                      width: i == 0 ? 2 : 1,
                    ),
                  ),
                ),
                child: Text(
                  labels[i],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: i == 0 ? AppColors.brand : AppColors.muted,
                    fontWeight: i == 0 ? FontWeight.w900 : FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
