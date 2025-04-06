import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:yaml/yaml.dart';

class ConfigManager {
  final String ip;
  final int port;
  final String mysqlHost;
  final int mysqlPort;
  final String mysqlUser;
  final String mysqlPassword;
  final String mysqlDatabase;
  final String sentryDsn;

  ConfigManager._({
    required this.ip,
    required this.port,
    required this.mysqlHost,
    required this.mysqlPort,
    required this.mysqlUser,
    required this.mysqlPassword,
    required this.mysqlDatabase,
    required this.sentryDsn,
  });

  factory ConfigManager.load() {
    final binDir = path.dirname(Platform.resolvedExecutable);
    final filePath = path.join(binDir, 'config.yaml');
    final yaml = loadYaml(File(filePath).readAsStringSync()) as YamlMap;

    return ConfigManager._(
      ip: yaml['http_server']['ip'],
      port: yaml['http_server']['port'],
      mysqlHost: yaml['my_sql_server']['host'],
      mysqlPort: yaml['my_sql_server']['port'],
      mysqlUser: yaml['my_sql_server']['user'],
      mysqlPassword: yaml['my_sql_server']['password'],
      mysqlDatabase: yaml['my_sql_server']['database'],
      sentryDsn: yaml['sentry']['dsn'],
    );
  }
}
