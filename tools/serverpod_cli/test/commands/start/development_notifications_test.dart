import 'dart:async';

import 'package:serverpod_cli/src/commands/start/development_notifications.dart';
import 'package:serverpod_cli/src/util/desktop_notifier.dart';
import 'package:serverpod_shared/development_notifications.dart';
import 'package:test/test.dart';
import 'package:vm_service/vm_service.dart';

void main() {
  group('Given a local development runner,', () {
    late _Desktop desktop;
    late DevelopmentNotifications notifications;

    setUp(() {
      desktop = _Desktop();
      notifications = DevelopmentNotifications(
        runMode: 'development',
        notifier: desktop,
        isCI: false,
        environment: const {},
      );
    });

    tearDown(() => notifications.close());

    test('when the server publishes an eligible code, '
        'then it reaches the desktop without a terminal subscriber.', () async {
      notifications.handleEvent(_event(notifications.environment));
      await desktop.delivered.future;

      expect(desktop.messages, [
        (
          title: 'My app — Serverpod development',
          body: 'Login code: 123456\nuser@example.com',
        ),
      ]);
    });

    test('when an event belongs to another server process, '
        'then it never reaches the desktop.', () {
      notifications.handleEvent(
        _event({developmentNotificationTokenEnv: 'b' * 64}),
      );

      expect(desktop.messages, isEmpty);
    });

    test('when a generic log contains the notification fields, '
        'then it never reaches the desktop.', () {
      notifications.handleEvent(
        _event(notifications.environment, kind: 'ext.serverpod.log'),
      );

      expect(desktop.messages, isEmpty);
    });

    test('when a code contains command syntax, '
        'then the malformed event never reaches the desktop.', () {
      notifications.handleEvent(
        _event(notifications.environment, code: r'$(touch /tmp/x)'),
      );

      expect(desktop.messages, isEmpty);
    });

    test('when the server is disposed before an event arrives, '
        'then stale events never reach the desktop.', () {
      notifications.close();
      notifications.handleEvent(_event(notifications.environment));

      expect(desktop.messages, isEmpty);
    });

    test('when several codes arrive while a helper runs, '
        'then only the newest pending code is delivered next.', () async {
      desktop.hold = Completer<void>();
      notifications.handleEvent(
        _event(notifications.environment, code: '111111'),
      );
      notifications.handleEvent(
        _event(notifications.environment, code: '222222'),
      );
      notifications.handleEvent(
        _event(notifications.environment, code: '333333'),
      );
      desktop.hold!.complete();
      await desktop.secondDelivery.future;

      expect(desktop.messages.map((m) => m.body).toList(), [
        'Login code: 111111\nuser@example.com',
        'Login code: 333333\nuser@example.com',
      ]);
    });

    test('when the server exits while another code is pending, '
        'then the pending code is discarded.', () async {
      desktop.hold = Completer<void>();
      notifications.handleEvent(
        _event(notifications.environment, code: '111111'),
      );
      notifications.handleEvent(
        _event(notifications.environment, code: '222222'),
      );
      notifications.close();
      desktop.hold!.complete();
      await desktop.delivered.future;

      expect(desktop.messages.map((m) => m.body).toList(), [
        'Login code: 111111\nuser@example.com',
      ]);
    });
  });

  test('Given a production runner, when notifications are configured, '
      'then its child receives no usable notification capability.', () {
    final runner = DevelopmentNotifications(
      runMode: 'production',
      isCI: false,
      environment: const {},
    );
    addTearDown(runner.close);

    expect(runner.environment, {developmentNotificationTokenEnv: ''});
  });

  test('Given a CI runner, when development mode is selected, '
      'then its child receives no usable notification capability.', () {
    final runner = DevelopmentNotifications(
      runMode: 'development',
      isCI: true,
      environment: const {},
    );
    addTearDown(runner.close);

    expect(runner.environment, {developmentNotificationTokenEnv: ''});
  });

  test('Given an SSH session, when development mode is selected, '
      'then its child receives no usable notification capability.', () {
    final runner = DevelopmentNotifications(
      runMode: 'development',
      isCI: false,
      environment: const {'SSH_CONNECTION': 'remote connection'},
    );
    addTearDown(runner.close);

    expect(runner.environment, {developmentNotificationTokenEnv: ''});
  });

  test(
    'Given a restarted development server, when a new runner handler is created, '
    'then the previous child capability is not reused.',
    () {
      final first = DevelopmentNotifications(
        runMode: 'development',
        isCI: false,
        environment: const {},
      );
      final second = DevelopmentNotifications(
        runMode: 'development',
        isCI: false,
        environment: const {},
      );
      addTearDown(first.close);
      addTearDown(second.close);

      expect(first.environment, isNot(second.environment));
      expect(
        DevelopmentAuthNotification.isValidToken(
          second.environment[developmentNotificationTokenEnv]!,
        ),
        isTrue,
      );
    },
  );
}

Event _event(
  Map<String, String> environment, {
  String kind = developmentAuthNotificationEvent,
  String code = '123456',
}) => Event(
  extensionKind: kind,
  extensionData: ExtensionData.parse({
    'token': environment[developmentNotificationTokenEnv],
    'appName': 'My app',
    'email': 'user@example.com',
    'code': code,
    'purpose': 'Login',
  }),
);

// The OS is the external boundary. No notification is shown by automated tests.
class _Desktop extends DesktopNotifier {
  final messages = <({String title, String body})>[];
  final delivered = Completer<void>();
  final secondDelivery = Completer<void>();
  Completer<void>? hold;

  @override
  Future<bool> show({required String title, required String body}) async {
    messages.add((title: title, body: body));
    await hold?.future;
    if (!delivered.isCompleted) delivered.complete();
    if (messages.length == 2 && !secondDelivery.isCompleted) {
      secondDelivery.complete();
    }
    return true;
  }
}
