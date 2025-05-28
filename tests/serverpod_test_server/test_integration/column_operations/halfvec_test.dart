import 'package:postgres/postgres.dart';
import 'package:serverpod/src/database/adapters/postgres/pgvector_encoder.dart';
import 'package:serverpod_serialization/serverpod_serialization.dart';

void main() async {
  var connection = await Connection.open(
    Endpoint(
      host: 'localhost',
      port: 5444,
      database: 'serverpod_test',
      username: 'postgres',
      password: 'password',
    ),
    settings: ConnectionSettings(
      sslMode: SslMode.disable,
      typeRegistry: TypeRegistry(encoders: [pgvectorEncoder]),
    ),
  );

  await connection.execute('''
    CREATE TABLE IF NOT EXISTS halfvec_test (
      id SERIAL PRIMARY KEY,
      embedding HALFVEC(3)
    );
  ''');

  // await connection.execute(
  //   Sql.named('INSERT INTO halfvec_test (embedding) VALUES (@a), (@b), (@c)'),
  //   parameters: {
  //     'a': const HalfVector([1, 0, 0]),
  //     'b': const HalfVector([0, 1, 0]),
  //     'c': const HalfVector([0, 0, 1]),
  //   },
  // );

  var results = await connection.execute('select * from halfvec_test;');
  var b = (results[0][1] as UndecodedBytes).bytes;
  print(HalfVector.fromBinary(b));

  print('end');
}
