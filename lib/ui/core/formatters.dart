import 'package:cloud_firestore/cloud_firestore.dart';

String formatInt(Object? value) {
  if (value is num) return value.round().toString();
  return '0';
}

String formatMoney(Object? value) {
  final number = value is num ? value.round() : 0;
  final text = number.toString().replaceAllMapped(
    RegExp(r'(\d)(?=(\d{3})+$)'),
    (match) => '${match[1]}.',
  );
  return '\$$text';
}

String formatDate(Object? value) {
  DateTime? date;
  if (value is Timestamp) date = value.toDate();
  if (value is DateTime) date = value;
  if (date == null) return '-';
  return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String locationLine(Map<String, dynamic> data) {
  return [
    data['city'],
    data['stateProvince'],
    data['countryName'],
  ].whereType<String>().where((text) => text.isNotEmpty).join(', ');
}

String departmentLocation(Map<String, dynamic> data) {
  return [
    data['city'],
    data['countryName'],
  ].whereType<String>().where((text) => text.isNotEmpty).join(', ');
}
