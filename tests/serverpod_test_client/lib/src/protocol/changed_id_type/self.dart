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
import 'package:serverpod_test_client/src/protocol/protocol.dart' as _iza9lbb5;
import '../changed_id_type/self.dart' as _iqjmn1nu;

abstract class ChangedIdTypeSelf
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  ChangedIdTypeSelf._({
    _isc.UuidValue? id,
    required this.name,
    Object? previous = #serverpodUnloadedRelation,
    this.nextId,
    Object? next = #serverpodUnloadedRelation,
    this.parentId,
    Object? parent = #serverpodUnloadedRelation,
    this.children,
  }) : _previous$loaded = !identical(
         previous,
         #serverpodUnloadedRelation,
       ),
       _previous =
           !identical(
             previous,
             #serverpodUnloadedRelation,
           )
           ? (previous as _iqjmn1nu.ChangedIdTypeSelf?)
           : null,
       _next$loaded = !identical(
         next,
         #serverpodUnloadedRelation,
       ),
       _next =
           !identical(
             next,
             #serverpodUnloadedRelation,
           )
           ? (next as _iqjmn1nu.ChangedIdTypeSelf?)
           : null,
       _parent$loaded = !identical(
         parent,
         #serverpodUnloadedRelation,
       ),
       _parent =
           !identical(
             parent,
             #serverpodUnloadedRelation,
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
                : _iza9lbb5.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['previous'],
                  )
          : #serverpodUnloadedRelation,
      nextId: jsonSerialization['nextId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['nextId']),
      next: jsonSerialization.containsKey('next')
          ? jsonSerialization['next'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['next'],
                  )
          : #serverpodUnloadedRelation,
      parentId: jsonSerialization['parentId'] == null
          ? null
          : _isc.UuidValueJsonExtension.fromJson(jsonSerialization['parentId']),
      parent: jsonSerialization.containsKey('parent')
          ? jsonSerialization['parent'] == null
                ? null
                : _iza9lbb5.Protocol().deserialize<_iqjmn1nu.ChangedIdTypeSelf>(
                    jsonSerialization['parent'],
                  )
          : #serverpodUnloadedRelation,
      children: jsonSerialization['children'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<List<_iqjmn1nu.ChangedIdTypeSelf>>(
              jsonSerialization['children'],
            ),
    );
  }

  /// The id of the object.
  _isc.UuidValue? id;

  String name;

  bool _previous$loaded;

  _iqjmn1nu.ChangedIdTypeSelf? _previous;

  _isc.UuidValue? nextId;

  bool _next$loaded;

  _iqjmn1nu.ChangedIdTypeSelf? _next;

  _isc.UuidValue? parentId;

  bool _parent$loaded;

  _iqjmn1nu.ChangedIdTypeSelf? _parent;

  List<_iqjmn1nu.ChangedIdTypeSelf>? children;

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get previous {
    final value = _previous;
    if (!_previous$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'previous',
      );
    }
    return value;
  }

  set previous(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _previous = value;
    _previous$loaded = true;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get next {
    final value = _next;
    if (!_next$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'next',
      );
    }
    return value;
  }

  set next(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _next = value;
    _next$loaded = true;
  }

  /// Throws `RelationNotLoadedError` if this relation was not loaded.
  _iqjmn1nu.ChangedIdTypeSelf? get parent {
    final value = _parent;
    if (!_parent$loaded) {
      throw _iss.RelationNotLoadedError(
        model: 'ChangedIdTypeSelf',
        relation: 'parent',
      );
    }
    return value;
  }

  set parent(_iqjmn1nu.ChangedIdTypeSelf? value) {
    _parent = value;
    _parent$loaded = true;
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
      if (_previous$loaded) 'previous': _previous?.toJson(),
      if (nextId != null) 'nextId': nextId?.toJson(),
      if (_next$loaded) 'next': _next?.toJson(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      if (_parent$loaded) 'parent': _parent?.toJson(),
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
      if (_previous$loaded) 'previous': _previous?.toJsonForProtocol(),
      if (nextId != null) 'nextId': nextId?.toJson(),
      if (_next$loaded) 'next': _next?.toJsonForProtocol(),
      if (parentId != null) 'parentId': parentId?.toJson(),
      if (_parent$loaded) 'parent': _parent?.toJsonForProtocol(),
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
    Object? previous = #serverpodUnloadedRelation,
    _isc.UuidValue? nextId,
    Object? next = #serverpodUnloadedRelation,
    _isc.UuidValue? parentId,
    Object? parent = #serverpodUnloadedRelation,
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
          : _previous$loaded
          ? this._previous?.copyWith()
          : #serverpodUnloadedRelation,
      nextId: nextId is _isc.UuidValue? ? nextId : this.nextId,
      next: next is _iqjmn1nu.ChangedIdTypeSelf?
          ? next?.copyWith()
          : _next$loaded
          ? this._next?.copyWith()
          : #serverpodUnloadedRelation,
      parentId: parentId is _isc.UuidValue? ? parentId : this.parentId,
      parent: parent is _iqjmn1nu.ChangedIdTypeSelf?
          ? parent?.copyWith()
          : _parent$loaded
          ? this._parent?.copyWith()
          : #serverpodUnloadedRelation,
      children: children is List<_iqjmn1nu.ChangedIdTypeSelf>?
          ? children
          : this.children?.map((e0) => e0.copyWith()).toList(),
    );
  }
}
