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
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:serverpod_service_client/src/protocol/database/database_definition.dart'
    as _i3;
import 'package:serverpod_test_sqlite_client/src/protocol/simple_data.dart'
    as _i4;
import 'package:serverpod_test_sqlite_client/src/protocol/types.dart' as _i5;
import 'package:serverpod_test_sqlite_client/src/protocol/protocol.dart' as _i6;
import 'package:serverpod_test_sqlite_client/src/protocol/types_record.dart'
    as _i7;
import 'protocol.dart' as _i8;

/// {@category Endpoint}
class EndpointInsights extends _i1.EndpointRef {
  EndpointInsights(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'insights';

  _i2.Future<void> executeSql(String sql) => caller.callServerEndpoint<void>(
    'insights',
    'executeSql',
    {'sql': sql},
  );

  _i2.Future<_i3.DatabaseDefinition> getLiveDatabaseDefinition() =>
      caller.callServerEndpoint<_i3.DatabaseDefinition>(
        'insights',
        'getLiveDatabaseDefinition',
        {},
      );
}

/// {@category Endpoint}
class EndpointTestTools extends _i1.EndpointRef {
  EndpointTestTools(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'testTools';

  _i2.Future<_i1.UuidValue> returnsSessionId() =>
      caller.callServerEndpoint<_i1.UuidValue>(
        'testTools',
        'returnsSessionId',
        {},
      );

  _i2.Future<List<String?>> returnsSessionEndpointAndMethod() =>
      caller.callServerEndpoint<List<String?>>(
        'testTools',
        'returnsSessionEndpointAndMethod',
        {},
      );

  _i2.Stream<_i1.UuidValue> returnsSessionIdFromStream() => caller
      .callStreamingServerEndpoint<_i2.Stream<_i1.UuidValue>, _i1.UuidValue>(
        'testTools',
        'returnsSessionIdFromStream',
        {},
        {},
      );

  _i2.Stream<String?> returnsSessionEndpointAndMethodFromStream() =>
      caller.callStreamingServerEndpoint<_i2.Stream<String?>, String?>(
        'testTools',
        'returnsSessionEndpointAndMethodFromStream',
        {},
        {},
      );

  _i2.Future<String> returnsString(String string) =>
      caller.callServerEndpoint<String>(
        'testTools',
        'returnsString',
        {'string': string},
      );

  _i2.Stream<int> returnsStream(int n) =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'testTools',
        'returnsStream',
        {'n': n},
        {},
      );

  _i2.Future<List<int>> returnsListFromInputStream(_i2.Stream<int> numbers) =>
      caller.callStreamingServerEndpoint<_i2.Future<List<int>>, List<int>>(
        'testTools',
        'returnsListFromInputStream',
        {},
        {'numbers': numbers},
      );

  _i2.Future<List<_i4.SimpleData>> returnsSimpleDataListFromInputStream(
    _i2.Stream<_i4.SimpleData> simpleDatas,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Future<List<_i4.SimpleData>>,
        List<_i4.SimpleData>
      >(
        'testTools',
        'returnsSimpleDataListFromInputStream',
        {},
        {'simpleDatas': simpleDatas},
      );

  _i2.Stream<int> returnsStreamFromInputStream(_i2.Stream<int> numbers) =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'testTools',
        'returnsStreamFromInputStream',
        {},
        {'numbers': numbers},
      );

  _i2.Stream<_i4.SimpleData> returnsSimpleDataStreamFromInputStream(
    _i2.Stream<_i4.SimpleData> simpleDatas,
  ) => caller
      .callStreamingServerEndpoint<_i2.Stream<_i4.SimpleData>, _i4.SimpleData>(
        'testTools',
        'returnsSimpleDataStreamFromInputStream',
        {},
        {'simpleDatas': simpleDatas},
      );

  _i2.Future<void> postNumberToSharedStream(int number) =>
      caller.callServerEndpoint<void>(
        'testTools',
        'postNumberToSharedStream',
        {'number': number},
      );

  _i2.Stream<int> postNumberToSharedStreamAndReturnStream(int number) =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'testTools',
        'postNumberToSharedStreamAndReturnStream',
        {'number': number},
        {},
      );

  _i2.Stream<int> listenForNumbersOnSharedStream() =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'testTools',
        'listenForNumbersOnSharedStream',
        {},
        {},
      );

  _i2.Future<void> createSimpleData(int data) =>
      caller.callServerEndpoint<void>(
        'testTools',
        'createSimpleData',
        {'data': data},
      );

  _i2.Future<List<_i4.SimpleData>> getAllSimpleData() =>
      caller.callServerEndpoint<List<_i4.SimpleData>>(
        'testTools',
        'getAllSimpleData',
        {},
      );

  _i2.Future<void> createSimpleDatasInsideTransactions(int data) =>
      caller.callServerEndpoint<void>(
        'testTools',
        'createSimpleDatasInsideTransactions',
        {'data': data},
      );

  _i2.Future<void> createSimpleDataAndThrowInsideTransaction(int data) =>
      caller.callServerEndpoint<void>(
        'testTools',
        'createSimpleDataAndThrowInsideTransaction',
        {'data': data},
      );

  _i2.Future<void> createSimpleDatasInParallelTransactionCalls() =>
      caller.callServerEndpoint<void>(
        'testTools',
        'createSimpleDatasInParallelTransactionCalls',
        {},
      );

  _i2.Future<_i4.SimpleData> echoSimpleData(_i4.SimpleData simpleData) =>
      caller.callServerEndpoint<_i4.SimpleData>(
        'testTools',
        'echoSimpleData',
        {'simpleData': simpleData},
      );

  _i2.Future<List<_i4.SimpleData>> echoSimpleDatas(
    List<_i4.SimpleData> simpleDatas,
  ) => caller.callServerEndpoint<List<_i4.SimpleData>>(
    'testTools',
    'echoSimpleDatas',
    {'simpleDatas': simpleDatas},
  );

  _i2.Future<_i5.Types> echoTypes(_i5.Types typesModel) =>
      caller.callServerEndpoint<_i5.Types>(
        'testTools',
        'echoTypes',
        {'typesModel': typesModel},
      );

  _i2.Future<List<_i5.Types>> echoTypesList(List<_i5.Types> typesList) =>
      caller.callServerEndpoint<List<_i5.Types>>(
        'testTools',
        'echoTypesList',
        {'typesList': typesList},
      );

  _i2.Future<(String, (int, bool))> echoRecord((String, (int, bool)) record) =>
      caller.callServerEndpoint<(String, (int, bool))>(
        'testTools',
        'echoRecord',
        {'record': _i6.Protocol().mapRecordToJson(record)},
      );

  _i2.Future<List<(String, (int, bool))>> echoRecords(
    List<(String, (int, bool))> records,
  ) => caller.callServerEndpoint<List<(String, (int, bool))>>(
    'testTools',
    'echoRecords',
    {'records': _i6.Protocol().mapContainerToJson(records)},
  );

  _i2.Future<(int, _i4.SimpleData)> returnRecordWithSerializableObject(
    int number,
    _i4.SimpleData data,
  ) => caller.callServerEndpoint<(int, _i4.SimpleData)>(
    'testTools',
    'returnRecordWithSerializableObject',
    {
      'number': number,
      'data': data,
    },
  );

  _i2.Stream<
    (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))
  >
  recordEchoStream(
    (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))
    initialValue,
    _i2.Stream<
      (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))
    >
    stream,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<
          (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))
        >,
        (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))
      >(
        'testTools',
        'recordEchoStream',
        {'initialValue': initialValue},
        {'stream': stream},
      );

  _i2.Stream<List<(String, int)>> listOfRecordEchoStream(
    List<(String, int)> initialValue,
    _i2.Stream<List<(String, int)>> stream,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<List<(String, int)>>,
        List<(String, int)>
      >(
        'testTools',
        'listOfRecordEchoStream',
        {'initialValue': initialValue},
        {'stream': stream},
      );

  _i2.Stream<
    (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))?
  >
  nullableRecordEchoStream(
    (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))?
    initialValue,
    _i2.Stream<
      (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))?
    >
    stream,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<
          (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))?
        >,
        (String, (Map<String, int>, {bool flag, _i4.SimpleData simpleData}))?
      >(
        'testTools',
        'nullableRecordEchoStream',
        {'initialValue': initialValue},
        {'stream': stream},
      );

  _i2.Stream<List<(String, int)>?> nullableListOfRecordEchoStream(
    List<(String, int)>? initialValue,
    _i2.Stream<List<(String, int)>?> stream,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<List<(String, int)>?>,
        List<(String, int)>?
      >(
        'testTools',
        'nullableListOfRecordEchoStream',
        {'initialValue': initialValue},
        {'stream': stream},
      );

  _i2.Stream<_i7.TypesRecord?> modelWithRecordsEchoStream(
    _i7.TypesRecord? initialValue,
    _i2.Stream<_i7.TypesRecord?> stream,
  ) =>
      caller.callStreamingServerEndpoint<
        _i2.Stream<_i7.TypesRecord?>,
        _i7.TypesRecord?
      >(
        'testTools',
        'modelWithRecordsEchoStream',
        {'initialValue': initialValue},
        {'stream': stream},
      );

  _i2.Future<void> logMessageWithSession() => caller.callServerEndpoint<void>(
    'testTools',
    'logMessageWithSession',
    {},
  );

  _i2.Future<void> addWillCloseListenerToSessionAndThrow() =>
      caller.callServerEndpoint<void>(
        'testTools',
        'addWillCloseListenerToSessionAndThrow',
        {},
      );

  _i2.Stream<int> addWillCloseListenerToSessionIntStreamMethodAndThrow() =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'testTools',
        'addWillCloseListenerToSessionIntStreamMethodAndThrow',
        {},
        {},
      );

  _i2.Future<void> putInLocalCache(
    String key,
    _i4.SimpleData data,
  ) => caller.callServerEndpoint<void>(
    'testTools',
    'putInLocalCache',
    {
      'key': key,
      'data': data,
    },
  );

  _i2.Future<_i4.SimpleData?> getFromLocalCache(String key) =>
      caller.callServerEndpoint<_i4.SimpleData?>(
        'testTools',
        'getFromLocalCache',
        {'key': key},
      );

  _i2.Future<void> putInLocalPrioCache(
    String key,
    _i4.SimpleData data,
  ) => caller.callServerEndpoint<void>(
    'testTools',
    'putInLocalPrioCache',
    {
      'key': key,
      'data': data,
    },
  );

  _i2.Future<_i4.SimpleData?> getFromLocalPrioCache(String key) =>
      caller.callServerEndpoint<_i4.SimpleData?>(
        'testTools',
        'getFromLocalPrioCache',
        {'key': key},
      );

  _i2.Future<void> putInQueryCache(
    String key,
    _i4.SimpleData data,
  ) => caller.callServerEndpoint<void>(
    'testTools',
    'putInQueryCache',
    {
      'key': key,
      'data': data,
    },
  );

  _i2.Future<_i4.SimpleData?> getFromQueryCache(String key) =>
      caller.callServerEndpoint<_i4.SimpleData?>(
        'testTools',
        'getFromQueryCache',
        {'key': key},
      );

  _i2.Future<void> putInLocalCacheWithGroup(
    String key,
    _i4.SimpleData data,
    String group,
  ) => caller.callServerEndpoint<void>(
    'testTools',
    'putInLocalCacheWithGroup',
    {
      'key': key,
      'data': data,
      'group': group,
    },
  );
}

/// {@category Endpoint}
class EndpointAuthenticatedTestTools extends _i1.EndpointRef {
  EndpointAuthenticatedTestTools(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'authenticatedTestTools';

  _i2.Future<String> returnsString(String string) =>
      caller.callServerEndpoint<String>(
        'authenticatedTestTools',
        'returnsString',
        {'string': string},
      );

  _i2.Stream<int> returnsStream(int n) =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'authenticatedTestTools',
        'returnsStream',
        {'n': n},
        {},
      );

  _i2.Future<List<int>> returnsListFromInputStream(_i2.Stream<int> numbers) =>
      caller.callStreamingServerEndpoint<_i2.Future<List<int>>, List<int>>(
        'authenticatedTestTools',
        'returnsListFromInputStream',
        {},
        {'numbers': numbers},
      );

  _i2.Stream<int> intEchoStream(_i2.Stream<int> stream) =>
      caller.callStreamingServerEndpoint<_i2.Stream<int>, int>(
        'authenticatedTestTools',
        'intEchoStream',
        {},
        {'stream': stream},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i8.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    insights = EndpointInsights(this);
    testTools = EndpointTestTools(this);
    authenticatedTestTools = EndpointAuthenticatedTestTools(this);
  }

  late final EndpointInsights insights;

  late final EndpointTestTools testTools;

  late final EndpointAuthenticatedTestTools authenticatedTestTools;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'insights': insights,
    'testTools': testTools,
    'authenticatedTestTools': authenticatedTestTools,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
