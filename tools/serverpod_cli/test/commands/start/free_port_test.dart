import 'dart:io';

import 'package:serverpod_cli/src/commands/start/free_port.dart';
import 'package:test/test.dart';

void main() {
  group('Given findFreePorts,', () {
    test(
      'when requesting three ports, '
      'then three distinct currently-free ports are returned.',
      () async {
        final ports = await findFreePorts(3);

        expect(ports, hasLength(3));
        expect(ports.toSet(), hasLength(3));
        for (final port in ports) {
          expect(port, greaterThan(0));
          final socket = await ServerSocket.bind(
            InternetAddress.anyIPv6,
            port,
            shared: true,
          );
          await socket.close();
        }
      },
    );
  });
}
