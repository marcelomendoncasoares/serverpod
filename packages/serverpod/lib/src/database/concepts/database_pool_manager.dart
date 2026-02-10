import 'package:meta/meta.dart';

import '../../serialization/serialization_manager.dart';
import 'value_encoder.dart';

/// Abstract interface for database pool managers.
/// Provides a unified interface for both PostgreSQL and SQLite implementations.
@internal
abstract class DatabasePoolManager {
  /// Access to the serialization manager.
  SerializationManagerServer get serializationManager;

  /// The encoder used to encode objects for storing in the database.
  ValueEncoder get encoder;

  /// Starts the database pool.
  void start();

  /// Closes the database pool.
  Future<void> stop();

  /// Tests the database connection.
  /// Throws an exception if the connection is not working.
  Future<bool> testConnection();
}
