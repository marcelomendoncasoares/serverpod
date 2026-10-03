import 'dart:io';
import 'dart:isolate';

/// Builds the web worker using the same resolved dependencies as the app.
Future<void> main(List<String> arguments) async {
  if (arguments.length > 1) {
    stderr.writeln(
      'Usage: dart run serverpod_database:build_sqlite_web_worker '
      '[web/serverpod_db_worker.js]',
    );
    exitCode = 64;
    return;
  }

  final source = await Isolate.resolvePackageUri(
    Uri.parse('package:serverpod_database/sqlite_web_worker.dart'),
  );
  final packages = await Isolate.packageConfig;
  final target = File(arguments.singleOrNull ?? 'web/serverpod_db_worker.js');
  await target.parent.create(recursive: true);

  final process = await Process.start(Platform.resolvedExecutable, [
    'compile',
    'js',
    '-O4',
    '-Dsqlite3.dartbigints=false',
    if (packages != null) '--packages=${packages.toFilePath()}',
    source!.toFilePath(),
    '-o',
    target.path,
  ]);
  await Future.wait([
    stdout.addStream(process.stdout),
    stderr.addStream(process.stderr),
  ]);
  exitCode = await process.exitCode;
}
