import 'package:meta/meta.dart';
import 'package:serverpod/src/database/concepts/database_pool_manager.dart';
import 'package:serverpod/src/database/concepts/value_encoder.dart';
import 'package:serverpod/src/serialization/serialization_manager.dart';
import 'package:serverpod_shared/serverpod_shared.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../../../serialization/sqlite_serialization_manager.dart';
import 'sqlite_value_encoder.dart';

/// Configuration for connecting to a SQLite database.
@internal
class SqlitePoolManager implements DatabasePoolManager {
  /// The dialect of the database pool manager.
  @override
  DatabaseDialect get dialect => DatabaseDialect.sqlite;

  /// Database configuration.
  final DatabaseConfig config;

  late SerializationManagerServer _serializationManager;

  /// Access to the serialization manager.
  @override
  SerializationManagerServer get serializationManager => _serializationManager;

  SqliteDatabase? _db;

  /// The SQLite database instance.
  ///
  /// Throws a [StateError] if the database has not been started.
  SqliteDatabase get database {
    var db = _db;
    if (db == null) {
      throw StateError('Database not started.');
    }
    return db;
  }

  /// The encoder used to encode objects for storing in the database.
  @override
  ValueEncoder get encoder => SqliteValueEncoder();

  /// Creates a new [SqlitePoolManager]. Typically, this is done automatically
  /// when starting the [Server] with SQLite configuration.
  SqlitePoolManager(
    SerializationManagerServer serializationManager,
    this.config,
  ) {
    _serializationManager = SqliteSerializationManager(serializationManager);
  }

  /// Starts the database connection.
  @override
  void start() {
    _db ??= SqliteDatabase(path: config.host);
  }

  /// Closes the database.
  @override
  Future<void> stop() async {
    await _db?.close();
    _db = null;
  }

  /// Tests the database connection.
  @override
  Future<bool> testConnection() async {
    await database.get('SELECT 1');
    return true;
  }
}
