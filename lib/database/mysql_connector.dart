import 'package:emp_gateway/config_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry/sentry.dart';
import '../models/employee.dart';
import 'package:mysql_client/mysql_client.dart';

class MySQLConnector {
  Future<List<Employee>> fetchEmployees() async {
    final config = GetIt.I<ConfigManager>();

    final conn = await MySQLConnection.createConnection(
        host: config.mysqlHost,
        port: config.mysqlPort,
        userName: config.mysqlUser,
        password: config.mysqlPassword,
        databaseName: config.mysqlDatabase);

    final transaction = Sentry.startTransaction('MySQL_Connector', 'Execute',
        bindToScope: true);

    try {
      await conn.connect();

      final result = await conn.execute(
          'SELECT employee, "" as employee_lower, tel, organization FROM employee');
      final employees =
          result.rows.map((row) => Employee.fromMap(row.assoc())).toList();

      await conn.close();

      transaction.setData(
          'mysql_status_info', '${DateTime.now()} Execute completed.');
      await transaction.finish(status: SpanStatus.ok());

      return employees;
    } catch (e, stack) {
      await Sentry.captureException('${DateTime.now()} MySQL update failed: $e',
          stackTrace: stack);

      throw Exception(e);
    }
  }
}
