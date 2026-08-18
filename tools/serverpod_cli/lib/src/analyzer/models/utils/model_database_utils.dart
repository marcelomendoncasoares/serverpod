import 'package:serverpod_cli/src/analyzer/models/definitions.dart';
import 'package:serverpod_cli/src/util/model_helper.dart';

extension ModelClassDefinitionClientDatabase on ModelClassDefinition {
  /// Whether this host-owned model requires client-side database support.
  ///
  /// Shared-package and module models never count, even when [database] is
  /// [ModelDatabaseDefinition.client] or [ModelDatabaseDefinition.all].
  bool get isHostClientDatabaseTable {
    if (serverOnly || isSharedModel || !shouldGenerateTableCode(false)) {
      return false;
    }
    final alias = type.moduleAlias;
    return alias == null || alias == defaultModuleAlias;
  }
}

extension SerializableModelDefinitionsClientDatabase
    on Iterable<SerializableModelDefinition> {
  /// Whether the host project has non-shared models that require client-side
  /// database support.
  ///
  /// Only host-owned table models with [ModelDatabaseDefinition.client] or
  /// [ModelDatabaseDefinition.all] count. Shared-package tables owned by this
  /// project are counted separately by [hasSharedClientDatabaseTables]. Tables
  /// from dependent modules never enable client-side database support on their
  /// own; they are merged into the client schema once [hasClientDatabaseTables]
  /// passes.
  bool get hasHostClientDatabaseTables => whereType<ModelClassDefinition>().any(
    (model) => model.isHostClientDatabaseTable,
  );

  /// Whether a shared package owned by the current project contains a table
  /// that requires client-side database support.
  bool get hasSharedClientDatabaseTables =>
      whereType<ModelClassDefinition>().any(
        (model) =>
            model.isSharedModel &&
            !model.serverOnly &&
            model.shouldGenerateTableCode(false),
      );

  /// Whether the current project should generate a client-side database.
  ///
  /// True when the project owns at least one host table or shared-package table
  /// with [ModelDatabaseDefinition.client] or [ModelDatabaseDefinition.all].
  /// Tables from dependent modules do not enable this on their own.
  bool get hasClientDatabaseTables =>
      hasHostClientDatabaseTables || hasSharedClientDatabaseTables;
}
