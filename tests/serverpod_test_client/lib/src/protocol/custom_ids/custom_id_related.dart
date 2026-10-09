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
import 'package:serverpod_test_client/src/protocol/protocol.dart' as _iza9lbb5;
import '../custom_ids/date_time_id_model.dart' as _iddrsmux;
import '../custom_ids/duration_id_model.dart' as _ipwirpu1;
import '../custom_ids/string_id_model.dart' as _i7tbipax;

abstract class CustomIdRelated
    implements _isc.SerializableModel, _isc.ProtocolSerialization {
  CustomIdRelated._({
    required this.id,
    required this.stringId,
    this.string,
    required this.dateTimeId,
    this.dateTime,
    required this.durationId,
    this.duration,
  });

  factory CustomIdRelated({
    required String id,
    required String stringId,
    _i7tbipax.StringIdModel? string,
    required DateTime dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime,
    required Duration durationId,
    _ipwirpu1.DurationIdModel? duration,
  }) = _CustomIdRelatedImpl;

  factory CustomIdRelated.fromJson(Map<String, dynamic> jsonSerialization) {
    return CustomIdRelated(
      id: jsonSerialization['id'] as String,
      stringId: jsonSerialization['stringId'] as String,
      string: jsonSerialization['string'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<_i7tbipax.StringIdModel>(
              jsonSerialization['string'],
            ),
      dateTimeId: _isc.DateTimeJsonExtension.fromJson(
        jsonSerialization['dateTimeId'],
      ),
      dateTime: jsonSerialization['dateTime'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<_iddrsmux.DateTimeIdModel>(
              jsonSerialization['dateTime'],
            ),
      durationId: _isc.DurationJsonExtension.fromJson(
        jsonSerialization['durationId'],
      ),
      duration: jsonSerialization['duration'] == null
          ? null
          : _iza9lbb5.Protocol().deserialize<_ipwirpu1.DurationIdModel>(
              jsonSerialization['duration'],
            ),
    );
  }

  /// The id of the object.
  String id;

  String stringId;

  _i7tbipax.StringIdModel? string;

  DateTime dateTimeId;

  _iddrsmux.DateTimeIdModel? dateTime;

  Duration durationId;

  _ipwirpu1.DurationIdModel? duration;

  /// Returns a shallow copy of this [CustomIdRelated]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  CustomIdRelated copyWith({
    String? id,
    String? stringId,
    _i7tbipax.StringIdModel? string = const _UndefinedCustomIdRelated$string(),
    DateTime? dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime =
        const _UndefinedCustomIdRelated$dateTime(),
    Duration? durationId,
    _ipwirpu1.DurationIdModel? duration =
        const _UndefinedCustomIdRelated$duration(),
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'CustomIdRelated',
      'id': id,
      'stringId': stringId,
      if (string != null) 'string': string?.toJson(),
      'dateTimeId': dateTimeId.toJson(),
      if (dateTime != null) 'dateTime': dateTime?.toJson(),
      'durationId': durationId.toJson(),
      if (duration != null) 'duration': duration?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'CustomIdRelated',
      'id': id,
      'stringId': stringId,
      if (string != null) 'string': string?.toJsonForProtocol(),
      'dateTimeId': dateTimeId.toJson(),
      if (dateTime != null) 'dateTime': dateTime?.toJsonForProtocol(),
      'durationId': durationId.toJson(),
      if (duration != null) 'duration': duration?.toJsonForProtocol(),
    };
  }

  @override
  String toString() {
    return _isc.SerializationManager.encode(this);
  }
}

class _UndefinedCustomIdRelated$string extends _isc.UndefinedSentinel
    implements _i7tbipax.StringIdModel {
  const _UndefinedCustomIdRelated$string();
}

class _UndefinedCustomIdRelated$dateTime extends _isc.UndefinedSentinel
    implements _iddrsmux.DateTimeIdModel {
  const _UndefinedCustomIdRelated$dateTime();
}

class _UndefinedCustomIdRelated$duration extends _isc.UndefinedSentinel
    implements _ipwirpu1.DurationIdModel {
  const _UndefinedCustomIdRelated$duration();
}

class _CustomIdRelatedImpl extends CustomIdRelated {
  _CustomIdRelatedImpl({
    required String id,
    required String stringId,
    _i7tbipax.StringIdModel? string,
    required DateTime dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime,
    required Duration durationId,
    _ipwirpu1.DurationIdModel? duration,
  }) : super._(
         id: id,
         stringId: stringId,
         string: string,
         dateTimeId: dateTimeId,
         dateTime: dateTime,
         durationId: durationId,
         duration: duration,
       );

  /// Returns a shallow copy of this [CustomIdRelated]
  /// with some or all fields replaced by the given arguments.
  @_isc.useResult
  @override
  CustomIdRelated copyWith({
    String? id,
    String? stringId,
    _i7tbipax.StringIdModel? string = const _UndefinedCustomIdRelated$string(),
    DateTime? dateTimeId,
    _iddrsmux.DateTimeIdModel? dateTime =
        const _UndefinedCustomIdRelated$dateTime(),
    Duration? durationId,
    _ipwirpu1.DurationIdModel? duration =
        const _UndefinedCustomIdRelated$duration(),
  }) {
    return CustomIdRelated(
      id: id ?? this.id,
      stringId: stringId ?? this.stringId,
      string: string is _isc.UndefinedSentinel
          ? this.string?.copyWith()
          : string,
      dateTimeId: dateTimeId ?? this.dateTimeId,
      dateTime: dateTime is _isc.UndefinedSentinel
          ? this.dateTime?.copyWith()
          : dateTime,
      durationId: durationId ?? this.durationId,
      duration: duration is _isc.UndefinedSentinel
          ? this.duration?.copyWith()
          : duration,
    );
  }
}
