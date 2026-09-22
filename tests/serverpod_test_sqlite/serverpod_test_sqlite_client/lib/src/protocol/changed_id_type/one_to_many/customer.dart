/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _isc;
import 'package:serverpod_serialization/serverpod_serialization.dart' as _iss;
import 'package:serverpod_test_sqlite_client/src/protocol/protocol.dart'
    as _i0ntutnq;
import '../../changed_id_type/one_to_many/order.dart' as _ivss21qh;

@_isc.immutable
abstract class CustomerInt
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  const CustomerInt._({
    this.id,
    required this.name,
    List<_ivss21qh.OrderUuid>? orders,
  }) : _orders = orders;

  const factory CustomerInt({
    int? id,
    required String name,
    List<_ivss21qh.OrderUuid> orders,
  }) = _CustomerIntImpl;

  factory CustomerInt.fromJson(Map<String, dynamic> jsonSerialization) {
    return _CustomerIntImpl(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      orders: jsonSerialization['orders'] == null
          ? null
          : _i0ntutnq.Protocol().deserialize<List<_ivss21qh.OrderUuid>>(
              jsonSerialization['orders'],
            ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  final int? id;

  final String name;

  final List<_ivss21qh.OrderUuid>? _orders;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  List<_ivss21qh.OrderUuid> get orders {
    final value = _orders;
    if (value == null) {
      throw _iss.RelationNotLoadedError(
        model: 'CustomerInt',
        relation: 'orders',
      );
    }
    return value;
  }

  /// Returns a shallow copy of this [CustomerInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustomerInt copyWith({
    int? id,
    String? name,
    Object? orders = _Undefined,
  });
  @override
  bool operator ==(Object other) {
    return identical(
          other,
          this,
        ) ||
        other.runtimeType == runtimeType &&
            other is CustomerInt &&
            (identical(
                  other.id,
                  id,
                ) ||
                other.id == id) &&
            (identical(
                  other.name,
                  name,
                ) ||
                other.name == name) &&
            const _iss.DeepCollectionEquality().equals(
              other._orders,
              _orders,
            );
  }

  @override
  int get hashCode {
    return Object.hash(
      runtimeType,
      id,
      name,
      const _iss.DeepCollectionEquality().hash(_orders),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomerInt',
      if (id != null) 'id': id,
      'name': name,
      if (_orders case final value?)
        'orders': value.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomerInt',
      if (id != null) 'id': id,
      'name': name,
      if (_orders case final value?)
        'orders': value.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _CustomerIntImpl extends CustomerInt {
  const _CustomerIntImpl({
    int? id,
    required String name,
    List<_ivss21qh.OrderUuid>? orders,
  }) : super._(
         id: id,
         name: name,
         orders: orders,
       );

  /// Returns a shallow copy of this [CustomerInt]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CustomerInt copyWith({
    Object? id = _Undefined,
    String? name,
    Object? orders = _Undefined,
  }) {
    return _CustomerIntImpl(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      orders: orders is List
          ? orders
                .cast<_ivss21qh.OrderUuid>()
                .map((e0) => e0.copyWith())
                .toList()
          : this._orders?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
