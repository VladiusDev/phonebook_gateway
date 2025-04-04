import '../models/employee.dart';
import 'package:sqlite3/sqlite3.dart';

class SQLiteManager {
  late Database _database;

  SQLiteManager() {
    _initDatabase();
  }

  void _initDatabase() {
    _database = sqlite3.open('employees.db');

    _database.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee TEXT NOT NULL,
        employee_lower TEXT NOT NULL,
        tel TEXT NOT NULL,
        organization TEXT NOT NULL
      )
    ''');
  }

  Future<void> updateEmployees(List<Employee> employees) async {
    _database.execute('DELETE FROM employees');

    final stmt = _database.prepare(
        'INSERT INTO employees (employee, employee_lower, tel, organization) VALUES (?, ?, ?, ?)');

    for (var employee in employees) {
      stmt.execute([
        employee.name,
        employee.name.toLowerCase(),
        employee.tel,
        employee.organization
      ]);
    }

    stmt.dispose();
  }

  List<Employee> getEmployees([String? query]) {
    final ResultSet result;

    if (query != null && query.isNotEmpty) {
      result = _database.select(
          'SELECT employee, employee_lower, tel, organization FROM employees WHERE employee_lower LIKE ? OR tel LIKE ?',
          ['%$query%', '%$query%']);
    } else {
      result = _database.select(
          'SELECT employee, employee_lower, tel, organization FROM employees');
    }

    return result
        .map((row) => Employee(
              name: row['employee'] as String,
              nameLower: row['employee_lower'] as String,
              tel: row['tel'] as String,
              organization: row['organization'] as String,
            ))
        .toList();
  }

  void dispose() {
    _database.dispose();
  }
}
