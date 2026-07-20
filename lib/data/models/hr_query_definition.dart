import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/widgets.dart';

class HrQueryDefinition {
  const HrQueryDefinition({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.firestoreQuery,
    required this.sql,
    required this.primaryColumn,
    required this.secondaryColumn,
    required this.valueColumn,
    required this.cells,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Query<Map<String, dynamic>> firestoreQuery;
  final String sql;
  final String primaryColumn;
  final String secondaryColumn;
  final String valueColumn;
  final List<String> Function(Map<String, dynamic> data, int index) cells;
}
