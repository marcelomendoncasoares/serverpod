import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:ci/ci.dart' as ci;
import 'package:serverpod_cli/src/util/desktop_notifier.dart';
import 'package:serverpod_shared/development_notifications.dart';
import 'package:vm_service/vm_service.dart';

/// Handles transient auth events only in the runner that owns the server.
/// Attach clients, log replay, and Flutter VM events never enter this path.
class DevelopmentNotifications {
  DevelopmentNotifications({
    required String runMode,
    DesktopNotifier? notifier,
    bool? isCI,
    Map<String, String>? environment,
  }) : _notifier = notifier ?? DesktopNotifier(),
       _enabled =
           runMode == 'development' &&
           !(isCI ?? ci.isCI) &&
           !(environment ?? Platform.environment).containsKey(
             'SSH_CONNECTION',
           ) &&
           !(environment ?? Platform.environment).containsKey('SSH_CLIENT');

  final DesktopNotifier _notifier;
  final bool _enabled;
  final String _token = _createToken();
  DevelopmentAuthNotification? _pending;
  bool _sending = false;
  bool _closed = false;

  /// Always overrides inherited capabilities, including in non-development mode.
  Map<String, String> get environment => {
    developmentNotificationTokenEnv: _enabled ? _token : '',
  };

  /// Accepts only fresh events belonging to this server process.
  void handleEvent(Event event) {
    if (_closed ||
        !_enabled ||
        event.extensionKind != developmentAuthNotificationEvent) {
      return;
    }
    final notification = DevelopmentAuthNotification.tryFromJson(
      event.extensionData?.data ?? const {},
    );
    if (notification == null || notification.token != _token) return;
    // Bounded coalescing: a burst retains only its newest code while a system
    // helper is running. Never grow a queue of obsolete verification codes.
    _pending = notification;
    if (!_sending) unawaited(_deliver());
  }

  Future<void> _deliver() async {
    _sending = true;
    try {
      while (!_closed && _pending != null) {
        final notification = _pending!;
        _pending = null;
        await _notifier.show(
          title: '${notification.appName} — Serverpod development',
          body:
              '${notification.purpose} code: ${notification.code}\n${notification.email}',
        );
      }
    } finally {
      _sending = false;
    }
  }

  /// Drops queued codes and terminates any helper when the child exits/restarts.
  void close() {
    _closed = true;
    _pending = null;
    _notifier.close();
  }

  static String _createToken() {
    final random = Random.secure();
    return List.generate(
      32,
      (_) => random.nextInt(256),
    ).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }
}
