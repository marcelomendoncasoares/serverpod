import 'package:serverpod_shared/development_notifications.dart';
import 'package:test/test.dart';

void main() {
  group('Given a development notification payload,', () {
    late Map<String, Object?> payload;

    setUp(() {
      payload = {
        'token': List.filled(64, 'a').join(),
        'appName': 'My app',
        'email': 'user@example.com',
        'code': '123456',
        'purpose': 'Login',
      };
    });

    test('when decoded, then all delivery fields survive a round trip.', () {
      final notification = DevelopmentAuthNotification.tryFromJson(payload);

      expect(notification?.toJson(), payload);
    });

    test('when the code contains a newline, then the payload is rejected.', () {
      payload['code'] = '123456\n';
      final notification = DevelopmentAuthNotification.tryFromJson(payload);

      expect(notification, isNull);
    });

    test(
      'when the capability contains a trailing newline, then the payload is rejected.',
      () {
        payload['token'] = '${payload['token']}\n';
        final notification = DevelopmentAuthNotification.tryFromJson(payload);

        expect(notification, isNull);
      },
    );

    test(
      'when the title exceeds the display limit, then the payload is rejected.',
      () {
        payload['appName'] = List.filled(65, 'a').join();
        final notification = DevelopmentAuthNotification.tryFromJson(payload);

        expect(notification, isNull);
      },
    );

    test(
      'when a field has the wrong type, then decoding fails without throwing.',
      () {
        payload['code'] = 123456;
        final notification = DevelopmentAuthNotification.tryFromJson(payload);

        expect(notification, isNull);
      },
    );

    test('when the purpose is unknown, then the payload is rejected.', () {
      payload['purpose'] = 'Execute command';
      final notification = DevelopmentAuthNotification.tryFromJson(payload);

      expect(notification, isNull);
    });
  });
}
