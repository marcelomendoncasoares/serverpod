import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:serverpod_auth_idp_server/providers/email.dart';
import 'package:serverpod_auth_idp_server/serverpod_auth_idp_server.dart';

// Exercises the public email sender on real HTTP requests, with real VM events.
Future<void> main(List<String> args) async {
  final directory = Directory(args[0]);
  final mode = args[1];
  final pod = Serverpod(
    ['-m', mode],
    Protocol(),
    Endpoints(),
    config: ServerpodConfig(
      apiServer: ServerConfig(
        port: 0,
        publicScheme: 'http',
        publicHost: args[2],
        publicPort: 0,
      ),
    ),
    serverDirectory: directory,
  );
  var emailsSent = 0;
  final app = RelicApp();
  late int port;
  app.post('/cloud/api/email/send', (_) {
    emailsSent++;
    return Response.ok();
  });
  app.post('/send', (request) async {
    final options =
        jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final client = ServerpodCloudEmailClient(
      baseUrl: 'http://localhost:$port/cloud',
    );
    final config = options['enabled'] == null
        ? ServerpodCloudEmailIdpConfig(
            appDisplayName: 'Notification test',
            runMode: options['overrideMode'] as String?,
            emailClient: client,
          )
        : ServerpodCloudEmailIdpConfig(
            appDisplayName: 'Notification test',
            enableDevelopmentNotifications:
                options['enabled'] as bool? ?? false,
            runMode: options['overrideMode'] as String?,
            emailClient: client,
          );
    final session = _RequestSession(
      pod.server,
      options['noRequest'] == true ? null : request,
    );
    try {
      switch (options['purpose']) {
        case 'Registration':
          await config.sendRegistrationVerificationCode!(
            session,
            email: 'user@example.com',
            accountRequestId: const Uuid().v4obj(),
            verificationCode: 'ABC123',
            transaction: null,
          );
        case 'Password reset':
          await config.sendPasswordResetVerificationCode!(
            session,
            email: 'user@example.com',
            passwordResetRequestId: const Uuid().v4obj(),
            verificationCode: 'ABC123',
            transaction: null,
          );
        default:
          await config.sendOtpLoginVerificationCode!(
            session,
            email: 'user@example.com',
            otpLoginRequestId: const Uuid().v4obj(),
            verificationCode: '123456',
            transaction: null,
          );
      }
    } finally {
      client.close();
      await session.close();
    }
    // Ordered on the same VM stream: negative assertions need no timing sleep.
    developer.postEvent('ext.notificationTest.complete', {});
    return Response.ok(
      body: Body.fromString(jsonEncode({'emailsSent': emailsSent})),
    );
  });
  // Binding the fixture on local interfaces permits the non-loopback-peer
  // regression test. This fixture emits only the fixed dummy codes above.
  final server = await app.serve(address: InternetAddress.anyIPv4, port: 0);
  port = server.port;
  stdout.writeln('READY:$port');
  await stdin.drain<void>();
  await app.close(force: true);
  exit(0);
}

class _RequestSession extends Session {
  _RequestSession(Server server, Request? request)
    : super(
        server: server,
        request: request,
        enableLogging: false,
        endpoint: 'email',
        method: 'send',
      );
}
