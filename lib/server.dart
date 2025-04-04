import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:yaml/yaml.dart';
import 'database/mysql_connector.dart';
import 'database/sqlite_manager.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:path/path.dart' as path;

class EmployeeServer {
  final MySQLConnector mysqlConnector = MySQLConnector();
  final SQLiteManager sqliteManager = SQLiteManager();

  EmployeeServer() {
    _startPeriodicSync();
  }

  void _startPeriodicSync() {
    Timer.periodic(const Duration(hours: 12), (timer) async {
      try {
        print('${DateTime.now()} Sync employees started...');

        final employees = await mysqlConnector.fetchEmployees();
        await sqliteManager.updateEmployees(employees);

        print('${DateTime.now()} Sync employees comleted.');
      } catch (e) {
        print('${DateTime.now()} Sync employees error: $e');
      }
    });

    _syncEmployees();
  }

  Future<void> _syncEmployees() async {
    try {
      final employees = await mysqlConnector.fetchEmployees();
      await sqliteManager.updateEmployees(employees);
    } catch (e) {
      print('${DateTime.now()} Sync employees error: $e');
    }
  }

  Handler get handler {
    final router = Router();

    router.get('/employees', (Request request) {
      final String? query = request.url.queryParameters['query']?.toLowerCase();
      final employees = sqliteManager.getEmployees(query);
      final jsonData = jsonEncode(employees.map((e) => e.toMap()).toList());

      print('${DateTime.now()} GET request $query');

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
    final config = loadConfig();
    final server = await io.serve(handler, config['ip'], config['port']);
    print(
        '${DateTime.now()} Server started ${server.address.host}:${server.port}');
  }

  static Map<String, dynamic> loadConfig() {
    final binDir = path.dirname(Platform.resolvedExecutable);
    final filePath = path.join(binDir, 'config.yaml');
    final yaml = loadYaml(File(filePath).readAsStringSync()) as YamlMap;

    return {
      'ip': yaml['http_server']['ip'],
      'port': yaml['http_server']['port'],
      'mysql_host': yaml['my_sql_server']['host'],
      'mysql_port': yaml['my_sql_server']['port'],
      'mysql_user': yaml['my_sql_server']['user'],
      'mysql_password': yaml['my_sql_server']['password'],
      'mysql_database': yaml['my_sql_server']['database'],
    };
  }

  void dispose() {
    sqliteManager.dispose();
  }
}
