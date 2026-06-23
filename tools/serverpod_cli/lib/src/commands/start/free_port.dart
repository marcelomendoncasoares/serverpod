import 'dart:io';

/// Finds [count] distinct free TCP ports by binding ephemeral sockets.
///
/// Sockets are bound to [InternetAddress.anyIPv6] with port `0`, matching the
/// pod's bind address. All probe sockets are held open simultaneously so the
/// returned ports are guaranteed distinct.
///
/// There is a small TOCTOU window between releasing the probe sockets and the
/// consumer binding them; acceptable for dev tooling.
Future<List<int>> findFreePorts(int count) async {
  if (count <= 0) {
    throw ArgumentError.value(count, 'count', 'must be positive');
  }

  final sockets = <ServerSocket>[];
  try {
    for (var i = 0; i < count; i++) {
      sockets.add(await ServerSocket.bind(InternetAddress.anyIPv6, 0));
    }
    return [for (final socket in sockets) socket.port];
  } finally {
    for (final socket in sockets) {
      await socket.close();
    }
  }
}
