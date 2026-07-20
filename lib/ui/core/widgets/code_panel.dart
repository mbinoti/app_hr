import 'package:flutter/material.dart';

import 'info_card.dart';

class CodePanel extends StatelessWidget {
  const CodePanel({super.key, required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: SelectableText(
        code,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 12,
          color: Color(0xFF34286E),
          height: 1.45,
        ),
      ),
    );
  }
}
