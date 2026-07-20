#!/usr/bin/env node

import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const repoRoot = path.resolve(__dirname, '..');

const defaultSqlPath = path.resolve(
  repoRoot,
  '../../db-sample-schemas/human_resources/hr_populate.sql',
);

const args = new Set(process.argv.slice(2));
const dryRun = args.has('--dry-run');
const clearExisting = args.has('--clear');
const sqlPath = getArgValue('--sql') ?? defaultSqlPath;
const projectId = getArgValue('--project-id') ?? process.env.FIREBASE_PROJECT_ID ?? 'hr-oracle';

const tableColumns = {
  regions: ['regionId', 'regionName'],
  countries: ['countryId', 'countryName', 'regionId'],
  locations: [
    'locationId',
    'streetAddress',
    'postalCode',
    'city',
    'stateProvince',
    'countryId',
  ],
  departments: ['departmentId', 'departmentName', 'managerId', 'locationId'],
  jobs: ['jobId', 'jobTitle', 'minSalary', 'maxSalary'],
  employees: [
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
  job_history: ['employeeId', 'startDate', 'endDate', 'jobId', 'departmentId'],
};

const source = fs.readFileSync(sqlPath, 'utf8');
const rows = parseSql(source);
const model = buildFirestoreModel(rows);

printSummary(model, sqlPath);

if (dryRun) {
  console.log('\nDry run only. No Firestore writes were made.');
  process.exit(0);
}

const { default: admin } = await import('firebase-admin');
initializeAdmin(admin, projectId);
const firestore = admin.firestore();

if (clearExisting) {
  await clearCollections(firestore, [
    'regions',
    'countries',
    'locations',
    'departments',
    'jobs',
    'employees',
    'jobHistory',
    'organizationSummary',
  ]);
}

await writeModel(firestore, model);
console.log(`\nFirestore import finished for project "${projectId}".`);

function getArgValue(name) {
  const arg = process.argv.slice(2).find((item) => item.startsWith(`${name}=`));
  return arg ? arg.slice(name.length + 1) : undefined;
}

function parseSql(sql) {
  const result = Object.fromEntries(Object.keys(tableColumns).map((table) => [table, []]));
  const insertPattern = /INSERT\s+INTO\s+(\w+)(?:\s+VALUES)?\s*\(([\s\S]*?)\)\s*;/gi;
  let match;

  while ((match = insertPattern.exec(sql)) !== null) {
    const table = match[1].toLowerCase();
    const columns = tableColumns[table];
    if (!columns) {
      continue;
    }

    const values = splitValues(match[2]).map(parseValue);
    if (values.length !== columns.length) {
      throw new Error(
        `Column mismatch for ${table}: expected ${columns.length}, found ${values.length}`,
      );
    }

    result[table].push(Object.fromEntries(columns.map((column, index) => [column, values[index]])));
  }

  return result;
}

function splitValues(input) {
  const values = [];
  let current = '';
  let quote = false;
  let parenDepth = 0;

  for (let index = 0; index < input.length; index += 1) {
    const char = input[index];
    const next = input[index + 1];

    if (quote) {
      current += char;
      if (char === "'" && next === "'") {
        current += next;
        index += 1;
      } else if (char === "'") {
        quote = false;
      }
      continue;
    }

    if (char === "'") {
      quote = true;
      current += char;
      continue;
    }

    if (char === '(') {
      parenDepth += 1;
    } else if (char === ')') {
      parenDepth -= 1;
    }

    if (char === ',' && parenDepth === 0) {
      values.push(current.trim());
      current = '';
      continue;
    }

    current += char;
  }

  if (current.trim()) {
    values.push(current.trim());
  }

  return values;
}

function parseValue(value) {
  if (/^NULL$/i.test(value)) {
    return null;
  }

  const dateMatch = value.match(/^TO_DATE\('(\d{2})-(\d{2})-(\d{4})',\s*'dd-MM-yyyy'\)$/i);
  if (dateMatch) {
    const [, day, month, year] = dateMatch;
    return `${year}-${month}-${day}`;
  }

  if (value.startsWith("'") && value.endsWith("'")) {
    return value.slice(1, -1).replaceAll("''", "'");
  }

  const numberValue = Number(value);
  if (!Number.isNaN(numberValue)) {
    return numberValue;
  }

  throw new Error(`Unsupported SQL value: ${value}`);
}

function buildFirestoreModel(data) {
  const regions = mapBy(data.regions, 'regionId');
  const countries = mapBy(data.countries, 'countryId');
  const locations = mapBy(data.locations, 'locationId');
  const departments = mapBy(data.departments, 'departmentId');
  const jobs = mapBy(data.jobs, 'jobId');
  const employees = mapBy(data.employees, 'employeeId');

  const locationDepartmentCounts = countBy(data.departments, 'locationId');
  const countryLocationCounts = countBy(data.locations, 'countryId');
  const regionCountryCounts = countBy(data.countries, 'regionId');
  const departmentEmployees = groupBy(data.employees, 'departmentId');
  const jobEmployees = groupBy(data.employees, 'jobId');
  const now = new Date();

  const regionDocs = data.regions.map((region) => ({
    id: String(region.regionId),
    data: {
      ...region,
      countryCount: regionCountryCounts.get(region.regionId) ?? 0,
    },
  }));

  const countryDocs = data.countries.map((country) => {
    const region = regions.get(country.regionId);
    return {
      id: country.countryId,
      data: {
        ...country,
        regionName: region?.regionName ?? null,
        locationCount: countryLocationCounts.get(country.countryId) ?? 0,
      },
    };
  });

  const locationDocs = data.locations.map((location) => {
    const country = countries.get(location.countryId);
    const region = country ? regions.get(country.regionId) : null;
    return {
      id: String(location.locationId),
      data: {
        ...location,
        countryName: country?.countryName ?? null,
        regionId: country?.regionId ?? null,
        regionName: region?.regionName ?? null,
        departmentCount: locationDepartmentCounts.get(location.locationId) ?? 0,
      },
    };
  });

  const departmentDocs = data.departments.map((department) => {
    const location = locations.get(department.locationId);
    const country = location ? countries.get(location.countryId) : null;
    const region = country ? regions.get(country.regionId) : null;
    const manager = department.managerId ? employees.get(department.managerId) : null;
    const members = departmentEmployees.get(department.departmentId) ?? [];
    const salaries = members.map((employee) => employee.salary).filter(isFiniteNumber);
    return {
      id: String(department.departmentId),
      data: {
        ...department,
        managerName: manager ? fullName(manager) : null,
        city: location?.city ?? null,
        countryId: country?.countryId ?? null,
        countryName: country?.countryName ?? null,
        regionId: region?.regionId ?? null,
        regionName: region?.regionName ?? null,
        employeeCount: members.length,
        averageSalary: average(salaries),
        totalSalary: sum(salaries),
      },
    };
  });

  const jobDocs = data.jobs.map((job) => ({
    id: job.jobId,
    data: {
      ...job,
      employeeCount: (jobEmployees.get(job.jobId) ?? []).length,
    },
  }));

  const employeeDocs = data.employees.map((employee) => {
    const job = jobs.get(employee.jobId);
    const manager = employee.managerId ? employees.get(employee.managerId) : null;
    const department = employee.departmentId ? departments.get(employee.departmentId) : null;
    const location = department ? locations.get(department.locationId) : null;
    const country = location ? countries.get(location.countryId) : null;
    const region = country ? regions.get(country.regionId) : null;
    const histories = data.job_history
      .filter((history) => history.employeeId === employee.employeeId)
      .map((history) => {
        const historyJob = jobs.get(history.jobId);
        const historyDepartment = departments.get(history.departmentId);
        return {
          id: `${history.employeeId}_${history.startDate}`,
          data: {
            ...history,
            jobTitle: historyJob?.jobTitle ?? null,
            departmentName: historyDepartment?.departmentName ?? null,
          },
        };
      });

    return {
      id: String(employee.employeeId),
      data: {
        ...employee,
        fullName: fullName(employee),
        jobTitle: job?.jobTitle ?? null,
        managerName: manager ? fullName(manager) : null,
        departmentName: department?.departmentName ?? null,
        locationId: location?.locationId ?? null,
        city: location?.city ?? null,
        stateProvince: location?.stateProvince ?? null,
        countryId: country?.countryId ?? null,
        countryName: country?.countryName ?? null,
        regionId: region?.regionId ?? null,
        regionName: region?.regionName ?? null,
        searchKeywords: buildSearchKeywords(employee, job, department),
        active: true,
        createdAt: now,
        updatedAt: now,
      },
      histories,
    };
  });

  const globalJobHistoryDocs = employeeDocs.flatMap((employee) =>
    employee.histories.map((history) => ({
      id: history.id,
      data: {
        ...history.data,
        employeeName: employee.data.fullName,
      },
    })),
  );

  const salaries = data.employees.map((employee) => employee.salary).filter(isFiniteNumber);
  const organizationSummary = {
    id: 'global',
    data: {
      totalEmployees: data.employees.length,
      totalDepartments: data.departments.length,
      totalJobs: data.jobs.length,
      totalCountries: data.countries.length,
      totalLocations: data.locations.length,
      averageSalary: average(salaries),
      highestSalary: salaries.length ? Math.max(...salaries) : 0,
      lowestSalary: salaries.length ? Math.min(...salaries) : 0,
      updatedAt: now,
    },
  };

  return {
    regions: regionDocs,
    countries: countryDocs,
    locations: locationDocs,
    departments: departmentDocs,
    jobs: jobDocs,
    employees: employeeDocs,
    jobHistory: globalJobHistoryDocs,
    organizationSummary,
  };
}

function mapBy(items, key) {
  return new Map(items.map((item) => [item[key], item]));
}

function groupBy(items, key) {
  const groups = new Map();
  for (const item of items) {
    if (item[key] === null || item[key] === undefined) {
      continue;
    }
    const group = groups.get(item[key]) ?? [];
    group.push(item);
    groups.set(item[key], group);
  }
  return groups;
}

function countBy(items, key) {
  const counts = new Map();
  for (const item of items) {
    counts.set(item[key], (counts.get(item[key]) ?? 0) + 1);
  }
  return counts;
}

function fullName(employee) {
  return [employee.firstName, employee.lastName].filter(Boolean).join(' ');
}

function buildSearchKeywords(employee, job, department) {
  return Array.from(
    new Set(
      [
        employee.firstName,
        employee.lastName,
        fullName(employee),
        employee.email,
        job?.jobTitle,
        department?.departmentName,
      ]
        .filter(Boolean)
        .flatMap((value) => String(value).toLowerCase().split(/\s+/)),
    ),
  );
}

function isFiniteNumber(value) {
  return Number.isFinite(value);
}

function sum(values) {
  return values.reduce((total, value) => total + value, 0);
}

function average(values) {
  if (!values.length) {
    return 0;
  }
  return Math.round((sum(values) / values.length) * 100) / 100;
}

function initializeAdmin(admin, fallbackProjectId) {
  if (process.env.FIREBASE_SERVICE_ACCOUNT) {
    admin.initializeApp({
      credential: admin.credential.cert(JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT)),
    });
    return;
  }

  admin.initializeApp({
    credential: admin.credential.applicationDefault(),
    projectId: fallbackProjectId,
  });
}

async function writeModel(firestore, data) {
  const writes = [];

  for (const collection of ['regions', 'countries', 'locations', 'departments', 'jobs']) {
    for (const doc of data[collection]) {
      writes.push({ path: `${collection}/${doc.id}`, data: doc.data });
    }
  }

  for (const employee of data.employees) {
    writes.push({ path: `employees/${employee.id}`, data: employee.data });
    for (const history of employee.histories) {
      writes.push({
        path: `employees/${employee.id}/jobHistory/${history.id}`,
        data: history.data,
      });
    }
  }

  for (const history of data.jobHistory) {
    writes.push({ path: `jobHistory/${history.id}`, data: history.data });
  }

  writes.push({
    path: `organizationSummary/${data.organizationSummary.id}`,
    data: data.organizationSummary.data,
  });

  for (let start = 0; start < writes.length; start += 450) {
    const batch = firestore.batch();
    for (const write of writes.slice(start, start + 450)) {
      batch.set(firestore.doc(write.path), write.data);
    }
    await batch.commit();
  }
}

async function clearCollections(firestore, collections) {
  for (const collection of collections) {
    await deleteCollection(firestore, collection);
  }
}

async function deleteCollection(firestore, collectionPath) {
  const snapshot = await firestore.collection(collectionPath).limit(450).get();
  if (snapshot.empty) {
    return;
  }

  const batch = firestore.batch();
  snapshot.docs.forEach((doc) => batch.delete(doc.ref));
  await batch.commit();
  await deleteCollection(firestore, collectionPath);
}

function printSummary(data, sourcePath) {
  console.log(`Source SQL: ${sourcePath}`);
  console.log(`regions: ${data.regions.length}`);
  console.log(`countries: ${data.countries.length}`);
  console.log(`locations: ${data.locations.length}`);
  console.log(`departments: ${data.departments.length}`);
  console.log(`jobs: ${data.jobs.length}`);
  console.log(`employees: ${data.employees.length}`);
  console.log(`jobHistory: ${data.jobHistory.length}`);
  console.log(`organizationSummary: ${JSON.stringify(data.organizationSummary.data)}`);
}
