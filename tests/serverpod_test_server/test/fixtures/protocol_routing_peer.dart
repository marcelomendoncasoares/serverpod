import 'dart:convert';
import 'dart:io';

import 'package:serverpod_test_client/serverpod_test_client.dart' as client;
import 'package:serverpod_test_module_client/serverpod_test_module_client.dart'
    as client_module;
import 'package:serverpod_test_module_server/serverpod_test_module_server.dart'
    as server_module;
import 'package:serverpod_test_server/src/generated/protocol.dart' as server;

// Run this peer with independently resolved old and new package configurations.
// Each peer writes wire JSON or reads JSON emitted by the opposite version.
void main(List<String> arguments) {
  final [side, action, path] = arguments;
  final protocol = side == 'client' ? client.Protocol() : server.Protocol();
  final databaseProtocol = side == 'client'
      ? server.Protocol()
      : server_module.Protocol();
  databaseProtocol.getTargetTableDefinitions();

  if (action == 'write') {
    final values = side == 'client'
        ? [
            client.SimpleData(num: 42),
            client_module.ModuleClass(name: 'entry', data: 7, record: (true,)),
            client_module.ModulePolymorphicChild(
              parent: 'base',
              child: 'child',
            ),
            client_module.DynamicOnModule(
              name: 'host',
              data: client.SimpleData(num: 11),
            ),
          ]
        : [
            server.SimpleData(num: 42),
            server_module.ModuleClass(name: 'entry', data: 7, record: (true,)),
            server_module.ModulePolymorphicChild(
              parent: 'base',
              child: 'child',
            ),
            server_module.DynamicOnModule(
              name: 'host',
              data: server.SimpleData(num: 11),
            ),
          ];
    File(path).writeAsStringSync(jsonEncode(values));
    return;
  }

  final data = (jsonDecode(File(path).readAsStringSync()) as List)
      .cast<Map<String, dynamic>>();
  final moduleRow = Map<String, dynamic>.from(data[1])..remove('__className__');
  final futureSubtype = <String, dynamic>{
    '__className__': 'future.NewSubtype',
    'parent': 'base',
  };

  if (side == 'client') {
    _check(
      protocol.deserialize<client.SimpleData>(data[0]).num == 42,
      'project',
    );
    final record = protocol.deserialize<client_module.ModuleClass>(data[1]);
    _check(
      record.name == 'entry' && record.data == 7 && record.record == (true,),
      'module record',
    );
    final typed = protocol.deserialize<Object>(
      moduleRow,
      client_module.ModuleClass,
    );
    _check(
      typed is client_module.ModuleClass && typed.data == 7,
      'typed module',
    );
    final child = protocol.deserialize<client_module.ModulePolymorphicParent>(
      data[2],
    );
    _check(
      child is client_module.ModulePolymorphicChild && child.child == 'child',
      'subtype',
    );
    final dynamic = protocol.deserialize<client_module.DynamicOnModule>(
      data[3],
    );
    _check(
      dynamic.data is client.SimpleData &&
          (dynamic.data as client.SimpleData).num == 11,
      'host dynamic',
    );
    final parent = protocol.deserialize<client_module.ModulePolymorphicParent>(
      futureSubtype,
    );
    _check(parent.parent == 'base', 'future subtype');
  } else {
    _check(
      protocol.deserialize<server.SimpleData>(data[0]).num == 42,
      'project',
    );
    final record = protocol.deserialize<server_module.ModuleClass>(data[1]);
    _check(
      record.name == 'entry' && record.data == 7 && record.record == (true,),
      'module record',
    );
    final typed = protocol.deserialize<Object>(
      moduleRow,
      server_module.ModuleClass,
    );
    _check(
      typed is server_module.ModuleClass && typed.data == 7,
      'typed module',
    );
    final child = protocol.deserialize<server_module.ModulePolymorphicParent>(
      data[2],
    );
    _check(
      child is server_module.ModulePolymorphicChild && child.child == 'child',
      'subtype',
    );
    final dynamic = protocol.deserialize<server_module.DynamicOnModule>(
      data[3],
    );
    _check(
      dynamic.data is server.SimpleData &&
          (dynamic.data as server.SimpleData).num == 11,
      'host dynamic',
    );
    final parent = protocol.deserialize<server_module.ModulePolymorphicParent>(
      futureSubtype,
    );
    _check(parent.parent == 'base', 'future subtype');
  }

  stdout.writeln('$side decoded all six compatibility cases');
}

void _check(bool condition, String label) {
  if (!condition) throw StateError('Failed compatibility case: $label');
}
