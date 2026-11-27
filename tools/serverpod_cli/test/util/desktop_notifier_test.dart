import 'dart:convert';
import 'dart:io';

import 'package:serverpod_cli/src/util/desktop_notifier.dart';
import 'package:serverpod_shared/process_io.dart';
import 'package:test/test.dart';

void main() {
  test(
    'Given macOS and text with quotes and script syntax, '
    'when resolving a notification, then the text stays in separate arguments.',
    () {
      const body = 'Code 123456 for a"&\$(doSomething)@example.com';
      final command = DesktopNotificationCommand.resolve(
        title: 'My app',
        body: body,
        operatingSystem: 'macos',
        environment: const {},
      )!;

      expect(command.executable, '/usr/bin/osascript');
      expect(command.arguments, ['-l', 'AppleScript', '-', 'My app', body]);
      expect(command.input, isNot(contains(body)));
    },
  );

  test(
    'Given Windows and text with PowerShell syntax, '
    'when resolving a notification, then the payload stays out of the script.',
    () {
      const body = 'Code 123456 for \$(Start-Process calc) & <x>';
      final command = DesktopNotificationCommand.resolve(
        title: 'My app',
        body: body,
        operatingSystem: 'windows',
        environment: const {'SystemRoot': r'C:\Windows'},
      )!;
      final bytes = base64Decode(command.arguments.last);
      final script = String.fromCharCodes(
        List.generate(
          bytes.length ~/ 2,
          (i) => bytes[i * 2] | (bytes[i * 2 + 1] << 8),
        ),
      );

      expect(
        command.executable,
        r'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe',
      );
      expect((jsonDecode(command.input!) as Map)['body'], body);
      expect(script, isNot(contains(body)));
    },
  );

  test('Given WSL without a Linux display, '
      'when resolving a notification, then it uses the Windows helper.', () {
    final command = DesktopNotificationCommand.resolve(
      title: 'My app',
      body: '123456',
      operatingSystem: 'linux',
      environment: const {},
      wslPowerShell:
          '/mnt/d/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    )!;

    expect(
      command.executable,
      '/mnt/d/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    );
    expect(command.arguments, contains('-EncodedCommand'));
  });

  test(
    'Given a Linux desktop and markup in a recipient, '
    'when resolving a notification, then markup and option prefixes stay literal.',
    () {
      final command = DesktopNotificationCommand.resolve(
        title: '--help',
        body: 'a&b <test>',
        operatingSystem: 'linux',
        environment: const {'WAYLAND_DISPLAY': 'wayland-0'},
      )!;

      expect(command.arguments, [
        '--app-name=Serverpod',
        '--expire-time=15000',
        '--',
        '--help',
        'a&amp;b &lt;test&gt;',
      ]);
    },
  );

  test('Given a headless Linux host, when resolving a notification, '
      'then desktop delivery is unavailable.', () {
    final command = DesktopNotificationCommand.resolve(
      title: 'My app',
      body: '123456',
      operatingSystem: 'linux',
      environment: const {},
    );

    expect(command, isNull);
  });

  group('Given a desktop notification subprocess,', () {
    late Directory directory;
    late DesktopNotifier notifier;

    setUp(() async {
      directory = await Directory.systemTemp.createTemp(
        'desktop_notification_',
      );
      notifier = DesktopNotifier(timeout: const Duration(seconds: 2));
    });

    tearDown(() async {
      notifier.close();
      await directory.delete(recursive: true);
    });

    test(
      'when it receives metacharacters, then they arrive as data without shell evaluation.',
      () async {
        final output = File('${directory.path}/received.json');
        final result = await notifier.execute(
          DesktopNotificationCommand(Platform.resolvedExecutable, [
            'test/util/fixtures/notification_helper.dart',
            'record',
            output.path,
            r'$(not-a-command); & "quoted"',
          ], input: '123456'),
        );
        final received = jsonDecode(await output.readAsString());

        expect(result, isTrue);
        expect(received, {
          'arguments': [r'$(not-a-command); & "quoted"'],
          'input': '123456',
        });
      },
    );

    test(
      'when the helper exits with an error, then delivery fails without throwing.',
      () async {
        final result = await notifier.execute(
          DesktopNotificationCommand(Platform.resolvedExecutable, [
            'test/util/fixtures/notification_helper.dart',
            'fail',
          ]),
        );

        expect(result, isFalse);
      },
    );

    test(
      'when the helper is missing, then delivery fails without throwing.',
      () async {
        final result = await notifier.execute(
          DesktopNotificationCommand(
            '${directory.path}/missing-helper',
            const [],
          ),
        );

        expect(result, isFalse);
      },
    );

    test(
      'when the runner closes, then its active helper is terminated.',
      () async {
        final pidFile = File('${directory.path}/helper.pid');
        final delivery = notifier.execute(
          DesktopNotificationCommand(
            Platform.resolvedExecutable,
            [
              'test/util/fixtures/notification_helper.dart',
              'wait',
              pidFile.path,
            ],
          ),
        );
        for (
          var attempt = 0;
          attempt < 100 && !pidFile.existsSync();
          attempt++
        ) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        final helperPid = int.parse(await pidFile.readAsString());
        notifier.close();
        final result = await delivery;

        expect(result, isFalse);
        expect(isProcessAlive(helperPid), isFalse);
      },
    );

    test('when the helper hangs, then the deadline terminates it.', () async {
      final pidFile = File('${directory.path}/helper.pid');
      final result = await notifier.execute(
        DesktopNotificationCommand(Platform.resolvedExecutable, [
          'test/util/fixtures/notification_helper.dart',
          'wait',
          pidFile.path,
        ]),
      );
      final helperPid = int.parse(await pidFile.readAsString());
      // Give the OS process table time to reap a terminated child.
      for (
        var attempt = 0;
        attempt < 50 && isProcessAlive(helperPid);
        attempt++
      ) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      expect(result, isFalse);
      expect(isProcessAlive(helperPid), isFalse);
    });
  });
}
