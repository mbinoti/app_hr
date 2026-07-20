import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';

import '../../hr_seed/hr_firestore_importer.dart';
import '../../ui/core/formatters.dart';
import '../../ui/core/theme/app_colors.dart';
import '../models/hr_query_definition.dart';

abstract class HrRepository {
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrganizationSummary();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchEmployees({
    String? department,
    String? job,
    required bool salaryDescending,
  });

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDepartments();

  Stream<QuerySnapshot<Map<String, dynamic>>> watchDepartmentEmployees(
    Object? departmentId,
  );

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSimpleCollection(
    String collection,
    String orderBy,
  );

  Future<List<String>> distinctEmployeeValues(String field);

  Future<HrImportResult> importHrData();

  List<HrQueryDefinition> queryDefinitions();
}

class FirestoreHrRepository implements HrRepository {
  FirestoreHrRepository({this.firestore, HrFirestoreImporter? importer})
    : _importer = importer ?? HrFirestoreImporter();

  final FirebaseFirestore? firestore;
  final HrFirestoreImporter _importer;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> watchOrganizationSummary() {
    return _db.doc('organizationSummary/global').snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchEmployees({
    String? department,
    String? job,
    required bool salaryDescending,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('employees');
    if (department != null) {
      query = query.where('departmentName', isEqualTo: department);
    }
    if (job != null) {
      query = query.where('jobTitle', isEqualTo: job);
    }
    return query.orderBy('salary', descending: salaryDescending).snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDepartments() {
    return _db
        .collection('departments')
        .orderBy('employeeCount', descending: true)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchDepartmentEmployees(
    Object? departmentId,
  ) {
    return _db
        .collection('employees')
        .where('departmentId', isEqualTo: departmentId)
        .orderBy('salary', descending: true)
        .snapshots();
  }

  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> watchSimpleCollection(
    String collection,
    String orderBy,
  ) {
    return _db.collection(collection).orderBy(orderBy).snapshots();
  }

  @override
  Future<List<String>> distinctEmployeeValues(String field) async {
    final snapshot = await _db.collection('employees').orderBy(field).get();
    return snapshot.docs
        .map((doc) => doc.data()[field])
        .whereType<String>()
        .toSet()
        .toList();
  }

  @override
  Future<HrImportResult> importHrData() {
    return _importer.importFromAsset();
  }

  @override
  List<HrQueryDefinition> queryDefinitions() => [
    HrQueryDefinition(
      title: 'Top 10 maiores salarios',
      subtitle: 'Veja os funcionarios com maiores salarios',
      icon: CupertinoIcons.chart_bar_alt_fill,
      color: AppColors.brand,
      firestoreQuery: _db
          .collection('employees')
          .orderBy('salary', descending: true)
          .limit(10),
      sql:
          'SELECT first_name, last_name, job_title, salary\nFROM employees e\nJOIN jobs j ON e.job_id = j.job_id\nORDER BY salary DESC\nFETCH FIRST 10 ROWS ONLY;',
      primaryColumn: 'Funcionario',
      secondaryColumn: 'Cargo',
      valueColumn: 'Salario',
      cells: (data, index) => [
        '$index',
        '${data['fullName'] ?? '-'}',
        '${data['jobTitle'] ?? '-'}',
        formatMoney(data['salary']),
      ],
    ),
    HrQueryDefinition(
      title: 'Media salarial por departamento',
      subtitle: 'Agrupar e calcular a media salarial',
      icon: CupertinoIcons.money_dollar_circle_fill,
      color: AppColors.rose,
      firestoreQuery: _db
          .collection('departments')
          .orderBy('averageSalary', descending: true)
          .limit(10),
      sql:
          'SELECT department_name, AVG(salary)\nFROM employees e\nJOIN departments d ON e.department_id = d.department_id\nGROUP BY department_name\nORDER BY AVG(salary) DESC;',
      primaryColumn: 'Departamento',
      secondaryColumn: 'Gerente',
      valueColumn: 'Media',
      cells: (data, index) => [
        '$index',
        '${data['departmentName'] ?? '-'}',
        '${data['managerName'] ?? '-'}',
        formatMoney(data['averageSalary']),
      ],
    ),
    HrQueryDefinition(
      title: 'Funcionarios por departamento',
      subtitle: 'Lista de funcionarios por departamento',
      icon: CupertinoIcons.building_2_fill,
      color: AppColors.mint,
      firestoreQuery: _db
          .collection('departments')
          .orderBy('employeeCount', descending: true)
          .limit(10),
      sql:
          'SELECT department_name, COUNT(*)\nFROM employees e\nJOIN departments d ON e.department_id = d.department_id\nGROUP BY department_name\nORDER BY COUNT(*) DESC;',
      primaryColumn: 'Departamento',
      secondaryColumn: 'Local',
      valueColumn: 'Qtd',
      cells: (data, index) => [
        '$index',
        '${data['departmentName'] ?? '-'}',
        departmentLocation(data),
        '${data['employeeCount'] ?? 0}',
      ],
    ),
    HrQueryDefinition(
      title: 'Funcionarios sem comissao',
      subtitle: 'Funcionarios que nao recebem comissao',
      icon: CupertinoIcons.person_crop_circle_badge_xmark,
      color: AppColors.muted,
      firestoreQuery: _db
          .collection('employees')
          .where('commissionPct', isNull: true)
          .orderBy('salary', descending: true)
          .limit(10),
      sql:
          'SELECT first_name, last_name, job_title, salary\nFROM employees e\nJOIN jobs j ON e.job_id = j.job_id\nWHERE commission_pct IS NULL\nORDER BY salary DESC;',
      primaryColumn: 'Funcionario',
      secondaryColumn: 'Cargo',
      valueColumn: 'Salario',
      cells: (data, index) => [
        '$index',
        '${data['fullName'] ?? '-'}',
        '${data['jobTitle'] ?? '-'}',
        formatMoney(data['salary']),
      ],
    ),
    HrQueryDefinition(
      title: 'Departamentos por pais',
      subtitle: 'Quantidade de departamentos por pais',
      icon: CupertinoIcons.cube_box_fill,
      color: AppColors.mint,
      firestoreQuery: _db
          .collection('countries')
          .orderBy('locationCount', descending: true)
          .limit(10),
      sql:
          'SELECT country_name, COUNT(department_id)\nFROM countries c\nJOIN locations l ON c.country_id = l.country_id\nJOIN departments d ON l.location_id = d.location_id\nGROUP BY country_name;',
      primaryColumn: 'Pais',
      secondaryColumn: 'Regiao',
      valueColumn: 'Locais',
      cells: (data, index) => [
        '$index',
        '${data['countryName'] ?? '-'}',
        '${data['regionName'] ?? '-'}',
        '${data['locationCount'] ?? 0}',
      ],
    ),
    HrQueryDefinition(
      title: 'Quantidade de funcionarios por cargo',
      subtitle: 'Agrupar funcionarios por cargo',
      icon: CupertinoIcons.person_2_fill,
      color: AppColors.brand,
      firestoreQuery: _db
          .collection('jobs')
          .orderBy('employeeCount', descending: true)
          .limit(10),
      sql:
          'SELECT job_title, COUNT(*)\nFROM employees e\nJOIN jobs j ON e.job_id = j.job_id\nGROUP BY job_title\nORDER BY COUNT(*) DESC;',
      primaryColumn: 'Cargo',
      secondaryColumn: 'Faixa',
      valueColumn: 'Qtd',
      cells: (data, index) => [
        '$index',
        '${data['jobTitle'] ?? '-'}',
        '${formatMoney(data['minSalary'])} - ${formatMoney(data['maxSalary'])}',
        '${data['employeeCount'] ?? 0}',
      ],
    ),
  ];
}
