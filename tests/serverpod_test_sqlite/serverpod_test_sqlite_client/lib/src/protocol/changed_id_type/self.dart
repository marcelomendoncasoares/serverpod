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
import '../changed_id_type/self.dart' as _iqjmn1nu;

abstract class ChangedIdTypeSelf
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChangedIdTypeSelf._({
    _isc.UuidValue? id,
    required this.name,
    Object? previous = _Undefined,
    this.nextId,
    Object? next = _Undefined,
    this.parentId,
    Object? parent = _Undefined,
    this.children,
  }) : _previousLoaded = !identical(
         previous,
         _Undefined,
       ),
       _previous =
           !identical(
             previous,
             _Undefined,
           )
           ? (previous as _iqjmn1nu.ChangedIdTypeSelf?)
           : null,
       _nextLoaded = !identical(
         next,
         _Undefined,
       ),
       _next =
           !identical(
             next,
             _Undefined,
           )
           ? (next as _iqjmn1nu.ChangedIdTypeSelf?)
           : null,
       _parentLoaded = !identical(
         parent,
         _Undefined,
       ),
       _parent =
           !identical(
             parent,
             _Undefined,
           )
           ? (parent as _iqjmn1nu.ChangedIdTypeSelf?)
           : null,
       id = id ?? const _isc.Uuid().v4obj();

  factory ChangedIdTypeSelf({
    _isc.UuidValue? id,
    required String name,
    _iqjmn1nu.ChangedIdTypeSelf? previous,
    _isc.UuidValue? nextId,
    _iqjmn1nu.ChangedIdTypeSelf? next,
    _isc.UuidValue? parentId,
    _iqjmn1nu.ChangedIdTypeSelf? parent,
    List<_iqjmn1nu.ChangedIdTypeSelf>? children,
  }) = _ChangedIdTypeSelfImpl;

  factory ChangedIdTypeSelf.fromJson(Map<String, dynamic> jsonSerialization) {
    return _ChangedIdTypeSelfImpl(
      id: jsonSerialization['id'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['id']),
      name: jsonSerialization['name'] as String,
      previous: jsonSerialization.containsKey('previous')
          ? jsonSerialization['previous'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['previous'],
                  )
          : _Undefined,
      nextId: jsonSerialization['nextId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['nextId']),
      next: jsonSerialization.containsKey('next')
          ? jsonSerialization['next'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['next'],
                  )
          : _Undefined,
      parentId: jsonSerialization['parentId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['parentId']),
      parent: jsonSerialization.containsKey('parent')
          ? jsonSerialization['parent'] == null
                ? null
                : _i0ntutnq.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['parent'],
                  )
          : _Undefined,
      children: jsonSerialization['children'] == null
          ? null
          : _i0ntutnq.Protocol().deserialize<List<_iqjmn1nu.ChangedIdTypeSelf>>(
              jsonSerialization['children'],
            ),
    );
  }

  /// The id of the object.
  _isc.UuidValue? id;

  String name;

  bool _previousLoaded;

  _iqjmn1nu.ChangedIdTypeSelf? _previous;

  _isc.UuidValue? nextId;

  bool _nextLoaded;

  _iqjmn1nu.ChangedIdTypeSelf? _next;

  _isc.UuidValue? parentId;

  bool _parentLoaded;

  _iqjmn1nu.ChangedIdTypeSelf? _parent;

  List<_iqjmn1nu.ChangedIdTypeSelf>? children;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get previous {
    final value = _previous;
    if (!_previousLoaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'previous',
      );
    }
    return value;
  }

  set previous(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _previous = value;
    _previousLoaded = true;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get next {
    final value = _next;
    if (!_nextLoaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'next',
      );
    }
    return value;
  }

  set next(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _next = value;
    _nextLoaded = true;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get parent {
    final value = _parent;
    if (!_parentLoaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'parent',
      );
    }
    return value;
  }

  set parent(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _parent = value;
    _parentLoaded = true;
  }

  /// Returns a shallow copy of this [ChangedIdTypeSelf]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  ChangedIdTypeSelf copyWith({
    _isc.UuidValue? id,
    String? name,
    Object? previous = _Undefined,
    _isc.UuidValue? nextId,
    Object? next = _Undefined,
    _isc.UuidValue? parentId,
    Object? parent = _Undefined,
    List<_iqjmn1nu.ChangedIdTypeSelf>? children,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChangedIdTypeSelf',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      if (_previousLoaded) 'previous': _previous?.toJson(),
      if (nextId != null) 'nextId': nextId?.toJson(),
      if (_nextLoaded) 'next': _next?.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      if (_parentLoaded) 'parent': _parent?.toJson(),
      if (children != null)
        'children': children?.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'ChangedIdTypeSelf',
      if (id != null) 'id': id?.toJson(),
      'name': name,
      if (_previousLoaded) 'previous': _previous?.toJsonForProtocol(),
      if (nextId != null) 'nextId': nextId?.toJson(),
      if (_nextLoaded) 'next': _next?.toJsonForProtocol(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      if (_parentLoaded) 'parent': _parent?.toJsonForProtocol(),
      if (children != null)
        'children': children?.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChangedIdTypeSelfImpl extends ChangedIdTypeSelf {
  _ChangedIdTypeSelfImpl({
    _isc.UuidValue? id,
    required String name,
    Object? previous = _Undefined,
    _isc.UuidValue? nextId,
    Object? next = _Undefined,
    _isc.UuidValue? parentId,
    Object? parent = _Undefined,
    List<_iqjmn1nu.ChangedIdTypeSelf>? children,
  }) : super._(
         id: id,
         name: name,
         previous: previous,
         nextId: nextId,
         next: next,
         parentId: parentId,
         parent: parent,
         children: children,
       );

  /// Returns a shallow copy of this [ChangedIdTypeSelf]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  ChangedIdTypeSelf copyWith({
    Object? id = _Undefined,
    String? name,
    Object? previous = _Undefined,
    Object? nextId = _Undefined,
    Object? next = _Undefined,
    Object? parentId = _Undefined,
    Object? parent = _Undefined,
    Object? children = _Undefined,
  }) {
    return _ChangedIdTypeSelfImpl(
      id: id is _isc.UuidValue? ? id : this.id,
      name: name ?? this.name,
      previous: previous is _iqjmn1nu.ChangedIdTypeSelf?
          ? previous?.copyWith()
          : _previousLoaded
          ? this._previous?.copyWith()
          : _Undefined,
      nextId: nextId is _isc.UuidValue? ? nextId : this.nextId,
      next: next is _iqjmn1nu.ChangedIdTypeSelf?
          ? next?.copyWith()
          : _nextLoaded
          ? this._next?.copyWith()
          : _Undefined,
      parentId: parentId is _isc.UuidValue? ? parentId : this.parentId,
      parent: parent is _iqjmn1nu.ChangedIdTypeSelf?
          ? parent?.copyWith()
          : _parentLoaded
          ? this._parent?.copyWith()
          : _Undefined,
      children: children is List<_iqjmn1nu.ChangedIdTypeSelf>?
          ? children
          : this.children?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
