import 'package:serverpod/serverpod.dart' show RelationNotLoadedError;
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import '../test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('[Safe relation loading]', (sessionBuilder, endpoints) {
    final session = sessionBuilder.build();

    group('Given a persisted company in a town without a mayor,', () {
      late Town town;
      late Company company;

      setUp(() async {
        town = await Town.db.insertRow(session, Town(name: 'Stockholm'));
        company = await Company.db.insertRow(
          session,
          Company(name: 'Serverpod', townId: town.id!),
        );
      });

      group('when finding the company without includes,', () {
        late Company found;

        setUp(() async {
          found = (await Company.db.findById(session, company.id!))!;
        });

        test('then its required town is unloaded.', () {
          expect(() => found.town, throwsA(isA<RelationNotLoadedError>()));
        });

        test('then serialization omits the unloaded relation.', () {
          expect(found.toJson().containsKey('town'), isFalse);
          expect(found.toJsonForProtocol().containsKey('town'), isFalse);
        });
      });

      group('when including the town and its absent mayor,', () {
        late Company found;

        setUp(() async {
          found = (await Company.db.findById(
            session,
            company.id!,
            include: Company.include(
              town: Town.include(mayor: Citizen.include()),
            ),
          ))!;
        });

        test('then the required town has a non-nullable domain type.', () {
          final Town includedTown = found.town;

          expect(includedTown.id, town.id);
          expect(includedTown.name, 'Stockholm');
        });

        test('then the optional mayor is loaded absent.', () {
          expect(found.town.mayor, isNull);
          expect(found.town.toJson(), containsPair('mayor', null));
        });
      });

      test(
        'when updating a company whose town is unloaded, '
        'then persistence succeeds and keeps the relation unloaded.',
        () async {
          final updated = await Company.db.updateRow(
            session,
            company.copyWith(name: 'Renamed'),
          );

          expect(updated.name, 'Renamed');
          expect(
            () => updated.town,
            throwsA(isA<RelationNotLoadedError>()),
          );
        },
      );

      test(
        'when including only the town, '
        'then its optional mayor remains unloaded.',
        () async {
          final found = (await Company.db.findById(
            session,
            company.id!,
            include: Company.include(town: Town.include()),
          ))!;

          expect(
            () => found.town.mayor,
            throwsA(isA<RelationNotLoadedError>()),
          );
        },
      );

      test(
        'when attaching a mayor using an unloaded town, '
        'then a subsequent include loads the mayor.',
        () async {
          final mayor = await Citizen.db.insertRow(
            session,
            Citizen(name: 'Ada', companyId: company.id!),
          );

          await Town.db.attachRow.mayor(session, town, mayor);
          final found = (await Town.db.findById(
            session,
            town.id!,
            include: Town.include(mayor: Citizen.include()),
          ))!;

          expect(found.mayor?.id, mayor.id);
          expect(found.mayor?.name, 'Ada');
        },
      );
    });

    group('Given a persisted customer without orders,', () {
      late Customer customer;

      setUp(() async {
        customer = await Customer.db.insertRow(session, Customer(name: 'Ada'));
      });

      test(
        'when querying without includes, '
        'then orders are unloaded.',
        () async {
          final found = (await Customer.db.findById(session, customer.id!))!;

          expect(
            () => found.orders,
            throwsA(isA<RelationNotLoadedError>()),
          );
        },
      );

      test(
        'when including orders, '
        'then orders are loaded empty.',
        () async {
          final found = (await Customer.db.findById(
            session,
            customer.id!,
            include: Customer.include(orders: Order.includeList()),
          ))!;

          final List<Order> orders = found.orders;
          expect(orders, isEmpty);
          expect(found.toJson(), containsPair('orders', isEmpty));
        },
      );

      group(
        'when inserting an order, including its comments and copying the customer,',
        () {
          late Customer found;
          late Customer copy;
          late Order order;

          setUp(() async {
            order = await Order.db.insertRow(
              session,
              Order(description: 'First', customerId: customer.id!),
            );
            found = (await Customer.db.findById(
              session,
              customer.id!,
              include: Customer.include(
                orders: Order.includeList(
                  include: Order.include(comments: Comment.includeList()),
                ),
              ),
            ))!;
            copy = found.copyWith();
          });

          test(
            'then safe and legacy includes both contain loaded collections.',
            () {
              expect(found.orders.single.id, order.id);
              expect(found.orders.single.comments, isEmpty);
            },
          );

          test('then the copy deep copies its loaded orders.', () {
            expect(copy.orders.single.id, order.id);
            expect(identical(copy.orders, found.orders), isFalse);
            expect(identical(copy.orders.single, found.orders.single), isFalse);
          });
        },
      );
    });

    test(
      'Given a town with a loaded absent mayor, '
      'when inserting and updating it, '
      'then returned models preserve loaded absence.',
      () async {
        final town = Town(name: 'Stockholm', mayor: null);

        final inserted = await Town.db.insertRow(session, town);
        final updated = await Town.db.updateRow(
          session,
          inserted.copyWith(name: 'Renamed'),
        );

        expect(inserted.mayor, isNull);
        expect(updated.mayor, isNull);
        expect(updated.toJson(), containsPair('mayor', null));
      },
    );

    test(
      'Given a company with a loaded town, '
      'when inserting and updating it, '
      'then returned models preserve the nested relation state.',
      () async {
        final town = await Town.db.insertRow(
          session,
          Town(name: 'Stockholm', mayor: null),
        );
        final company = Company(
          name: 'Serverpod',
          townId: town.id!,
          town: town,
        );

        final inserted = await Company.db.insertRow(session, company);
        final updated = await Company.db.updateRow(
          session,
          inserted.copyWith(name: 'Renamed'),
        );

        expect(inserted.town.id, town.id);
        expect(updated.town.id, town.id);
        expect(updated.town.mayor, isNull);
      },
    );

    test(
      'Given an immutable customer with a loaded empty order list, '
      'when inserting and updating it, '
      'then returned models preserve the loaded empty list.',
      () async {
        const customer = CustomerInt(name: 'Ada', orders: []);

        final inserted = await CustomerInt.db.insertRow(session, customer);
        final updated = await CustomerInt.db.updateRow(
          session,
          inserted.copyWith(name: 'Renamed'),
        );

        expect(inserted.orders, isEmpty);
        expect(updated.orders, isEmpty);
        expect(updated.name, 'Renamed');
      },
    );

    test(
      'Given an arena with an unloaded optional inverse team, '
      'when attaching and detaching the inverse relation, '
      'then loading state survives persistence.',
      () async {
        final arena = await Arena.db.insertRow(session, Arena(name: 'Arena'));
        final team = await Team.db.insertRow(session, Team(name: 'Team'));

        await Arena.db.attachRow.team(session, arena, team);
        final attached = (await Arena.db.findById(
          session,
          arena.id!,
          include: Arena.include(team: Team.include()),
        ))!;
        await Arena.db.detachRow.team(session, attached);
        final detached = (await Arena.db.findById(
          session,
          arena.id!,
          include: Arena.include(team: Team.include()),
        ))!;

        expect(attached.team?.id, team.id);
        expect(detached.team, isNull);
      },
    );
  });
}
