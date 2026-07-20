import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../../../data/models/hr_query_definition.dart';
import '../../../core/widgets/adaptive_progress.dart';
import '../../../core/widgets/back_glyph.dart';
import '../../../core/widgets/code_panel.dart';
import '../../../core/widgets/hr_page.dart';
import '../../../core/widgets/info_card.dart';
import '../../../core/widgets/panels.dart';
import '../widgets/table_cell_text.dart';

class QueryResultPage extends StatelessWidget {
  const QueryResultPage({
    super.key,
    required this.definition,
    required this.useCupertino,
  });

  final HrQueryDefinition definition;
  final bool useCupertino;

  @override
  Widget build(BuildContext context) {
    return HrPage(
      useCupertino: useCupertino,
      title: 'Resultado da Consulta',
      leading: BackGlyph(useCupertino: useCupertino),
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: definition.firestoreQuery.snapshots(),
        builder: (context, snapshot) {
          final docs = snapshot.data?.docs ?? [];
          return ListView(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 28),
            children: [
              Text(
                definition.title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              if (!snapshot.hasData)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: AdaptiveProgress()),
                ),
              if (snapshot.hasError) ErrorPanel(message: '${snapshot.error}'),
              if (snapshot.hasData)
                InfoCard(
                  padding: EdgeInsets.zero,
                  child: Table(
                    columnWidths: const {
                      0: FixedColumnWidth(32),
                      1: FlexColumnWidth(1.4),
                      2: FlexColumnWidth(1.2),
                      3: FlexColumnWidth(.9),
                    },
                    children: [
                      TableRow(
                        decoration: const BoxDecoration(
                          color: Color(0xFFF6F4FA),
                        ),
                        children:
                            [
                                  '#',
                                  definition.primaryColumn,
                                  definition.secondaryColumn,
                                  definition.valueColumn,
                                ]
                                .map(
                                  (text) => TableCellText(text, header: true),
                                )
                                .toList(),
                      ),
                      for (var i = 0; i < docs.length; i++)
                        TableRow(
                          children: definition
                              .cells(docs[i].data(), i + 1)
                              .map((text) => TableCellText(text))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {},
                      child: const Text('SQL'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('NoSQL'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CodePanel(code: definition.sql),
            ],
          );
        },
      ),
    );
  }
}
