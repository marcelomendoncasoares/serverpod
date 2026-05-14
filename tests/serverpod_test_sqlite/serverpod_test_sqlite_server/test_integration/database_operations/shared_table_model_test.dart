import 'package:serverpod/serverpod.dart';
import 'package:serverpod_test_sqlite_shared/serverpod_test_sqlite_shared.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod(
    'Given SharedTableModel from the shared package',
    (sessionBuilder, _) {
      late Session session;

      setUp(() async {
        session = sessionBuilder.build();
      });

      test(
        'when inserting a SharedTableModel then it can be read back.',
        () async {
          var inserted = await SharedTableModel.db.insertRow(
            session,
            SharedTableModel(name: 'shared-sqlite'),
          );

          expect(inserted.id, isNotNull);
          expect(inserted.name, 'shared-sqlite');

          var found = await SharedTableModel.db.findById(session, inserted.id!);
          expect(found, isNotNull);
          expect(found!.name, 'shared-sqlite');
        },
      );
    },
  );
}
