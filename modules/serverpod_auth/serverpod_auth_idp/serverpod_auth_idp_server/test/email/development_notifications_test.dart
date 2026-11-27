@Timeout(Duration(minutes: 2))
library;

import 'dart:io';

import 'package:test/test.dart';

import '../test_utils/development_notification_probe.dart';

void main() {
  setUpAll(DevelopmentNotificationProbe.prepare);

  tearDownAll(DevelopmentNotificationProbe.disposeFixture);

  group('Given an opted-in development server launched by a local runner,', () {
    late DevelopmentNotificationProbe probe;

    setUpAll(() async {
      probe = await DevelopmentNotificationProbe.start();
    });

    tearDownAll(() => probe.close());

    test('when a native client requests a login code over loopback, '
        'then the runner receives the normal verification code.', () async {
      final result = await probe.send();

      expect(result.notifications, [
        {
          'token': DevelopmentNotificationProbe.token,
          'appName': 'Notification test',
          'email': 'user@example.com',
          'code': '123456',
          'purpose': 'Login',
        },
      ]);
    });

    test('when a local browser requests a registration code, '
        'then the runner receives its registration code.', () async {
      final result = await probe.send(
        purpose: 'Registration',
        headers: {
          'Origin': 'http://localhost:54321',
        },
      );

      expect(result.notifications.single['purpose'], 'Registration');
      expect(result.notifications.single['code'], 'ABC123');
    });

    test('when a local client requests a password reset, '
        'then the runner receives its reset code.', () async {
      final result = await probe.send(purpose: 'Password reset');

      expect(result.notifications.single['purpose'], 'Password reset');
      expect(result.notifications.single['code'], 'ABC123');
    });

    test('when notification delivery is disabled in email configuration, '
        'then no notification event is published.', () async {
      final result = await probe.send(enabled: false);

      expect(result.notifications, isEmpty);
    });

    test('when an existing project omits the new configuration flag, '
        'then no notification event is published.', () async {
      final result = await probe.send(enabled: null);

      expect(result.notifications, isEmpty);
    });

    test('when a non-loopback peer supplies local Host and Origin, '
        'then the socket address still prevents a notification.', () async {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
      );
      final address = interfaces.expand((i) => i.addresses).firstOrNull;
      if (address == null) {
        markTestSkipped(
          'No non-loopback IPv4 interface for a real remote-peer request.',
        );
        return;
      }
      final result = await probe.send(
        address: address.address,
        headers: {
          'Host': 'localhost:${probe.port}',
          'Origin': 'http://localhost:54321',
        },
      );

      expect(result.notifications, isEmpty);
    });

    test('when an internal sender has no HTTP request, '
        'then no notification event is published.', () async {
      final result = await probe.send(noRequest: true);

      expect(result.notifications, isEmpty);
    });

    test('when a remote website sends a loopback request, '
        'then its Origin prevents a notification.', () async {
      final result = await probe.send(
        headers: {'Origin': 'https://example.com'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when a sandboxed website sends an opaque Origin, '
        'then no notification event is published.', () async {
      final result = await probe.send(headers: {'Origin': 'null'});

      expect(result.notifications, isEmpty);
    });

    test('when a browser supplies a localhost-looking remote domain, '
        'then no notification event is published.', () async {
      final result = await probe.send(
        headers: {'Origin': 'http://localhost.example.com'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when a browser supplies a malformed Origin with a path, '
        'then no notification event is published.', () async {
      final result = await probe.send(
        headers: {'Origin': 'http://localhost/path'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when a DNS-rebinding request carries a remote Host, '
        'then no notification event is published.', () async {
      final result = await probe.send(
        headers: {'Host': 'example.com:${probe.port}'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when the Host does not match the listener port, '
        'then no notification event is published.', () async {
      final result = await probe.send(headers: {'Host': 'localhost:1'});

      expect(result.notifications, isEmpty);
    });

    test('when a proxy forwards a remote client through loopback, '
        'then its Forwarded header prevents a notification.', () async {
      final result = await probe.send(
        headers: {'Forwarded': 'for=203.0.113.1'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when a proxy claims a loopback client address, '
        'then X-Forwarded-For cannot authorize a notification.', () async {
      final result = await probe.send(
        headers: {'X-Forwarded-For': '127.0.0.1'},
      );

      expect(result.notifications, isEmpty);
    });

    test('when a proxy forwards a Host header, '
        'then no notification event is published.', () async {
      final result = await probe.send(
        headers: {'X-Forwarded-Host': 'localhost'},
      );

      expect(result.notifications, isEmpty);
    });
  });

  group('Given a development server started without a runner capability,', () {
    late DevelopmentNotificationProbe probe;

    setUpAll(() async {
      probe = await DevelopmentNotificationProbe.start(withRunner: false);
    });

    tearDownAll(() => probe.close());

    test('when an opted-in client requests a code, '
        'then no notification event is published.', () async {
      final result = await probe.send();

      expect(result.notifications, isEmpty);
    });
  });

  group('Given a development server configured with a public hostname,', () {
    late DevelopmentNotificationProbe probe;

    setUpAll(() async {
      probe = await DevelopmentNotificationProbe.start(
        publicHost: 'example.com',
      );
    });

    tearDownAll(() => probe.close());

    test('when a loopback client requests a code, '
        'then no notification event is published.', () async {
      final result = await probe.send();

      expect(result.notifications, isEmpty);
    });
  });

  group(
    'Given a production server with the notification flag and runner token,',
    () {
      late DevelopmentNotificationProbe probe;

      setUpAll(() async {
        probe = await DevelopmentNotificationProbe.start(mode: 'production');
      });

      tearDownAll(() => probe.close());

      test(
        'when a loopback client requests a code, '
        'then normal email delivery continues without a notification.',
        () async {
          final result = await probe.send();

          expect(result.notifications, isEmpty);
          expect(result.emailsSent, 1);
        },
      );

      test(
        'when the email run-mode override claims development, '
        'then the actual server mode still prevents notifications.',
        () async {
          final result = await probe.send(overrideMode: 'development');

          expect(result.notifications, isEmpty);
        },
      );
    },
  );

  group(
    'Given a staging server with the notification flag and runner token,',
    () {
      late DevelopmentNotificationProbe probe;

      setUpAll(() async {
        probe = await DevelopmentNotificationProbe.start(mode: 'staging');
      });

      tearDownAll(() => probe.close());

      test(
        'when a loopback client requests a code, '
        'then normal email delivery continues without a notification.',
        () async {
          final result = await probe.send();

          expect(result.notifications, isEmpty);
          expect(result.emailsSent, 1);
        },
      );
    },
  );

  group(
    'Given a test-mode server with the notification flag and runner token,',
    () {
      late DevelopmentNotificationProbe probe;

      setUpAll(() async {
        probe = await DevelopmentNotificationProbe.start(mode: 'test');
      });

      tearDownAll(() => probe.close());

      test('when a loopback client requests a code, '
          'then no notification event is published.', () async {
        final result = await probe.send();

        expect(result.notifications, isEmpty);
      });
    },
  );
}
