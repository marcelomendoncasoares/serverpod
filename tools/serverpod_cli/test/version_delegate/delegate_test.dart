import 'package:serverpod_cli/src/version_delegate/delegate.dart';
import 'package:test/test.dart';

void main() {
  group('Given extractSubcommand', () {
    test(
      'when args contain a subcommand after global flags '
      'then returns the subcommand',
      () {
        expect(
          extractSubcommand(['--verbose', 'generate']),
          'generate',
        );
      },
    );

    test(
      'when args contain experimental features flag '
      'then skips the flag value',
      () {
        expect(
          extractSubcommand([
            '--experimental-features',
            'someFeature',
            'start',
          ]),
          'start',
        );
      },
    );

    test(
      'when args contain only global flags '
      'then returns null',
      () {
        expect(extractSubcommand(['--verbose', '--quiet']), isNull);
      },
    );

    test(
      'when args use double dash separator '
      'then returns the subcommand before it',
      () {
        expect(
          extractSubcommand(['start', '--', 'extra']),
          'start',
        );
      },
    );

    test(
      'when subcommand is the first arg '
      'then returns it',
      () {
        expect(extractSubcommand(['migrate']), 'migrate');
      },
    );
  });

  group('Given excludedSubcommands', () {
    test(
      'then create and upgrade are excluded',
      () {
        expect(excludedSubcommands, containsAll(['create', 'upgrade']));
      },
    );
  });

  group('Given delegation env vars', () {
    test('then delegated and no-delegate env var names are stable', () {
      expect(delegatedEnvVar, 'SERVERPOD_CLI_DELEGATED');
      expect(noDelegateEnvVar, 'SERVERPOD_CLI_NO_DELEGATE');
    });
  });
}
