import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/generated/protocol.dart' as internal;
import 'package:serverpod_database/serverpod_database.dart';
import 'package:test/test.dart';

import 'test_helpers/empty_endpoints.dart';

final portZeroConfig = ServerConfig(
  port: 0,
  publicScheme: 'http',
  publicHost: 'localhost',
  publicPort: 0,
);

class _CapturingDatabase implements Database {
  _CapturingDatabase(this.inner);

  final Database inner;
  ServerpodAuthContext? capturedAuthContext;

  @override
  DatabaseAnalyzer get analyzer => inner.analyzer;

  @override
  DatabaseDialect get dialect => inner.dialect;

  @override
  DatabaseSerializationManager get serializationManager =>
      inner.serializationManager;

  @override
  Future<bool> testConnection() => inner.testConnection();

  @override
  Future<R> transaction<R>(
    TransactionFunction<R> transactionFunction, {
    TransactionSettings? settings,
  }) {
    return inner.transaction((transaction) async {
      var capturingTransaction = _CapturingTransaction(
        transaction,
        (context) => capturedAuthContext = context,
      );
      return transactionFunction(capturingTransaction);
    }, settings: settings);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CapturingTransaction implements Transaction {
  _CapturingTransaction(this.inner, this.onAuthContext);

  final Transaction inner;
  final void Function(ServerpodAuthContext context) onAuthContext;

  @override
  Future<void> cancel() => inner.cancel();

  @override
  Future<Savepoint> createSavepoint() => inner.createSavepoint();

  @override
  Map<String, dynamic> get runtimeParameters => inner.runtimeParameters;

  @override
  Future<void> setRuntimeParameters(
    RuntimeParametersListBuilder builder,
  ) async {
    var parameters = builder(RuntimeParametersBuilder());
    for (var parameter in parameters) {
      if (parameter is ServerpodAuthContext) {
        onAuthContext(parameter);
      }
    }
    return inner.setRuntimeParameters(builder);
  }
}

void main() {
  late Directory tempDir;
  late String databasePath;
  late Serverpod pod;
  late _CapturingDatabase capturingDatabase;

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
      databaseInterceptor: (session, inner) {
        capturingDatabase = _CapturingDatabase(inner);
        return capturingDatabase;
      },
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
      'when transactionForUser is called, '
      'then a StateError is thrown.',
      () {
        expect(
          () => session.transactionForUser((_) async => null),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              contains('requires an authenticated session'),
            ),
          ),
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
      'when transactionForUser is called, '
      'then the authenticated user id is set as a runtime parameter.',
      () async {
        await session.transactionForUser((_) async => null);

        expect(capturingDatabase.capturedAuthContext?.userId, userId);
      },
    );

    test(
      'when transactionForUser is called, '
      'then the transaction function result is returned.',
      () async {
        var result = await session.transactionForUser((_) async => 'done');

        expect(result, 'done');
      },
    );
  });
}
