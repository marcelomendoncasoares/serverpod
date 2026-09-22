import 'package:serverpod_serialization/serverpod_serialization.dart';

/// Thrown when a relation is accessed before it has been loaded.
///
/// Include the relation when querying, or supply its value when constructing
/// the model. A loaded optional relation can be null without throwing.
/// Accessing an unloaded relation is a programming error.
class RelationNotLoadedError extends StateError {
  /// The model declaring the relation.
  final String model;

  /// The relation that was accessed.
  final String relation;

  /// Creates an error identifying the unloaded relation.
  RelationNotLoadedError({
    required this.model,
    required this.relation,
  }) : super('$model.$relation was accessed but was not loaded.');

  @override
  String toString() {
    return 'RelationNotLoadedError: $message';
  }
}

/// This is `SerializableException` that can be used to pass Domain exceptions
/// from the Server to the Client
///
/// You can `throw SerializableException()`
///
/// Based on issue [#486](https://github.com/serverpod/serverpod/issues/486)
abstract class SerializableException implements SerializableModel, Exception {
  /// Const constructor to pass empty exception with `statusCode 500`
  SerializableException();

  @override
  String toString() {
    return 'ServerpodException: Internal server error';
  }

  @override
  dynamic toJson() {
    return {};
  }
}
