import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/generated/protocol.dart' as internal;
import 'package:test/test.dart';

import 'test_helpers/empty_endpoints.dart';

final portZeroConfig = ServerConfig(
  port: 0,
  publicScheme: 'http',
  publicHost: 'localhost',
  publicPort: 0,
);

void main() {
  late Directory tempDir;
  late String databasePath;
  late Serverpod pod;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('transaction_for_user_');
    databasePath = p.join(tempDir.path, 'test.db');

    pod = Serverpod(
      [],
      internal.Protocol(),
      EmptyEndpoints(),
      config: ServerpodConfig(
        apiServer: portZeroConfig,
        webServer: portZeroConfig,
        database: SqliteDatabaseConfig(filePath: databasePath),
      ),
    );
  });

  tearDown(() async {
    await pod.shutdown(exitProcess: false);
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Given an unauthenticated session, ', () {
    late Session session;

    setUp(() async {
      session = await pod.createSession();
    });

    test(
      'when transactionForUserSettings is read, '
      'then it is null.',
      () {
        expect(session.transactionForUserSettings, isNull);
      },
    );

    test(
      'when db.transactionForUser is called, '
      'then a StateError is thrown.',
      () {
        expect(
          () => session.db.transactionForUser((_) async => null),
          throwsA(isA<StateError>()),
        );
      },
    );
  });

  group('Given an authenticated session, ', () {
    late Session session;
    const userId = '123e4567-e89b-12d3-a456-426614174000';

    setUp(() async {
      session = await pod.createSession();
      session.updateAuthenticated(
        AuthenticationInfo(
          userId,
          {},
          authId: 'auth-id',
        ),
      );
    });

    test(
      'when transactionForUserSettings is read, '
      'then it exposes the user id as serverpod.user_id.',
      () {
        expect(
          session.transactionForUserSettings,
          {'serverpod.user_id': userId},
        );
      },
    );

    test(
      'when db.transactionForUser is called, '
      'then the user settings are applied as runtime parameters.',
      () async {
        var runtimeParameters = await session.db.transactionForUser(
          (transaction) async => transaction.runtimeParameters,
        );

        expect(runtimeParameters['serverpod.user_id'], userId);
      },
    );

    test(
      'when db.transactionForUser is called, '
      'then the transaction function result is returned.',
      () async {
        var result = await session.db.transactionForUser(
          (_) async => 'done',
        );

        expect(result, 'done');
      },
    );
  });
}
