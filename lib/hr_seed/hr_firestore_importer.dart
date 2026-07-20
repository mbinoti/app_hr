import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class HrFirestoreImporter {
  HrFirestoreImporter({this.firestore});

  final FirebaseFirestore? firestore;

  FirebaseFirestore get _db => firestore ?? FirebaseFirestore.instance;

  Future<HrImportResult> importFromAsset({
    String assetPath = 'assets/hr/hr_populate.sql',
    bool clearExisting = false,
  }) async {
    final sql = await rootBundle.loadString(assetPath);
    final relational = _HrSqlParser(sql).parse();
    final model = _HrFirestoreModel.fromRelational(relational);

    if (clearExisting) {
      await _clearMainCollections();
    }

    await _writeModel(model);

    return HrImportResult(
      regions: model.regions.length,
      countries: model.countries.length,
      locations: model.locations.length,
      departments: model.departments.length,
      jobs: model.jobs.length,
      employees: model.employees.length,
      jobHistory: model.jobHistory.length,
    );
  }

  Future<void> _writeModel(_HrFirestoreModel model) async {
    final writes = <_Write>[];

    void addCollection(String collection, List<_Doc> docs) {
      for (final doc in docs) {
        writes.add(_Write('$collection/${doc.id}', doc.data));
      }
    }

    addCollection('regions', model.regions);
    addCollection('countries', model.countries);
    addCollection('locations', model.locations);
    addCollection('departments', model.departments);
    addCollection('jobs', model.jobs);

    for (final employee in model.employees) {
      writes.add(_Write('employees/${employee.id}', employee.data));
      for (final history in employee.histories) {
        writes.add(
          _Write(
            'employees/${employee.id}/jobHistory/${history.id}',
            history.data,
          ),
        );
      }
    }

    addCollection('jobHistory', model.jobHistory);
    writes.add(
      _Write(
        'organizationSummary/${model.organizationSummary.id}',
        model.organizationSummary.data,
      ),
    );

    for (var start = 0; start < writes.length; start += 450) {
      final batch = _db.batch();
      for (final write in writes.skip(start).take(450)) {
        batch.set(_db.doc(write.path), write.data);
      }
      await batch.commit();
    }
  }

  Future<void> _clearMainCollections() async {
    for (final collection in [
      'regions',
      'countries',
      'locations',
      'departments',
      'jobs',
      'employees',
      'jobHistory',
      'organizationSummary',
    ]) {
      await _deleteCollection(collection);
    }
  }

  Future<void> _deleteCollection(String collectionPath) async {
    final snapshot = await _db.collection(collectionPath).limit(450).get();
    if (snapshot.docs.isEmpty) {
      return;
    }

    final batch = _db.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    await _deleteCollection(collectionPath);
  }
}

class HrImportResult {
  const HrImportResult({
    required this.regions,
    required this.countries,
    required this.locations,
    required this.departments,
    required this.jobs,
    required this.employees,
    required this.jobHistory,
  });

  final int regions;
  final int countries;
  final int locations;
  final int departments;
  final int jobs;
  final int employees;
  final int jobHistory;

  int get totalDocuments =>
      regions +
      countries +
      locations +
      departments +
      jobs +
      employees +
      jobHistory +
      1;
}

class _HrSqlParser {
  _HrSqlParser(this.sql);

  final String sql;

  static const _columns = <String, List<String>>{
    'regions': ['regionId', 'regionName'],
    'countries': ['countryId', 'countryName', 'regionId'],
    'locations': [
      'locationId',
      'streetAddress',
      'postalCode',
      'city',
      'stateProvince',
      'countryId',
    ],
    'departments': [
      'departmentId',
      'departmentName',
      'managerId',
      'locationId',
    ],
    'jobs': ['jobId', 'jobTitle', 'minSalary', 'maxSalary'],
    'employees': [
      'employeeId',
      'firstName',
      'lastName',
      'email',
      'phoneNumber',
      'hireDate',
      'jobId',
      'salary',
      'commissionPct',
      'managerId',
      'departmentId',
    ],
    'job_history': [
      'employeeId',
      'startDate',
      'endDate',
      'jobId',
      'departmentId',
    ],
  };

  _RelationalHr parse() {
    final rows = {
      for (final table in _columns.keys) table: <Map<String, Object?>>[],
    };
    final insertPattern = RegExp(
      r'INSERT\s+INTO\s+(\w+)(?:\s+VALUES)?\s*\(([\s\S]*?)\)\s*;',
      caseSensitive: false,
      multiLine: true,
    );

    for (final match in insertPattern.allMatches(sql)) {
      final table = match.group(1)!.toLowerCase();
      final columns = _columns[table];
      if (columns == null) {
        continue;
      }

      final values = _splitValues(match.group(2)!).map(_parseValue).toList();
      if (values.length != columns.length) {
        throw StateError(
          'Quantidade inesperada de colunas em $table: '
          '${values.length}/${columns.length}',
        );
      }

      rows[table]!.add({
        for (var i = 0; i < columns.length; i++) columns[i]: values[i],
      });
    }

    return _RelationalHr(rows);
  }

  List<String> _splitValues(String input) {
    final values = <String>[];
    final buffer = StringBuffer();
    var quote = false;
    var depth = 0;

    for (var i = 0; i < input.length; i++) {
      final char = input[i];
      final next = i + 1 < input.length ? input[i + 1] : '';

      if (quote) {
        buffer.write(char);
        if (char == "'" && next == "'") {
          buffer.write(next);
          i++;
        } else if (char == "'") {
          quote = false;
        }
        continue;
      }

      if (char == "'") {
        quote = true;
        buffer.write(char);
      } else if (char == '(') {
        depth++;
        buffer.write(char);
      } else if (char == ')') {
        depth--;
        buffer.write(char);
      } else if (char == ',' && depth == 0) {
        values.add(buffer.toString().trim());
        buffer.clear();
      } else {
        buffer.write(char);
      }
    }

    final last = buffer.toString().trim();
    if (last.isNotEmpty) {
      values.add(last);
    }
    return values;
  }

  Object? _parseValue(String value) {
    if (value.toUpperCase() == 'NULL') {
      return null;
    }

    final dateMatch = RegExp(
      r"^TO_DATE\('(\d{2})-(\d{2})-(\d{4})',\s*'dd-MM-yyyy'\)$",
      caseSensitive: false,
    ).firstMatch(value);
    if (dateMatch != null) {
      final day = int.parse(dateMatch.group(1)!);
      final month = int.parse(dateMatch.group(2)!);
      final year = int.parse(dateMatch.group(3)!);
      return Timestamp.fromDate(DateTime.utc(year, month, day));
    }

    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1).replaceAll("''", "'");
    }

    final number = num.tryParse(value);
    if (number != null) {
      return number % 1 == 0 ? number.toInt() : number;
    }

    throw StateError('Valor SQL nao suportado: $value');
  }
}

class _RelationalHr {
  _RelationalHr(this.rows);

  final Map<String, List<Map<String, Object?>>> rows;

  List<Map<String, Object?>> operator [](String table) => rows[table]!;
}

class _HrFirestoreModel {
  _HrFirestoreModel({
    required this.regions,
    required this.countries,
    required this.locations,
    required this.departments,
    required this.jobs,
    required this.employees,
    required this.jobHistory,
    required this.organizationSummary,
  });

  final List<_Doc> regions;
  final List<_Doc> countries;
  final List<_Doc> locations;
  final List<_Doc> departments;
  final List<_Doc> jobs;
  final List<_EmployeeDoc> employees;
  final List<_Doc> jobHistory;
  final _Doc organizationSummary;

  factory _HrFirestoreModel.fromRelational(_RelationalHr data) {
    final regionsById = _mapBy(data['regions'], 'regionId');
    final countriesById = _mapBy(data['countries'], 'countryId');
    final locationsById = _mapBy(data['locations'], 'locationId');
    final departmentsById = _mapBy(data['departments'], 'departmentId');
    final jobsById = _mapBy(data['jobs'], 'jobId');
    final employeesById = _mapBy(data['employees'], 'employeeId');

    final countryCounts = _countBy(data['countries'], 'regionId');
    final locationCounts = _countBy(data['locations'], 'countryId');
    final departmentCounts = _countBy(data['departments'], 'locationId');
    final employeesByDepartment = _groupBy(data['employees'], 'departmentId');
    final employeesByJob = _groupBy(data['employees'], 'jobId');
    final now = Timestamp.now();

    final regionDocs = data['regions']
        .map(
          (region) => _Doc('${region['regionId']}', {
            ...region,
            'countryCount': countryCounts[region['regionId']] ?? 0,
          }),
        )
        .toList();

    final countryDocs = data['countries'].map((country) {
      final region = regionsById[country['regionId']];
      return _Doc('${country['countryId']}', {
        ...country,
        'regionName': region?['regionName'],
        'locationCount': locationCounts[country['countryId']] ?? 0,
      });
    }).toList();

    final locationDocs = data['locations'].map((location) {
      final country = countriesById[location['countryId']];
      final region = country == null ? null : regionsById[country['regionId']];
      return _Doc('${location['locationId']}', {
        ...location,
        'countryName': country?['countryName'],
        'regionId': country?['regionId'],
        'regionName': region?['regionName'],
        'departmentCount': departmentCounts[location['locationId']] ?? 0,
      });
    }).toList();

    final departmentDocs = data['departments'].map((department) {
      final location = locationsById[department['locationId']];
      final country = location == null
          ? null
          : countriesById[location['countryId']];
      final region = country == null ? null : regionsById[country['regionId']];
      final manager = employeesById[department['managerId']];
      final members = employeesByDepartment[department['departmentId']] ?? [];
      final salaries = members.map((item) => item['salary']).whereType<num>();

      return _Doc('${department['departmentId']}', {
        ...department,
        'managerName': manager == null ? null : _fullName(manager),
        'city': location?['city'],
        'countryId': country?['countryId'],
        'countryName': country?['countryName'],
        'regionId': region?['regionId'],
        'regionName': region?['regionName'],
        'employeeCount': members.length,
        'averageSalary': _average(salaries),
        'totalSalary': _sum(salaries),
      });
    }).toList();

    final jobDocs = data['jobs']
        .map(
          (job) => _Doc('${job['jobId']}', {
            ...job,
            'employeeCount': employeesByJob[job['jobId']]?.length ?? 0,
          }),
        )
        .toList();

    final employeeDocs = data['employees'].map((employee) {
      final job = jobsById[employee['jobId']];
      final manager = employeesById[employee['managerId']];
      final department = departmentsById[employee['departmentId']];
      final location = department == null
          ? null
          : locationsById[department['locationId']];
      final country = location == null
          ? null
          : countriesById[location['countryId']];
      final region = country == null ? null : regionsById[country['regionId']];

      final histories = data['job_history']
          .where((history) => history['employeeId'] == employee['employeeId'])
          .map((history) {
            final historyJob = jobsById[history['jobId']];
            final historyDepartment = departmentsById[history['departmentId']];
            return _Doc(
              '${history['employeeId']}_${(history['startDate'] as Timestamp).seconds}',
              {
                ...history,
                'jobTitle': historyJob?['jobTitle'],
                'departmentName': historyDepartment?['departmentName'],
              },
            );
          })
          .toList();

      return _EmployeeDoc('${employee['employeeId']}', {
        ...employee,
        'fullName': _fullName(employee),
        'jobTitle': job?['jobTitle'],
        'managerName': manager == null ? null : _fullName(manager),
        'departmentName': department?['departmentName'],
        'locationId': location?['locationId'],
        'city': location?['city'],
        'stateProvince': location?['stateProvince'],
        'countryId': country?['countryId'],
        'countryName': country?['countryName'],
        'regionId': region?['regionId'],
        'regionName': region?['regionName'],
        'searchKeywords': _searchKeywords(employee, job, department),
        'active': true,
        'createdAt': now,
        'updatedAt': now,
      }, histories);
    }).toList();

    final globalHistory = employeeDocs
        .expand(
          (employee) => employee.histories.map(
            (history) => _Doc(history.id, {
              ...history.data,
              'employeeName': employee.data['fullName'],
            }),
          ),
        )
        .toList();

    final salaries = data['employees']
        .map((item) => item['salary'])
        .whereType<num>();
    final salaryList = salaries.toList();
    final summary = _Doc('global', {
      'totalEmployees': data['employees'].length,
      'totalDepartments': data['departments'].length,
      'totalJobs': data['jobs'].length,
      'totalCountries': data['countries'].length,
      'totalLocations': data['locations'].length,
      'averageSalary': _average(salaryList),
      'highestSalary': salaryList.reduce((a, b) => a > b ? a : b),
      'lowestSalary': salaryList.reduce((a, b) => a < b ? a : b),
      'updatedAt': now,
    });

    return _HrFirestoreModel(
      regions: regionDocs,
      countries: countryDocs,
      locations: locationDocs,
      departments: departmentDocs,
      jobs: jobDocs,
      employees: employeeDocs,
      jobHistory: globalHistory,
      organizationSummary: summary,
    );
  }

  static Map<Object?, Map<String, Object?>> _mapBy(
    List<Map<String, Object?>> rows,
    String key,
  ) {
    return {for (final row in rows) row[key]: row};
  }

  static Map<Object?, List<Map<String, Object?>>> _groupBy(
    List<Map<String, Object?>> rows,
    String key,
  ) {
    final groups = <Object?, List<Map<String, Object?>>>{};
    for (final row in rows) {
      final value = row[key];
      if (value == null) {
        continue;
      }
      groups.putIfAbsent(value, () => []).add(row);
    }
    return groups;
  }

  static Map<Object?, int> _countBy(
    List<Map<String, Object?>> rows,
    String key,
  ) {
    final counts = <Object?, int>{};
    for (final row in rows) {
      counts[row[key]] = (counts[row[key]] ?? 0) + 1;
    }
    return counts;
  }

  static String _fullName(Map<String, Object?> employee) {
    return '${employee['firstName']} ${employee['lastName']}';
  }

  static List<String> _searchKeywords(
    Map<String, Object?> employee,
    Map<String, Object?>? job,
    Map<String, Object?>? department,
  ) {
    final values = [
      employee['firstName'],
      employee['lastName'],
      _fullName(employee),
      employee['email'],
      job?['jobTitle'],
      department?['departmentName'],
    ].whereType<String>();

    return values
        .expand((value) => value.toLowerCase().split(RegExp(r'\s+')))
        .toSet()
        .toList();
  }

  static num _sum(Iterable<num> values) {
    return values.fold<num>(0, (total, value) => total + value);
  }

  static num _average(Iterable<num> values) {
    final list = values.toList();
    if (list.isEmpty) {
      return 0;
    }
    return (_sum(list) / list.length * 100).round() / 100;
  }
}

class _Doc {
  const _Doc(this.id, this.data);

  final String id;
  final Map<String, Object?> data;
}

class _EmployeeDoc extends _Doc {
  const _EmployeeDoc(super.id, super.data, this.histories);

  final List<_Doc> histories;
}

class _Write {
  const _Write(this.path, this.data);

  final String path;
  final Map<String, Object?> data;
}
