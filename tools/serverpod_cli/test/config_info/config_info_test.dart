import 'dart:io';

import 'package:serverpod_cli/src/config_info/config_info.dart';
import 'package:test/test.dart';

void main() {
  group('Given a server config with insights on port 8081,', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('config_info_test_');
      final configDir = Directory('${tempDir.path}/config');
      await configDir.create(recursive: true);
      await File('${configDir.path}/development.yaml').writeAsString('''
apiServer:
  port: 8080
  publicHost: localhost
  publicPort: 8080
  publicScheme: http

insightsServer:
  port: 8081
  publicHost: localhost
  publicPort: 8081
  publicScheme: http
''');
      await File('${configDir.path}/passwords.yaml').writeAsString('''
development:
  serviceSecret: test
''');
    });

    tearDown(() async {
      await tempDir.delete(recursive: true);
    });

    test(
      'when createServiceClient is called with an insights port override, '
      'then the client targets the overridden port.',
      () {
        final client = ConfigInfo(
          'development',
          serverDir: tempDir.path,
        ).createServiceClient(insightsPortOverride: 9123);

        expect(client.host, 'http://localhost:9123/');
        client.close();
      },
    );
  });
}
