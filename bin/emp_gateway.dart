import 'dart:io';

import 'package:emp_gateway/server.dart';

void main(List<String> args) async {
  final server = EmployeeServer();
  await server.start();

  ProcessSignal.sigint.watch().listen((signal) {
    server.dispose();
    exit(0);
  });
}
