import 'dart:async';
import 'dart:convert';
import 'package:emp_gateway/config_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry/sentry.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'database/mysql_connector.dart';
import 'database/sqlite_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf_io.dart' as io;

class EmployeeServer {
  final MySQLConnector mysqlConnector = MySQLConnector();
  final SQLiteManager sqliteManager = SQLiteManager();

  EmployeeServer() {
    _syncEmployees();

    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    Timer.periodic(const Duration(hours: 12), (timer) async {
      try {
        _syncEmployees();
      } catch (e, stack) {
        await Sentry.captureException(
            '${DateTime.now()} Sync employees error: $e',
            stackTrace: stack);
      }
    });
  }

  Future<void> _syncEmployees() async {
    try {
      final transaction =
          Sentry.startTransaction('SYNC_EMPLOYEES', 'Start', bindToScope: true);
      transaction.setData(
          'sync_status_info', '${DateTime.now()} Server started');

      final employees = await mysqlConnector.fetchEmployees();
      await sqliteManager.updateEmployees(employees);

      transaction.finish(status: SpanStatus.ok());
    } catch (e, stack) {
      Sentry.captureException('${DateTime.now()} Sync employees error: $e',
          stackTrace: stack);
    }
  }

  Handler get handler {
    final router = Router();

    router.get('/employees', (Request request) {
      final String? query = request.url.queryParameters['query']?.toLowerCase();
      final employees = sqliteManager.getEmployees(query);
      final jsonData = jsonEncode(employees.map((e) => e.toMap()).toList());

      return Response.ok(
        jsonData,
        headers: {'Content-Type': 'application/json'},
      );
    });

    return const Pipeline()
        .addMiddleware(corsHeaders(
          headers: {
            'ACCESS_CONTROL_ALLOW_ORIGIN': '*',
            'ACCESS_CONTROL_ALLOW_METHODS': 'GET, POST, OPTIONS',
            'ACCESS_CONTROL_ALLOW_HEADERS':
                'Origin, Content-Type, Accept, X-Requested-With, User-Agent, DNT, If-Modified-Since, Cache-Control, Range, Authorization',
            'Access-Control-Allow-Credentials': 'true',
          },
        ))
        .addHandler(router.call);
  }

  Future<void> start() async {
    final transaction =
        Sentry.startTransaction('HTTP_SERVER', 'Start', bindToScope: true);

    try {
      final config = GetIt.I<ConfigManager>();
      final server = await io.serve(handler, config.ip, config.port);

      transaction.setData('server_status_info',
          '${DateTime.now()} Server started on ${server.address.host}:${server.port}');

      await transaction.finish(status: SpanStatus.ok());

      print(
          '${DateTime.now()} Server started on ${server.address.host}:${server.port}');
    } catch (e, stack) {
      Sentry.captureException(e, stackTrace: stack);

      print(e);
    }
  }

  void dispose() {
    sqliteManager.dispose();
  }
}
