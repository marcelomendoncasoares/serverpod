import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/src/get_server_url.dart';
import 'package:serverpod_flutter/src/localhost.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Map<String, String> assets;

  setUp(() {
    assets = {};
    rootBundle.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          final key = utf8.decode(message!.buffer.asUint8List());
          final value = assets[key];
          if (value == null) return null;
          return ByteData.sublistView(Uint8List.fromList(utf8.encode(value)));
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', null);
  });

  group('Given getServerUrl,', () {
    test(
      'when config_override.json is present, '
      'then it wins over config.json.',
      () async {
        assets.addAll({
          'assets/config_override.json': '{"apiUrl":"http://localhost:7777"}',
          'assets/config.json': '{"apiUrl":"http://localhost:8080"}',
        });

        final url = await getServerUrl();

        expect(url, 'http://localhost:7777');
      },
    );

    test(
      'when config_override.json is absent, '
      'then config.json is used.',
      () async {
        assets['assets/config.json'] = '{"apiUrl":"http://localhost:8080"}';

        final url = await getServerUrl();

        expect(url, 'http://localhost:8080');
      },
    );

    test(
      'when no config assets are available, '
      'then the default localhost URL is returned.',
      () async {
        final url = await getServerUrl();

        expect(url, 'http://$localhost:8080/');
      },
    );
  });
}
