import 'dart:async';
import 'dart:io';

import 'package:async/async.dart';
import 'package:cli_tools/cli_tools.dart';

/// Starts [executable] with [arguments] and forwards stdio and signals until
/// the child exits.
///
/// Returns the child exit code. Throws [ExitException] when [throwOnNonZero]
/// is true and the exit code is non-zero.
Future<int> forwardProcess({
  required String executable,
  required List<String> arguments,
  String? workingDirectory,
  Map<String, String>? environment,
  bool throwOnNonZero = true,
}) async {
  final process = await Process.start(
    executable,
    arguments,
    workingDirectory: workingDirectory,
    environment: environment,
  );

  final sigSubscription =
      StreamGroup.merge(
        [
          ProcessSignal.sigint,
          if (!Platform.isWindows) ProcessSignal.sigterm,
        ].map((signal) => signal.watch()),
      ).listen((signal) {
        process.kill(signal);
      });

  StreamSubscription<List<int>>? stdinSubscription;
  stdinSubscription = stdin.listen(
    (data) {
      try {
        process.stdin.add(data);
      } on StateError {
        stdinSubscription?.cancel();
      } on IOException {
        stdinSubscription?.cancel();
      }
    },
    cancelOnError: true,
    onError: (_) {},
  );

  try {
    await Future.wait([
      stdout.addStream(process.stdout),
      stderr.addStream(process.stderr),
    ]);
  } finally {
    await stdinSubscription.cancel();
    await _closeProcessStdin(process.stdin);
    await sigSubscription.cancel();
  }

  final exitCode = await process.exitCode;
  if (throwOnNonZero && exitCode != 0) {
    throw ExitException(exitCode);
  }
  return exitCode;
}

Future<void> _closeProcessStdin(IOSink sink) async {
  try {
    await sink.close();
  } on StateError {
    // The child may already have closed stdin.
  } on IOException {
    // Ignore broken pipe errors during shutdown.
  }
}
