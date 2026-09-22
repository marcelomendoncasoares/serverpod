import 'dart:convert';
import 'dart:io';

import 'package:package_config/package_config.dart';
import 'package:path/path.dart' as p;
import 'package:serverpod_cli/src/analyzer/models/stateful_analyzer.dart';
import 'package:serverpod_cli/src/generator/code_generation_collector.dart';
import 'package:serverpod_cli/src/generator/dart/server_code_generator.dart';
import 'package:test/test.dart';

import '../../../test_util/builders/generator_config_builder.dart';
import '../../../test_util/builders/model_source_builder.dart';

void main() {
  group(
    'Given immutable parent and child models with safe relations,',
    () {
      late List<ModelSourceBuilder> sources;

      setUpAll(() {
        sources = [
          ModelSourceBuilder().withFileName('example').withYaml('''
class: Example
table: example
immutable: true
fields:
  name: String
  parent: Example, relation(name=reports)
  manager: Example?, relation(optional)
  reports: List<Example>, relation(name=reports)
'''),
          ModelSourceBuilder().withFileName('child_example').withYaml('''
class: ChildExample
extends: Example
immutable: true
fields:
  extra: String
'''),
        ];
      });

      group('when compiling and running their generated APIs,', () {
        late Map<String, dynamic> result;

        setUpAll(() async {
          result = await _runGeneratedProgram(sources, '''
import 'dart:convert';

import 'package:serverpod/serverpod.dart';
import 'lib/src/generated/protocol.dart';

bool isUnloaded(Object? Function() read) {
  try {
    read();
  } on RelationNotLoadedError {
    return true;
  }
  return false;
}

void main() {
  const parent = Example(name: 'Parent', parentId: 1);
  const child = ChildExample(name: 'Child', parentId: 1, extra: 'original');

  final forwarded = ChildExample(
    name: 'Child',
    parentId: 1,
    extra: 'original',
    manager: parent.\$managerRelationValue,
  );
  final forwardedCopy = forwarded.copyWith();

  final copy = child.copyWith(extra: 'updated');
  final loaded = child.copyWith(parent: parent, manager: null, reports: []);
  final loadedCopy = loaded.copyWith();
  final decoded = ChildExample.fromJson({
    'name': 'Decoded',
    'parentId': 1,
    'extra': 'decoded',
    'manager': null,
  });

  print(jsonEncode({
    'parentUnloaded': [
      isUnloaded(() => parent.parent),
      isUnloaded(() => parent.manager),
      isUnloaded(() => parent.reports),
    ],
    'childUnloaded': [
      isUnloaded(() => copy.parent),
      isUnloaded(() => copy.manager),
      isUnloaded(() => copy.reports),
    ],
    'copyExtra': copy.extra,
    'unloadedJson': copy.toJson(),
    'loadedManager': loadedCopy.manager,
    'loadedReports': loadedCopy.reports.length,
    'loadedParent': loadedCopy.parent.name,
    'deepCopied': !identical(loadedCopy.parent, loaded.parent),
    'loadedJson': loadedCopy.toJsonForProtocol(),
    'unchangedEqual': child.copyWith() == child,
    'hashPreserved': child.copyWith().hashCode == child.hashCode,
    'nullDistinct': child.copyWith(manager: null) != child,
    'forwardedEqual': forwarded == child && child == forwarded,
    'forwardedHashEqual': forwarded.hashCode == child.hashCode,
    'forwardedCopyEqual': forwardedCopy == child,
    'forwardedCopyUnloaded': isUnloaded(() => forwardedCopy.manager),
    'forwardedJson': forwardedCopy.toJson(),
    'forwardedNullDistinct': forwarded != child.copyWith(manager: null) &&
        child.copyWith(manager: null) != forwarded,
    'decodedManager': decoded.manager,
    'decodedParentUnloaded': isUnloaded(() => decoded.parent),
  }));
}
''');
        });

        test(
          'then omitted relations stay unloaded through inheritance and copying.',
          () {
            expect(result['parentUnloaded'], [true, true, true]);
            expect(result['childUnloaded'], [true, true, true]);
            expect(result['copyExtra'], 'updated');
            expect(result['unloadedJson'], isNot(contains('manager')));
          },
        );

        test('then copied domain values keep their loaded states.', () {
          expect(result['loadedManager'], isNull);
          expect(result['loadedReports'], 0);
          expect(result['loadedParent'], 'Parent');
          expect(result['deepCopied'], isTrue);
          expect(result['loadedJson'], containsPair('manager', null));
        });

        test('then equality compares loading state without throwing.', () {
          expect(result['unchangedEqual'], isTrue);
          expect(result['hashPreserved'], isTrue);
          expect(result['nullDistinct'], isTrue);
        });

        test(
          'then unloaded defaults from different libraries compare and hash equally.',
          () {
            expect(result['forwardedEqual'], isTrue);
            expect(result['forwardedHashEqual'], isTrue);
            expect(result['forwardedCopyEqual'], isTrue);
            expect(result['forwardedNullDistinct'], isTrue);
          },
        );

        test(
          'then forwarding an unloaded default preserves copying and serialization.',
          () {
            expect(result['forwardedCopyUnloaded'], isTrue);
            expect(result['forwardedJson'], isNot(contains('manager')));
          },
        );

        test(
          'then deserialization preserves missing and explicit null relations.',
          () {
            expect(result['decodedManager'], isNull);
            expect(result['decodedParentUnloaded'], isTrue);
          },
        );
      });

      group('when analyzing invalid relation copyWith arguments,', () {
        late List<String> diagnostics;

        setUpAll(() async {
          final directory = await _generatePackage(sources);
          final entrypoint = File(p.join(directory.path, 'invalid.dart'))
            ..writeAsStringSync("""
import 'lib/src/generated/protocol.dart';

void invalid(Example parent, ChildExample child) {
  parent.copyWith(parent: null);
  child.copyWith(parent: null);
  parent.copyWith(reports: null);
  child.copyWith(reports: null);
  parent.copyWith(manager: 'wrong');
  child.copyWith(manager: 'wrong');
  parent.copyWith(reports: ['wrong']);
  child.copyWith(reports: ['wrong']);
}
""");

          final process = await Process.run(Platform.resolvedExecutable, [
            'analyze',
            '--format=machine',
            entrypoint.path,
          ], workingDirectory: directory.path);

          if (process.exitCode != 3) {
            throw StateError(
              'Expected analyzer errors:\n${process.stdout}\n${process.stderr}',
            );
          }

          diagnostics = (process.stdout as String)
              .split('\n')
              .where((line) => line.startsWith('ERROR|'))
              .toList();
        });

        test('then null is rejected for required and list relations.', () {
          expect(
            diagnostics.where(
              (line) => line.contains('|ARGUMENT_TYPE_NOT_ASSIGNABLE|'),
            ),
            hasLength(6),
          );
          expect(
            diagnostics.where((line) => line.contains("argument type 'Null'")),
            hasLength(4),
          );
        });

        test('then optional models and list elements retain their types.', () {
          expect(
            diagnostics.where(
              (line) => line.contains("argument type 'String'"),
            ),
            hasLength(2),
          );
          expect(
            diagnostics.where(
              (line) => line.contains('|LIST_ELEMENT_TYPE_NOT_ASSIGNABLE|'),
            ),
            hasLength(2),
          );
          expect(diagnostics, hasLength(8));
        });
      });
    },
    timeout: const Timeout(Duration(minutes: 2)),
  );
}

/// Compiles generated models in their own package, so private-library access
/// and constructor forwarding are checked by Dart as well as at runtime.
Future<Map<String, dynamic>> _runGeneratedProgram(
  List<ModelSourceBuilder> sources,
  String program,
) async {
  final directory = await _generatePackage(sources);
  final entrypoint = File(p.join(directory.path, 'main.dart'))
    ..writeAsStringSync(program);
  final process = await Process.run(Platform.resolvedExecutable, [
    '--packages=${p.join(directory.path, '.dart_tool', 'package_config.json')}',
    entrypoint.path,
  ]);

  if (process.exitCode != 0) {
    throw StateError(
      'Generated program failed:\n${process.stdout}\n${process.stderr}',
    );
  }

  return jsonDecode(process.stdout as String) as Map<String, dynamic>;
}

Future<Directory> _generatePackage(List<ModelSourceBuilder> sources) async {
  final directory = Directory.systemTemp.createTempSync('safe-relations-');
  addTearDown(() => directory.deleteSync(recursive: true));

  final workspacePackages = (await findPackageConfig(Directory.current))!;
  final packageConfig = PackageConfig.toJson(workspacePackages);
  final packages = packageConfig['packages'] as List<dynamic>;

  packages.add({
    'name': 'example_server',
    'rootUri': directory.uri.toString(),
    'packageUri': 'lib/',
    'languageVersion': '3.12',
  });
  final configFile = File(
    p.join(directory.path, '.dart_tool', 'package_config.json'),
  );
  configFile.parent.createSync(recursive: true);
  configFile.writeAsStringSync(jsonEncode(packageConfig));

  final config = GeneratorConfigBuilder().build();
  final collector = CodeGenerationCollector();
  final models = StatefulAnalyzer(
    config,
    sources.map((source) => source.build()).toList(),
    onErrorsCollector(collector),
  ).validateAll();
  if (collector.errors.isNotEmpty) {
    throw StateError(collector.errors.map((error) => error.message).join('\n'));
  }

  final code = const DartServerCodeGenerator().generateSerializableModelsCode(
    models: models,
    config: config,
  );
  for (final entry in code.entries) {
    final file = File(p.join(directory.path, entry.key));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(entry.value);
  }

  File(
    p.join(directory.path, 'lib', 'src', 'generated', 'protocol.dart'),
  ).writeAsStringSync('''
import 'package:serverpod/serverpod.dart';
export 'example.dart';
export 'child_example.dart';
class Protocol extends SerializationManager {}
''');

  return directory;
}
