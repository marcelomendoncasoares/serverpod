import 'dart:async';
import 'dart:io';

import 'package:meta/meta.dart';
import 'package:serverpod/protocol.dart';
import 'package:serverpod/serverpod.dart';

@internal
class LogCleanupManager {
  final Duration? _cleanupInterval;
  final Duration? _retentionPeriod;
  final int? _retentionCount;

  LogCleanupManager({
    required Database database,
    required LogSettings settings,
  }) : _cleanupInterval = settings.logCleanupInterval,
       _retentionPeriod = settings.logRetentionPeriod,
       _retentionCount = settings.logRetentionCount;

  DateTime? _lastCleanupTime;
  Future<void>? _activeCleanupTask;

  Duration? get _timeSinceLastCleanup {
    final lastCleanup = _lastCleanupTime;
    if (lastCleanup == null) return null;
    return DateTime.now().difference(lastCleanup);
  }

  bool get shouldPerformCleanup {
    final timeSinceLastCleanup = _timeSinceLastCleanup;
    if (timeSinceLastCleanup == null) return true;

    final cleanupInterval = _cleanupInterval;
    if (cleanupInterval == null) return false;

    return timeSinceLastCleanup < cleanupInterval;
  }

  Future<void> performCleanup(Session session) async {
    if (!shouldPerformCleanup) return;
    if (_activeCleanupTask != null) return;

    _activeCleanupTask = _performCleanup(session)
        .timeout(const Duration(hours: 1))
        .whenComplete(() {
          _lastCleanupTime = DateTime.now();
          _activeCleanupTask = null;
        })
        .catchError((error, stackTrace) {
          stderr.writeln(
            '${DateTime.now().toUtc()} FAILED TO CLEAN UP LOGS\n'
            'ERROR: $error\n'
            'STACK TRACE: $stackTrace',
          );
          _activeCleanupTask = null;
        });

    unawaited(_activeCleanupTask);
  }

  Future<void> _performCleanup(Session session) async {
    await _performTimeBasedCleanup(session);
    await _performCountBasedCleanup(session);
  }

  Future<void> _performTimeBasedCleanup(Session session) async {
    final retentionPeriod = _retentionPeriod;
    if (retentionPeriod == null) return;

    final cutoffTime = DateTime.now().subtract(retentionPeriod);
    final deletedCount = await session.db.unsafeExecute(
      'DELETE FROM serverpod_session_log WHERE time < @cutoffTime',
      parameters: QueryParameters.named({'cutoffTime': cutoffTime}),
    );

    stderr.writeln(
      '${DateTime.now().toUtc()} Cleaned up $deletedCount log entries from '
      '"serverpod_session_log" older than $_retentionPeriod.',
    );
  }

  Future<void> _performCountBasedCleanup(Session session) async {
    final retentionCount = _retentionCount;
    if (retentionCount == null) return;

    final deletedCount = await session.db.unsafeExecute('''
      DELETE FROM serverpod_session_log
      WHERE id < (
        SELECT id FROM serverpod_session_log
        ORDER BY id DESC
        OFFSET $retentionCount LIMIT 1
      )
    ''');

    stderr.writeln(
      '${DateTime.now().toUtc()} Cleaned up $deletedCount log entries from '
      '"serverpod_session_log" exceeding the retention count of $retentionCount.',
    );
  }
}
