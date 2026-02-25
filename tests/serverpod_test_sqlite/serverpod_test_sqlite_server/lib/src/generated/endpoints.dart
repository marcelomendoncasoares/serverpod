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
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/test_tools.dart' as _i2;
import 'package:serverpod_test_sqlite_server/src/generated/simple_data.dart'
    as _i3;
import 'package:serverpod_test_sqlite_server/src/generated/types.dart' as _i4;
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart'
    as _i5;
import 'package:serverpod_test_sqlite_server/src/generated/types_record.dart'
    as _i6;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'testTools': _i2.TestToolsEndpoint()
        ..initialize(
          server,
          'testTools',
          null,
        ),
      'authenticatedTestTools': _i2.AuthenticatedTestToolsEndpoint()
        ..initialize(
          server,
          'authenticatedTestTools',
          null,
        ),
    };
    connectors['testTools'] = _i1.EndpointConnector(
      name: 'testTools',
      endpoint: endpoints['testTools']!,
      methodConnectors: {
        'returnsSessionId': _i1.MethodConnector(
          name: 'returnsSessionId',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSessionId(session),
        ),
        'returnsSessionEndpointAndMethod': _i1.MethodConnector(
          name: 'returnsSessionEndpointAndMethod',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSessionEndpointAndMethod(session),
        ),
        'returnsString': _i1.MethodConnector(
          name: 'returnsString',
          params: {
            'string': _i1.ParameterDescription(
              name: 'string',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsString(
                    session,
                    params['string'],
                  ),
        ),
        'postNumberToSharedStream': _i1.MethodConnector(
          name: 'postNumberToSharedStream',
          params: {
            'number': _i1.ParameterDescription(
              name: 'number',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .postNumberToSharedStream(
                    session,
                    params['number'],
                  ),
        ),
        'createSimpleData': _i1.MethodConnector(
          name: 'createSimpleData',
          params: {
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .createSimpleData(
                    session,
                    params['data'],
                  ),
        ),
        'getAllSimpleData': _i1.MethodConnector(
          name: 'getAllSimpleData',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .getAllSimpleData(session),
        ),
        'createSimpleDatasInsideTransactions': _i1.MethodConnector(
          name: 'createSimpleDatasInsideTransactions',
          params: {
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .createSimpleDatasInsideTransactions(
                    session,
                    params['data'],
                  ),
        ),
        'createSimpleDataAndThrowInsideTransaction': _i1.MethodConnector(
          name: 'createSimpleDataAndThrowInsideTransaction',
          params: {
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .createSimpleDataAndThrowInsideTransaction(
                    session,
                    params['data'],
                  ),
        ),
        'createSimpleDatasInParallelTransactionCalls': _i1.MethodConnector(
          name: 'createSimpleDatasInParallelTransactionCalls',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .createSimpleDatasInParallelTransactionCalls(session),
        ),
        'echoSimpleData': _i1.MethodConnector(
          name: 'echoSimpleData',
          params: {
            'simpleData': _i1.ParameterDescription(
              name: 'simpleData',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .echoSimpleData(
                    session,
                    params['simpleData'],
                  ),
        ),
        'echoSimpleDatas': _i1.MethodConnector(
          name: 'echoSimpleDatas',
          params: {
            'simpleDatas': _i1.ParameterDescription(
              name: 'simpleDatas',
              type: _i1.getType<List<_i3.SimpleData>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .echoSimpleDatas(
                    session,
                    params['simpleDatas'],
                  ),
        ),
        'echoTypes': _i1.MethodConnector(
          name: 'echoTypes',
          params: {
            'typesModel': _i1.ParameterDescription(
              name: 'typesModel',
              type: _i1.getType<_i4.Types>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['testTools'] as _i2.TestToolsEndpoint).echoTypes(
                    session,
                    params['typesModel'],
                  ),
        ),
        'echoTypesList': _i1.MethodConnector(
          name: 'echoTypesList',
          params: {
            'typesList': _i1.ParameterDescription(
              name: 'typesList',
              type: _i1.getType<List<_i4.Types>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .echoTypesList(
                    session,
                    params['typesList'],
                  ),
        ),
        'echoRecord': _i1.MethodConnector(
          name: 'echoRecord',
          params: {
            'record': _i1.ParameterDescription(
              name: 'record',
              type: _i1.getType<(String, (int, bool))>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .echoRecord(
                    session,
                    params['record'],
                  )
                  .then((record) => _i5.Protocol().mapRecordToJson(record)),
        ),
        'echoRecords': _i1.MethodConnector(
          name: 'echoRecords',
          params: {
            'records': _i1.ParameterDescription(
              name: 'records',
              type: _i1.getType<List<(String, (int, bool))>>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .echoRecords(
                    session,
                    params['records'],
                  )
                  .then(
                    (container) => _i5.Protocol().mapContainerToJson(container),
                  ),
        ),
        'returnRecordWithSerializableObject': _i1.MethodConnector(
          name: 'returnRecordWithSerializableObject',
          params: {
            'number': _i1.ParameterDescription(
              name: 'number',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnRecordWithSerializableObject(
                    session,
                    params['number'],
                    params['data'],
                  )
                  .then((record) => _i5.Protocol().mapRecordToJson(record)),
        ),
        'logMessageWithSession': _i1.MethodConnector(
          name: 'logMessageWithSession',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .logMessageWithSession(session),
        ),
        'addWillCloseListenerToSessionAndThrow': _i1.MethodConnector(
          name: 'addWillCloseListenerToSessionAndThrow',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .addWillCloseListenerToSessionAndThrow(session),
        ),
        'putInLocalCache': _i1.MethodConnector(
          name: 'putInLocalCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .putInLocalCache(
                    session,
                    params['key'],
                    params['data'],
                  ),
        ),
        'getFromLocalCache': _i1.MethodConnector(
          name: 'getFromLocalCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .getFromLocalCache(
                    session,
                    params['key'],
                  ),
        ),
        'putInLocalPrioCache': _i1.MethodConnector(
          name: 'putInLocalPrioCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .putInLocalPrioCache(
                    session,
                    params['key'],
                    params['data'],
                  ),
        ),
        'getFromLocalPrioCache': _i1.MethodConnector(
          name: 'getFromLocalPrioCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .getFromLocalPrioCache(
                    session,
                    params['key'],
                  ),
        ),
        'putInQueryCache': _i1.MethodConnector(
          name: 'putInQueryCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .putInQueryCache(
                    session,
                    params['key'],
                    params['data'],
                  ),
        ),
        'getFromQueryCache': _i1.MethodConnector(
          name: 'getFromQueryCache',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .getFromQueryCache(
                    session,
                    params['key'],
                  ),
        ),
        'putInLocalCacheWithGroup': _i1.MethodConnector(
          name: 'putInLocalCacheWithGroup',
          params: {
            'key': _i1.ParameterDescription(
              name: 'key',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'data': _i1.ParameterDescription(
              name: 'data',
              type: _i1.getType<_i3.SimpleData>(),
              nullable: false,
            ),
            'group': _i1.ParameterDescription(
              name: 'group',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .putInLocalCacheWithGroup(
                    session,
                    params['key'],
                    params['data'],
                    params['group'],
                  ),
        ),
        'returnsSessionIdFromStream': _i1.MethodStreamConnector(
          name: 'returnsSessionIdFromStream',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSessionIdFromStream(session),
        ),
        'returnsSessionEndpointAndMethodFromStream': _i1.MethodStreamConnector(
          name: 'returnsSessionEndpointAndMethodFromStream',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSessionEndpointAndMethodFromStream(session),
        ),
        'returnsStream': _i1.MethodStreamConnector(
          name: 'returnsStream',
          params: {
            'n': _i1.ParameterDescription(
              name: 'n',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsStream(
                    session,
                    params['n'],
                  ),
        ),
        'returnsListFromInputStream': _i1.MethodStreamConnector(
          name: 'returnsListFromInputStream',
          params: {},
          streamParams: {
            'numbers': _i1.StreamParameterDescription<int>(
              name: 'numbers',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.futureType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsListFromInputStream(
                    session,
                    streamParams['numbers']!.cast<int>(),
                  ),
        ),
        'returnsSimpleDataListFromInputStream': _i1.MethodStreamConnector(
          name: 'returnsSimpleDataListFromInputStream',
          params: {},
          streamParams: {
            'simpleDatas': _i1.StreamParameterDescription<_i3.SimpleData>(
              name: 'simpleDatas',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.futureType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSimpleDataListFromInputStream(
                    session,
                    streamParams['simpleDatas']!.cast<_i3.SimpleData>(),
                  ),
        ),
        'returnsStreamFromInputStream': _i1.MethodStreamConnector(
          name: 'returnsStreamFromInputStream',
          params: {},
          streamParams: {
            'numbers': _i1.StreamParameterDescription<int>(
              name: 'numbers',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsStreamFromInputStream(
                    session,
                    streamParams['numbers']!.cast<int>(),
                  ),
        ),
        'returnsSimpleDataStreamFromInputStream': _i1.MethodStreamConnector(
          name: 'returnsSimpleDataStreamFromInputStream',
          params: {},
          streamParams: {
            'simpleDatas': _i1.StreamParameterDescription<_i3.SimpleData>(
              name: 'simpleDatas',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .returnsSimpleDataStreamFromInputStream(
                    session,
                    streamParams['simpleDatas']!.cast<_i3.SimpleData>(),
                  ),
        ),
        'postNumberToSharedStreamAndReturnStream': _i1.MethodStreamConnector(
          name: 'postNumberToSharedStreamAndReturnStream',
          params: {
            'number': _i1.ParameterDescription(
              name: 'number',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .postNumberToSharedStreamAndReturnStream(
                    session,
                    params['number'],
                  ),
        ),
        'listenForNumbersOnSharedStream': _i1.MethodStreamConnector(
          name: 'listenForNumbersOnSharedStream',
          params: {},
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .listenForNumbersOnSharedStream(session),
        ),
        'recordEchoStream': _i1.MethodStreamConnector(
          name: 'recordEchoStream',
          params: {
            'initialValue': _i1.ParameterDescription(
              name: 'initialValue',
              type: _i1
                  .getType<
                    (
                      String,
                      (
                        Map<String, int>, {
                        bool flag,
                        _i3.SimpleData simpleData,
                      }),
                    )
                  >(),
              nullable: false,
            ),
          },
          streamParams: {
            'stream':
                _i1.StreamParameterDescription<
                  (
                    String,
                    (Map<String, int>, {bool flag, _i3.SimpleData simpleData}),
                  )
                >(
                  name: 'stream',
                  nullable: false,
                ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .recordEchoStream(
                    session,
                    params['initialValue'],
                    streamParams['stream']!
                        .cast<
                          (
                            String,
                            (
                              Map<String, int>, {
                              bool flag,
                              _i3.SimpleData simpleData,
                            }),
                          )
                        >(),
                  ),
        ),
        'listOfRecordEchoStream': _i1.MethodStreamConnector(
          name: 'listOfRecordEchoStream',
          params: {
            'initialValue': _i1.ParameterDescription(
              name: 'initialValue',
              type: _i1.getType<List<(String, int)>>(),
              nullable: false,
            ),
          },
          streamParams: {
            'stream': _i1.StreamParameterDescription<List<(String, int)>>(
              name: 'stream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .listOfRecordEchoStream(
                    session,
                    params['initialValue'],
                    streamParams['stream']!.cast<List<(String, int)>>(),
                  ),
        ),
        'nullableRecordEchoStream': _i1.MethodStreamConnector(
          name: 'nullableRecordEchoStream',
          params: {
            'initialValue': _i1.ParameterDescription(
              name: 'initialValue',
              type: _i1
                  .getType<
                    (
                      String,
                      (
                        Map<String, int>, {
                        bool flag,
                        _i3.SimpleData simpleData,
                      }),
                    )?
                  >(),
              nullable: true,
            ),
          },
          streamParams: {
            'stream':
                _i1.StreamParameterDescription<
                  (
                    String,
                    (Map<String, int>, {bool flag, _i3.SimpleData simpleData}),
                  )?
                >(
                  name: 'stream',
                  nullable: false,
                ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .nullableRecordEchoStream(
                    session,
                    params['initialValue'],
                    streamParams['stream']!
                        .cast<
                          (
                            String,
                            (
                              Map<String, int>, {
                              bool flag,
                              _i3.SimpleData simpleData,
                            }),
                          )?
                        >(),
                  ),
        ),
        'nullableListOfRecordEchoStream': _i1.MethodStreamConnector(
          name: 'nullableListOfRecordEchoStream',
          params: {
            'initialValue': _i1.ParameterDescription(
              name: 'initialValue',
              type: _i1.getType<List<(String, int)>?>(),
              nullable: true,
            ),
          },
          streamParams: {
            'stream': _i1.StreamParameterDescription<List<(String, int)>?>(
              name: 'stream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .nullableListOfRecordEchoStream(
                    session,
                    params['initialValue'],
                    streamParams['stream']!.cast<List<(String, int)>?>(),
                  ),
        ),
        'modelWithRecordsEchoStream': _i1.MethodStreamConnector(
          name: 'modelWithRecordsEchoStream',
          params: {
            'initialValue': _i1.ParameterDescription(
              name: 'initialValue',
              type: _i1.getType<_i6.TypesRecord?>(),
              nullable: true,
            ),
          },
          streamParams: {
            'stream': _i1.StreamParameterDescription<_i6.TypesRecord?>(
              name: 'stream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                  .modelWithRecordsEchoStream(
                    session,
                    params['initialValue'],
                    streamParams['stream']!.cast<_i6.TypesRecord?>(),
                  ),
        ),
        'addWillCloseListenerToSessionIntStreamMethodAndThrow':
            _i1.MethodStreamConnector(
              name: 'addWillCloseListenerToSessionIntStreamMethodAndThrow',
              params: {},
              streamParams: {},
              returnType: _i1.MethodStreamReturnType.streamType,
              call:
                  (
                    _i1.Session session,
                    Map<String, dynamic> params,
                    Map<String, Stream> streamParams,
                  ) => (endpoints['testTools'] as _i2.TestToolsEndpoint)
                      .addWillCloseListenerToSessionIntStreamMethodAndThrow(
                        session,
                      ),
            ),
      },
    );
    connectors['authenticatedTestTools'] = _i1.EndpointConnector(
      name: 'authenticatedTestTools',
      endpoint: endpoints['authenticatedTestTools']!,
      methodConnectors: {
        'returnsString': _i1.MethodConnector(
          name: 'returnsString',
          params: {
            'string': _i1.ParameterDescription(
              name: 'string',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['authenticatedTestTools']
                          as _i2.AuthenticatedTestToolsEndpoint)
                      .returnsString(
                        session,
                        params['string'],
                      ),
        ),
        'returnsStream': _i1.MethodStreamConnector(
          name: 'returnsStream',
          params: {
            'n': _i1.ParameterDescription(
              name: 'n',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          streamParams: {},
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['authenticatedTestTools']
                          as _i2.AuthenticatedTestToolsEndpoint)
                      .returnsStream(
                        session,
                        params['n'],
                      ),
        ),
        'returnsListFromInputStream': _i1.MethodStreamConnector(
          name: 'returnsListFromInputStream',
          params: {},
          streamParams: {
            'numbers': _i1.StreamParameterDescription<int>(
              name: 'numbers',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.futureType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['authenticatedTestTools']
                          as _i2.AuthenticatedTestToolsEndpoint)
                      .returnsListFromInputStream(
                        session,
                        streamParams['numbers']!.cast<int>(),
                      ),
        ),
        'intEchoStream': _i1.MethodStreamConnector(
          name: 'intEchoStream',
          params: {},
          streamParams: {
            'stream': _i1.StreamParameterDescription<int>(
              name: 'stream',
              nullable: false,
            ),
          },
          returnType: _i1.MethodStreamReturnType.streamType,
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
                Map<String, Stream> streamParams,
              ) =>
                  (endpoints['authenticatedTestTools']
                          as _i2.AuthenticatedTestToolsEndpoint)
                      .intEchoStream(
                        session,
                        streamParams['stream']!.cast<int>(),
                      ),
        ),
      },
    );
  }
}
