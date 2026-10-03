import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:code_builder/code_builder.dart' as code;
import 'package:serverpod_cli/src/generator/code_generator.dart';
import 'package:serverpod_cli/src/generator/dart/library_generators/protocol_deserialization_generator.dart';

// Re-emits only routing with the actual branch generator. Keeping the existing
// models, decoder bodies, and dependency order isolates routing in the benchmark.
void main(List<String> arguments) {
  final paths = (jsonDecode(File(arguments.single).readAsStringSync()) as List)
      .cast<String>();
  final counts = <String, Object>{};

  for (final path in paths) {
    final file = File(path);
    final source = file.readAsStringSync();
    final unit = parseString(content: source).unit;
    final protocol = unit.declarations
        .whereType<ClassDeclaration>()
        .singleWhere(
          (declaration) => declaration.namePart.typeName.lexeme == 'Protocol',
        );
    if (protocol.implementsClause != null) {
      throw StateError('Unexpected existing protocol interfaces: $path');
    }

    final members = (protocol.body as BlockClassBody).members;
    final method = members.whereType<MethodDeclaration>().singleWhere(
      (member) => member.name.lexeme == 'deserialize',
    );
    final statements = (method.body as BlockFunctionBody).block.statements;
    final branches = statements.whereType<IfStatement>().where((statement) {
      final condition = statement.expression;
      return condition is BinaryExpression &&
          condition.operator.lexeme == '==' &&
          condition.leftOperand.toSource() == 't';
    }).toList();
    final probes = statements.whereType<TryStatement>().toList();
    if (probes.isNotEmpty) {
      final first = statements.indexOf(probes.first);
      for (final (index, probe) in probes.indexed) {
        if (!identical(statements[first + index], probe)) {
          throw StateError('Module probes are not consecutive: $path');
        }
      }
    }
    final moduleExpressions = <code.Expression>[];

    for (final probe in probes) {
      final result = probe.body.statements.single as ReturnStatement;
      final call = result.expression as MethodInvocation;
      if (call.methodName.name != 'deserialize' ||
          call.target == null ||
          !probe.catchClauses.single.exceptionType!.toSource().endsWith(
            '.DeserializationTypeNotFoundException',
          )) {
        throw StateError('Unexpected module probe: ${probe.toSource()}');
      }
      moduleExpressions.add(
        code.CodeExpression(code.Code(call.target!.toSource())),
      );
    }

    final generator = ProtocolDeserializationGenerator(
      runtimeUrl:
          'package:serverpod_serialization/serverpod_serialization.dart',
    );
    final emitted = code.Library(
      (library) => library.body.add(
        code.Class(
          (declaration) => declaration
            ..name = 'Routing'
            ..implements.add(
              generator.provider(
                databaseRuntimeUrl:
                    protocol.extendsClause!.superclass.toSource().endsWith(
                      '.DatabaseSerializationManager',
                    )
                    ? 'package:serverpod_database/serverpod_database.dart'
                    : null,
              ),
            )
            ..fields.add(
              generator.metadata(
                types: branches.map(
                  (branch) => code.CodeExpression(
                    code.Code(
                      (branch.expression as BinaryExpression).rightOperand
                          .toSource(),
                    ),
                  ),
                ),
                modules: moduleExpressions,
              ),
            )
            ..methods.add(
              code.Method(
                (method) => method
                  ..name = 'route'
                  ..body = code.Block.of([generator.moduleFallback()]),
              ),
            ),
        ),
      ),
    ).generateCode();
    final generated = parseString(content: emitted).unit;
    final generatedClass = generated.declarations
        .whereType<ClassDeclaration>()
        .single;
    final generatedMembers = (generatedClass.body as BlockClassBody).members;
    final field = generatedMembers
        .whereType<FieldDeclaration>()
        .single
        .toSource();
    final routingMethod = generatedMembers
        .whereType<MethodDeclaration>()
        .single;
    final routingBody = (routingMethod.body as BlockFunctionBody)
        .block
        .statements
        .map((statement) => statement.toSource())
        .join('\n');
    final routingImports = generated.directives.whereType<ImportDirective>();
    final imports = unit.directives.whereType<ImportDirective>();
    final addedImports = <ImportDirective>[];
    for (final routingImport in routingImports) {
      final conflicting = imports.where(
        (directive) => directive.prefix?.name == routingImport.prefix?.name,
      );
      if (conflicting.any(
        (directive) =>
            directive.uri.stringValue != routingImport.uri.stringValue,
      )) {
        throw StateError(
          'Routing import conflicts with existing prefix: $path',
        );
      }
      if (conflicting.isEmpty) addedImports.add(routingImport);
    }

    final edits = <({int start, int end, String text})>[
      for (final routingImport in addedImports)
        (
          start: unit.directives.first.offset,
          end: unit.directives.first.offset,
          text: '${routingImport.toSource()}\n',
        ),
      (
        start: protocol.body.offset,
        end: protocol.body.offset,
        text: '${generatedClass.implementsClause!.toSource()} ',
      ),
      (
        start: members.first.offset,
        end: members.first.offset,
        text: '$field\n\n',
      ),
      if (probes.isNotEmpty)
        (start: probes.first.offset, end: probes.last.end, text: routingBody),
    ]..sort((a, b) => b.start.compareTo(a.start));
    var updated = source;
    for (final edit in edits) {
      updated = updated.replaceRange(edit.start, edit.end, edit.text);
    }
    file.writeAsStringSync(updated);
    counts[path] = {'types': branches.length, 'modules': probes.length};
  }

  print(jsonEncode(counts));
}
