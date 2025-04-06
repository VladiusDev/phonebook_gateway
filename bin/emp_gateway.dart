import 'dart:async';
import 'dart:io';

import 'package:emp_gateway/config_manager.dart';
import 'package:emp_gateway/server.dart';
import 'package:get_it/get_it.dart';
import 'package:sentry/sentry.dart';

Future<void> main(List<String> args) async {
  GetIt.I.registerSingleton<ConfigManager>(ConfigManager.load());

  await runZonedGuarded(
    () async {
      final config = GetIt.I<ConfigManager>();

      await Sentry.init((options) {
        options.dsn = config.sentryDsn;
        options.tracesSampleRate = 1.0;
      }, appRunner: initApp);
    },
    (e, stack) async {
      await Sentry.captureException(e, stackTrace: stack);
    },
  );
}

void initApp() async {
  final server = EmployeeServer();
  await server.start();

  ProcessSignal.sigint.watch().listen((signal) {
    server.dispose();
    Sentry.close();
    exit(0);
  });
}
