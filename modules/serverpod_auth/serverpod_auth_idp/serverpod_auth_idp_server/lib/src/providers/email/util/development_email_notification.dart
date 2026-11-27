import 'dart:developer' as developer;
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_shared/development_notifications.dart';

/// Posts an eligible development code to the local runner's VM connection.
/// Missing context always disables the shortcut; normal delivery is unaffected.
void notifyDevelopmentEmailCode(
  Session session, {
  required String appName,
  required String email,
  required String code,
  required String purpose,
}) {
  if (session.serverpod.runMode != ServerpodRunMode.development ||
      !isLoopbackHost(session.serverpod.config.apiServer.publicHost)) {
    return;
  }
  final token = Platform.environment[developmentNotificationTokenEnv];
  if (token == null || !DevelopmentAuthNotification.isValidToken(token)) return;
  final request = session.request;
  if (request == null || !isLocalDevelopmentRequest(request)) return;

  final notification = DevelopmentAuthNotification.tryFromJson({
    'token': token,
    'appName': appName,
    'email': email,
    'code': code,
    'purpose': purpose,
  });
  if (notification == null) return;
  developer.postEvent(developmentAuthNotificationEvent, notification.toJson());
}

/// Checks the actual connection peer, never a proxy-provided client address.
/// Host and Origin protect the shortcut against DNS rebinding and web callers
/// from non-local origins. Native clients may omit Origin.
bool isLocalDevelopmentRequest(Request request) {
  try {
    final peer = InternetAddress.tryParse(
      request.connectionInfo.remote.address.toString(),
    );
    if (peer == null || !peer.isLoopback) return false;
    if (request.headers.names.any((header) {
      final name = header.lower;
      return name == 'forwarded' ||
          name.startsWith('x-forwarded-') ||
          name == 'x-real-ip';
    })) {
      return false;
    }

    final hosts = request.headers['host']?.toList();
    if (hosts == null || hosts.length != 1) return false;
    final host = Uri.tryParse('${request.url.scheme}://${hosts.single}');
    if (host == null ||
        !_isLocalUri(host) ||
        host.path.isNotEmpty ||
        host.port != request.connectionInfo.localPort ||
        !_isLocalUri(request.url) ||
        host.host != request.url.host ||
        host.port != request.url.port) {
      return false;
    }

    final origins = request.headers['origin']?.toList();
    if (origins != null) {
      if (origins.length != 1) return false;
      final origin = Uri.tryParse(origins.single);
      if (origin == null || !_isLocalUri(origin) || origin.path.isNotEmpty) {
        return false;
      }
    }
    return true;
  } on FormatException {
    return false;
  }
}

bool _isLocalUri(Uri uri) =>
    (uri.scheme == 'http' || uri.scheme == 'https') &&
    uri.hasAuthority &&
    uri.userInfo.isEmpty &&
    !uri.hasQuery &&
    !uri.hasFragment &&
    isLoopbackHost(uri.host);

/// Only the literal localhost name and loopback IP addresses are accepted.
/// No DNS resolution, suffix matching, or wildcard bind-address allowances.
bool isLoopbackHost(String host) =>
    host.toLowerCase() == 'localhost' ||
    (InternetAddress.tryParse(host)?.isLoopback ?? false);
