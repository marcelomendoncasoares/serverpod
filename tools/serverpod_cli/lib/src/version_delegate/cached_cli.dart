import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cli/src/util/sdk_path.dart';
import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';

const _serverpodCliPackageName = 'serverpod_cli';

/// Returns the pub cache directory, honoring [PUB_CACHE] when set.
String get pubCachePath {
  final fromEnv = Platform.environment['PUB_CACHE'];
  if (fromEnv != null && fromEnv.isNotEmpty) {
    return fromEnv;
  }

  if (Platform.isWindows) {
    final localAppData = Platform.environment['LOCALAPPDATA'];
    if (localAppData != null && localAppData.isNotEmpty) {
      return p.join(localAppData, 'Pub', 'Cache');
    }
  }

  final home =
      Platform.environment['HOME'] ?? Platform.environment['USERPROFILE'];
  if (home != null && home.isNotEmpty) {
    return p.join(home, '.pub-cache');
  }

  throw StateError('Could not resolve pub cache directory.');
}

/// Returns the path to the cached [serverpod_cli] entrypoint for [version].
File cachedCliEntrypoint(Version version) {
  return File(
    p.join(
      pubCachePath,
      'hosted',
      'pub.dev',
      '$_serverpodCliPackageName-$version',
      'bin',
      'serverpod_cli.dart',
    ),
  );
}

/// Ensures [serverpod_cli] [version] is available in the pub cache.
Future<void> ensureServerpodCliCached(Version version) async {
  final entrypoint = cachedCliEntrypoint(version);
  if (entrypoint.existsSync()) {
    return;
  }

  final dartExecutable = p.join(getSdkPath(), 'bin', 'dart');
  log.info('Downloading Serverpod CLI $version...');

  final installProcess = await Process.start(dartExecutable, [
    'pub',
    'cache',
    'add',
    _serverpodCliPackageName,
    '--version',
    version.toString(),
  ]);

  installProcess.stdout.transform(const Utf8Decoder()).listen(log.debug);
  installProcess.stderr.transform(const Utf8Decoder()).listen(log.error);

  if (await installProcess.exitCode != 0) {
    log.error(
      'Failed to download Serverpod CLI $version. '
      'Try running `dart pub cache add $_serverpodCliPackageName '
      '--version $version` manually.',
    );
    throw StateError('Failed to cache serverpod_cli $version');
  }

  if (!entrypoint.existsSync()) {
    throw StateError(
      'Serverpod CLI $version was downloaded but the entrypoint was not '
      'found at ${entrypoint.path}.',
    );
  }
}
