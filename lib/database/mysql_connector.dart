import 'package:emp_gateway/server.dart';
import '../models/employee.dart';
import 'package:mysql_client/mysql_client.dart';

class MySQLConnector {
  Future<List<Employee>> fetchEmployees() async {
    final config = EmployeeServer.loadConfig();

    final conn = await MySQLConnection.createConnection(
        host: config['mysql_host'],
        port: config['mysql_port'],
        userName: config['mysql_user'],
        password: config['mysql_password'],
        databaseName: config['mysql_database']);
    try {
      await conn.connect();

      final result = await conn.execute(
          'SELECT employee, "" as employee_lower, tel, organization FROM employee');
      final employees =
          result.rows.map((row) => Employee.fromMap(row.assoc())).toList();

      await conn.close();

      return employees;
    } catch (e) {
      throw Exception(e);
    }
  }
}
