import 'dart:async';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_client/serverpod_test_client.dart';
import 'package:serverpod_test_server/test_util/test_serverpod.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

import '../../websocket_extensions.dart';

void main() {
  group(
    'Given a method stream connection to an endpoint that continuously yields values, ',
    () {
      late Serverpod server;
      late WebSocket webSocket;
      late Completer<CloseMethodStreamCommand> closeCommandReceived;
      var connectionId = const Uuid().v4obj();

      setUp(() async {
        closeCommandReceived = Completer<CloseMethodStreamCommand>();
        var streamOpened = Completer<void>();

        server = IntegrationTestServer.create();
        await server.startWithDatabase();
        webSocket = await WebSocket.connect(
          Uri.parse(server.methodWebSocketUrl),
        );

        webSocket.textEvents.listen((event) {
          var message = WebSocketMessage.fromJsonString(
            event,
            server.serializationManager,
          );
          if (message is OpenMethodStreamResponse) {
            streamOpened.complete();
          } else if (message is CloseMethodStreamCommand &&
              message.connectionId == connectionId) {
            closeCommandReceived.complete(message);
          }
        });

        webSocket.sendText(
          OpenMethodStreamCommand.buildMessage(
            endpoint: 'methodStreaming',
            method: 'neverEndingStreamWithDelay',
            args: {'millisecondsDelay': 100},
            connectionId: connectionId,
            inputStreams: [],
          ),
        );

        await streamOpened.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () => throw AssertionError(
            'Failed to open method stream with server.',
          ),
        );
      });

      tearDown(() async {
        await server.shutdown(exitProcess: false);
        await webSocket.tryClose();
      });

      test(
        'when the server shuts down, '
        'then a CloseMethodStreamCommand with shutdown reason is sent.',
        () async {
          await server.shutdown(exitProcess: false);

          var closeCommand = await closeCommandReceived.future.timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw AssertionError(
              'Server did not send CloseMethodStreamCommand on shutdown.',
            ),
          );

          expect(closeCommand.reason, CloseReason.shutdown);
          expect(closeCommand.parameter, isNull);
        },
      );
    },
  );

  group('Given a client subscribed to an open method stream, ', () {
    late Serverpod server;
    late Client client;
    late Completer<Object> streamError;

    setUp(() async {
      server = IntegrationTestServer.create();
      await server.startWithDatabase();
      client = Client(server.apiUrl);
      streamError = Completer<Object>();
      var firstValue = Completer<void>();

      client.methodStreaming
          .neverEndingStreamWithDelay(100)
          .listen(
            (_) {
              if (!firstValue.isCompleted) firstValue.complete();
            },
            onError: (e, _) {
              if (!streamError.isCompleted) streamError.complete(e);
            },
          );

      await firstValue.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw AssertionError(
          'Failed to receive a value from the method stream.',
        ),
      );
    });

    tearDown(() async {
      await client.closeStreamingMethodConnections(exception: null);
      client.close();
      await server.shutdown(exitProcess: false);
    });

    test(
      'when the server shuts down, '
      'then the stream is closed with a ServerShutdownException.',
      () async {
        await server.shutdown(exitProcess: false);

        expect(
          await streamError.future.timeout(
            const Duration(seconds: 5),
            onTimeout: () => throw AssertionError(
              'Method stream did not close when the server shut down.',
            ),
          ),
          isA<ServerShutdownException>(),
        );
      },
    );
  });
}
