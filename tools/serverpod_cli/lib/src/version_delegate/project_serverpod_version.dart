import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cli/src/util/pubspec_lock_parser.dart';
import 'package:serverpod_cli/src/util/server_directory_finder.dart';
import 'package:serverpod_cli/src/util/serverpod_cli_logger.dart';

/// Result of resolving a project's Serverpod version from its lock file.
sealed class ProjectServerpodVersionResult {}

/// No server directory was found near the current working directory.
class ProjectServerpodVersionNotFound extends ProjectServerpodVersionResult {}

/// Multiple server directories were found; delegation is skipped so the
/// command can surface the ambiguity error.
class ProjectServerpodVersionAmbiguous extends ProjectServerpodVersionResult {}

/// The project uses a path, git, or otherwise non-hosted `serverpod` dependency.
class ProjectServerpodVersionNonHosted extends ProjectServerpodVersionResult {}

/// The server directory has no `pubspec.lock` or no locked `serverpod` package.
class ProjectServerpodVersionMissingLock
    extends ProjectServerpodVersionResult {}

/// A hosted `serverpod` version was resolved from the project's lock file.
class ProjectServerpodVersionResolved extends ProjectServerpodVersionResult {
  final Version version;
  final Directory serverDirectory;

  ProjectServerpodVersionResolved({
    required this.version,
    required this.serverDirectory,
  });
}

/// Resolves the hosted `serverpod` package version from a project's lock file.
///
/// Does not call [GeneratorConfig.load] and does not require `dart pub get`.
ProjectServerpodVersionResult resolveProjectServerpodVersion({
  Directory? startDirectory,
}) {
  final start = startDirectory ?? Directory.current;

  Directory? serverDirectory;
  try {
    serverDirectory = ServerDirectoryFinder.search(start);
  } on AmbiguousSearchException {
    return ProjectServerpodVersionAmbiguous();
  }

  if (serverDirectory == null) {
    return ProjectServerpodVersionNotFound();
  }

  final lockFile = File(p.join(serverDirectory.path, 'pubspec.lock'));
  if (!lockFile.existsSync()) {
    return ProjectServerpodVersionMissingLock();
  }

  final lockParser = PubspecLockParser.fromFile(lockFile);
  final serverpodPackage = lockParser.getPackage('serverpod');
  if (serverpodPackage == null) {
    return ProjectServerpodVersionMissingLock();
  }

  if (serverpodPackage.source != PackageSource.hosted) {
    return ProjectServerpodVersionNonHosted();
  }

  final clientPackage = lockParser.getPackage('serverpod_client');
  if (clientPackage != null &&
      clientPackage.source == PackageSource.hosted &&
      clientPackage.version != serverpodPackage.version) {
    log.debug(
      'Locked serverpod_client version (${clientPackage.version}) differs '
      'from serverpod (${serverpodPackage.version}).',
    );
  }

  return ProjectServerpodVersionResolved(
    version: serverpodPackage.version,
    serverDirectory: serverDirectory,
  );
}
