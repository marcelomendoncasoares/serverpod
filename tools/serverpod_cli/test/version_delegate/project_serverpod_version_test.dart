import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cli/src/version_delegate/project_serverpod_version.dart';
import 'package:test/test.dart';

void main() {
  group('Given resolveProjectServerpodVersion', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'serverpod_version_test_',
      );
    });

    tearDown(() async {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    });

    test(
      'when server has a hosted serverpod lock version '
      'then returns the resolved version',
      () async {
        _createServerProject(
          tempDir,
          lockFile: _hostedLockFile(serverpodVersion: '3.4.0'),
        );

        final result = resolveProjectServerpodVersion(
          startDirectory: tempDir,
        );

        expect(result, isA<ProjectServerpodVersionResolved>());
        final resolved = result as ProjectServerpodVersionResolved;
        expect(resolved.version, Version.parse('3.4.0'));
      },
    );

    test(
      'when serverpod is a path dependency in the lock file '
      'then returns non-hosted',
      () async {
        _createServerProject(
          tempDir,
          lockFile: '''
packages:
  serverpod:
    dependency: "direct main"
    description:
      path: "../../../packages/serverpod"
      relative: true
    source: path
    version: "3.5.0"
sdks:
  dart: "^3.10.3"
''',
        );

        final result = resolveProjectServerpodVersion(
          startDirectory: tempDir,
        );

        expect(result, isA<ProjectServerpodVersionNonHosted>());
      },
    );

    test(
      'when pubspec.lock is missing '
      'then returns missing lock',
      () async {
        _createServerProject(tempDir);

        final result = resolveProjectServerpodVersion(
          startDirectory: tempDir,
        );

        expect(result, isA<ProjectServerpodVersionMissingLock>());
      },
    );

    test(
      'when no server directory exists '
      'then returns not found',
      () async {
        final result = resolveProjectServerpodVersion(
          startDirectory: tempDir,
        );

        expect(result, isA<ProjectServerpodVersionNotFound>());
      },
    );

    test(
      'when multiple server directories exist and interactive is not used '
      'then returns ambiguous',
      () async {
        _createServerProject(
          Directory(p.join(tempDir.path, 'project_a')),
          serverName: 'a_server',
        );
        _createServerProject(
          Directory(p.join(tempDir.path, 'project_b')),
          serverName: 'b_server',
        );

        final result = resolveProjectServerpodVersion(
          startDirectory: tempDir,
        );

        expect(result, isA<ProjectServerpodVersionAmbiguous>());
      },
    );
  });
}

void _createServerProject(
  Directory parent, {
  String serverName = 'myapp_server',
  String? lockFile,
}) {
  final serverDir = Directory(p.join(parent.path, serverName));
  serverDir.createSync(recursive: true);
  File(p.join(serverDir.path, 'pubspec.yaml')).writeAsStringSync('''
name: $serverName
dependencies:
  serverpod: 3.4.0
''');
  if (lockFile != null) {
    File(p.join(serverDir.path, 'pubspec.lock')).writeAsStringSync(lockFile);
  }
}

String _hostedLockFile({required String serverpodVersion}) {
  return '''
packages:
  serverpod:
    dependency: "direct main"
    description:
      name: serverpod
      sha256: abc123
      url: "https://pub.dev"
    source: hosted
    version: "$serverpodVersion"
  serverpod_client:
    dependency: transitive
    description:
      name: serverpod_client
      sha256: def456
      url: "https://pub.dev"
    source: hosted
    version: "$serverpodVersion"
sdks:
  dart: "^3.10.3"
''';
}
