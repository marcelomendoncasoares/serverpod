import 'package:serverpod/serverpod.dart';
import 'package:serverpod_service_client/serverpod_service_client.dart';

class InsightsEndpoint extends Endpoint {
  Future<void> executeSql(Session session, String sql) async {
    await session.db.unsafeExecute(sql);
  }

  Future<DatabaseDefinition> getLiveDatabaseDefinition(Session session) async {
    final serverDefinition = await session.db.analyzer.analyze();
    // NOTE: This roundtrip is needed because the type returned by the analyze
    // method is declared in the `serverpod` package, but we need to use the
    // one from the `serverpod_service_client` to be able to import on the
    // client side.
    return DatabaseDefinition.fromJson(serverDefinition.toJson());
  }
}
