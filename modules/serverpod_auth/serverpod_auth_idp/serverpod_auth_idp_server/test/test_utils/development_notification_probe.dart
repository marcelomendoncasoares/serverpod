import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:serverpod_shared/development_notifications.dart';
import 'package:vm_service/vm_service.dart';
import 'package:vm_service/vm_service_io.dart';

class DevelopmentNotificationProbe {
  DevelopmentNotificationProbe._(
    this.directory,
    this.process,
    this.vm,
    this.port,
  );
  final Directory directory;
  final Process process;
  final VmService vm;
  final int port;
  static final token = List.filled(64, 'a').join();
  static late Directory _fixtureDirectory;

  static Future<void> prepare() async {
    _fixtureDirectory = await Directory.systemTemp.createTemp(
      'auth_notification_kernel_',
    );
    final result = await Process.run(Platform.resolvedExecutable, [
      'compile',
      'kernel',
      'test/test_utils/development_notification_server.dart',
      '-o',
      '${_fixtureDirectory.path}/server.dill',
    ]);
    if (result.exitCode != 0) {
      throw StateError('${result.stdout}\n${result.stderr}');
    }
  }

  static Future<void> disposeFixture() =>
      _fixtureDirectory.delete(recursive: true);

  static Future<DevelopmentNotificationProbe> start({
    String mode = 'development',
    bool withRunner = true,
    String publicHost = 'localhost',
  }) async {
    final dir = await Directory.systemTemp.createTemp('auth_notification_');
    await Directory('${dir.path}/config').create();
    await File('${dir.path}/config/passwords.yaml').writeAsString(
      'shared:\n  emailSecretHashPepper: test-pepper\n  scloudAuthEmailKey: test-token\n',
    );
    final info = File('${dir.path}/vm.json');
    final process = await Process.start(
      Platform.resolvedExecutable,
      [
        '--enable-vm-service=0',
        '--write-service-info=${info.path}',
        '${_fixtureDirectory.path}/server.dill',
        dir.path,
        mode,
        publicHost,
      ],
      environment: {developmentNotificationTokenEnv: withRunner ? token : ''},
    );
    final error = StringBuffer();
    process.stderr.transform(utf8.decoder).listen(error.write);
    final ready = Completer<int>();
    process.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
          if (line.startsWith('READY:')) {
            ready.complete(int.parse(line.substring(6)));
          }
        });
    unawaited(
      process.exitCode.then((code) {
        if (!ready.isCompleted) {
          ready.completeError(StateError('Child exit $code: $error'));
        }
      }),
    );
    try {
      final port = await ready.future.timeout(const Duration(seconds: 45));
      final json =
          jsonDecode(await info.readAsString()) as Map<String, dynamic>;
      final uri = Uri.parse(json['uri'] as String);
      final vm = await vmServiceConnectUri(
        uri.replace(scheme: 'ws', path: '${uri.path}ws').toString(),
      );
      await vm.streamListen(EventStreams.kExtension);
      return DevelopmentNotificationProbe._(dir, process, vm, port);
    } catch (_) {
      process.kill();
      await process.exitCode;
      await dir.delete(recursive: true);
      rethrow;
    }
  }

  Future<({List<Map<String, dynamic>> notifications, int emailsSent})> send({
    bool? enabled = true,
    String? overrideMode,
    bool noRequest = false,
    String purpose = 'Login',
    Map<String, String> headers = const {},
    String address = 'localhost',
  }) async {
    final notifications = <Map<String, dynamic>>[];
    final barrier = Completer<void>();
    final subscription = vm.onExtensionEvent.listen((event) {
      if (event.extensionKind == developmentAuthNotificationEvent) {
        notifications.add(event.extensionData!.data);
      } else if (event.extensionKind == 'ext.notificationTest.complete') {
        barrier.complete();
      }
    });
    final client = HttpClient();
    try {
      final request = await client.postUrl(
        Uri.parse('http://$address:$port/send'),
      );
      headers.forEach(request.headers.set);
      request.write(
        jsonEncode({
          'enabled': enabled,
          'overrideMode': overrideMode,
          'noRequest': noRequest,
          'purpose': purpose,
        }),
      );
      final response = await request.close();
      final body = await response.transform(utf8.decoder).join();
      if (response.statusCode != 200) {
        throw StateError('HTTP ${response.statusCode}: $body');
      }
      await barrier.future.timeout(const Duration(seconds: 5));
      return (
        notifications: notifications,
        emailsSent:
            (jsonDecode(body) as Map<String, dynamic>)['emailsSent'] as int,
      );
    } finally {
      await subscription.cancel();
      client.close(force: true);
    }
  }

  Future<void> close() async {
    await vm.dispose();
    await process.stdin.close();
    await process.exitCode.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        process.kill();
        return -1;
      },
    );
    await directory.delete(recursive: true);
  }
}
