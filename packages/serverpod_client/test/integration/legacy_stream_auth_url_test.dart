@OnPlatform({
  'browser': Skip('WebSocket tests are not supported in browser'),
})
library;

import 'dart:async';
import 'dart:convert';

import 'package:serverpod_client/serverpod_client.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

import '../test_utils/test_auth_key_providers.dart';
import '../test_utils/test_serverpod_client.dart';
import '../test_utils/test_web_socket_server.dart';

void main() {
  test(
    'legacy streaming authentication is sent in-band and never in the URL',
    () async {
      final requestUri = Completer<Uri>();
      final connected = Completer<Uri>();
      final closeServer = await TestWebSocketServer.startServer(
        onConnected: connected.complete,
        onRequest: requestUri.complete,
        webSocketHandler: (webSocket) {
          webSocket.events.listen((event) {
            if (event is! TextDataReceived) return;
            final message = jsonDecode(event.text) as Map<String, dynamic>;
            if (message['command'] == 'ping') {
              try {
                webSocket.sendText(
                  SerializationManager.encode({'command': 'pong'}),
                );
              } catch (_) {
                // The client closes immediately after receiving the pong.
              }
            }
          });
        },
      );
      addTearDown(closeServer);

      final webSocketHost = await connected.future;
      final client = TestServerpodClient(
        host: webSocketHost.replace(scheme: 'http'),
        authKeyProvider: TestNonRefresherAuthKeyProvider(
          wrapAsBearerAuthHeaderValue('secret-token'),
        ),
      );
      addTearDown(client.close);

      // ignore: deprecated_member_use
      await client.openStreamingConnection(
        disconnectOnLostInternetConnection: false,
      );
      // ignore: deprecated_member_use
      await client.closeStreamingConnection();

      expect((await requestUri.future).queryParameters, isEmpty);
    },
  );
}
