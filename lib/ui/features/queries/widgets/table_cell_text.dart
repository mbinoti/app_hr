import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TableCellText extends StatelessWidget {
  const TableCellText(this.text, {super.key, this.header = false});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Text(
        text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          color: header ? AppColors.muted : AppColors.ink,
          fontWeight: header ? FontWeight.w800 : FontWeight.w600,
        ),
      ),
    );
  }
}
