import 'package:serverpod/serverpod.dart';
import 'package:serverpod/src/generated/endpoints.dart';
import 'package:serverpod/src/generated/protocol.dart' as internal;
import 'package:serverpod_shared/log.dart' as logging;
import 'package:test/test.dart';

void main() {
  late Serverpod pod;
  late logging.TestLogWriter writer;

  setUp(() async {
    final serverConfig = ServerConfig(
      port: 0,
      publicScheme: 'http',
      publicHost: 'localhost',
      publicPort: 0,
    );

    pod = Serverpod(
      [],
      internal.Protocol(),
      Endpoints(),
      config: ServerpodConfig(
        apiServer: serverConfig,
        webServer: serverConfig,
      ),
    );

    await logging.log.flush();
    writer = logging.TestLogWriter();
    logging.logWriter.add(writer);
  });

  tearDown(() async {
    logging.logWriter.remove(writer);
    await pod.shutdown(exitProcess: false);
  });

  group('Given an unloaded relation error with a stack trace,', () {
    late RelationNotLoadedError error;
    late StackTrace trace;

    setUp(() {
      error = RelationNotLoadedError(model: 'Company', relation: 'town');
      trace = StackTrace.current;
    });

    group('when the web server logs the error,', () {
      late logging.LogEntry entry;

      setUp(() async {
        pod.webServer.logError(error, stackTrace: trace);
        await logging.log.flush();
        entry = writer.entries.single;
      });

      test('then the structured entry retains the original error.', () {
        expect(entry.error, same(error));
        expect(entry.level, logging.LogLevel.error);
      });

      test('then the entry retains the stack trace and relation details.', () {
        expect(entry.stackTrace, same(trace));
        expect(
          entry.message,
          'WebServer: RelationNotLoadedError: '
          'Company.town was accessed but was not loaded.',
        );
      });
    });
  });
}
