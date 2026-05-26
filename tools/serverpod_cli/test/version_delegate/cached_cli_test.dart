import 'package:pub_semver/pub_semver.dart';
import 'package:serverpod_cli/src/version_delegate/cached_cli.dart';
import 'package:test/test.dart';

void main() {
  group('Given cachedCliEntrypoint', () {
    test(
      'when version is a stable release '
      'then path includes the version suffix',
      () {
        final entrypoint = cachedCliEntrypoint(Version.parse('3.4.0'));

        expect(
          entrypoint.path,
          endsWith(
            'hosted/pub.dev/serverpod_cli-3.4.0/bin/serverpod_cli.dart',
          ),
        );
      },
    );

    test(
      'when version is a prerelease '
      'then path includes the full prerelease suffix',
      () {
        final entrypoint = cachedCliEntrypoint(
          Version.parse('3.5.0-beta.9'),
        );

        expect(
          entrypoint.path,
          endsWith(
            'hosted/pub.dev/serverpod_cli-3.5.0-beta.9/bin/serverpod_cli.dart',
          ),
        );
      },
    );
  });
}
