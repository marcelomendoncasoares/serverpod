import 'dart:convert';

import 'package:serverpod/serverpod.dart' show RelationNotLoadedError;
import 'package:serverpod_test_sqlite_client/serverpod_test_sqlite_client.dart'
    as client;
import 'package:serverpod_test_sqlite_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  group('Given a company with its required town omitted,', () {
    late Company company;

    setUp(() {
      company = Company(name: 'Serverpod', townId: 1);
    });

    test(
      'when reading its town, '
      'then the error identifies the relation.',
      () {
        expect(
          () => company.town,
          throwsA(
            isA<RelationNotLoadedError>()
                .having((e) => e.model, 'model', 'Company')
                .having((e) => e.relation, 'relation', 'town')
                .having(
                  (e) => e.message,
                  'message',
                  'Company.town was accessed but was not loaded.',
                )
                .having(
                  (e) => e.toString(),
                  'description',
                  'RelationNotLoadedError: '
                      'Company.town was accessed but was not loaded.',
                ),
          ),
        );
      },
    );

    test(
      'when accessing its town through an exception handler, '
      'then a state error escapes with its original stack trace.',
      () {
        Object? caught;
        StackTrace? caughtTrace;
        var handledAsException = false;

        try {
          try {
            company.town;
          } on Exception {
            handledAsException = true;
          }
        } catch (error, trace) {
          caught = error;
          caughtTrace = trace;
        }

        expect(handledAsException, isFalse);
        expect(caught, isA<RelationNotLoadedError>());
        expect(caught, isA<StateError>());
        expect((caught as StateError).stackTrace, isNotNull);
        expect(caught.stackTrace.toString(), caughtTrace.toString());
      },
    );

    test(
      'when copying an unrelated field, '
      'then town remains unloaded.',
      () {
        final copy = company.copyWith(name: 'Renamed');

        expect(copy.name, 'Renamed');
        expect(() => copy.town, throwsA(isA<RelationNotLoadedError>()));
      },
    );

    test(
      'when serializing to the client and back, '
      'then the missing relation stays unloaded on both sides.',
      () {
        final wire =
            jsonDecode(jsonEncode(company.toJsonForProtocol()))
                as Map<String, dynamic>;
        final clientCompany = client.Company.fromJson(wire);
        final roundTrip = Company.fromJson(
          jsonDecode(jsonEncode(clientCompany.toJsonForProtocol()))
              as Map<String, dynamic>,
        );

        expect(wire.containsKey('town'), isFalse);
        expect(company.toJson().containsKey('town'), isFalse);
        expect(
          () => clientCompany.town,
          throwsA(isA<RelationNotLoadedError>()),
        );
        expect(
          () => roundTrip.town,
          throwsA(isA<RelationNotLoadedError>()),
        );
      },
    );
  });

  group('Given a town with its optional mayor omitted,', () {
    late Town town;

    setUp(() {
      town = Town(name: 'Stockholm');
    });

    test('when reading its mayor, '
        'then unloaded access throws.', () {
      expect(() => town.mayor, throwsA(isA<RelationNotLoadedError>()));
    });

    test('when copying its name, '
        'then mayor remains unloaded.', () {
      final copy = town.copyWith(name: 'Renamed');

      expect(() => copy.mayor, throwsA(isA<RelationNotLoadedError>()));
      expect(copy.toJson().containsKey('mayor'), isFalse);
    });

    test(
      'when copying with an explicit null mayor, '
      'then mayor is loaded absent.',
      () {
        final copy = town.copyWith(mayor: null);

        expect(copy.mayor, isNull);
        expect(copy.toJson(), containsPair('mayor', null));
      },
    );

    test('when assigning a null mayor, '
        'then mayor is loaded absent.', () {
      town.mayor = null;

      expect(town.mayor, isNull);
      expect(town.toJsonForProtocol(), containsPair('mayor', null));
    });
  });

  group('Given an explicitly absent optional mayor,', () {
    late Town town;

    setUp(() {
      town = Town(name: 'Stockholm', mayor: null);
    });

    test(
      'when copying without a mayor argument, '
      'then loaded absence is preserved.',
      () {
        final copy = town.copyWith();

        expect(copy.mayor, isNull);
        expect(copy.toJson(), containsPair('mayor', null));
      },
    );

    test(
      'when serializing to the client and back, '
      'then loaded absence survives both protocols.',
      () {
        final wire =
            jsonDecode(jsonEncode(town.toJsonForProtocol()))
                as Map<String, dynamic>;
        final clientTown = client.Town.fromJson(wire);
        final clientCopy = clientTown.copyWith();
        final roundTrip = Town.fromJson(
          jsonDecode(jsonEncode(clientCopy.toJsonForProtocol()))
              as Map<String, dynamic>,
        );

        expect(wire, containsPair('mayor', null));
        expect(clientTown.mayor, isNull);
        expect(clientCopy.mayor, isNull);
        expect(roundTrip.mayor, isNull);
      },
    );
  });

  test(
    'Given an old payload without an optional relation key, '
    'when the client deserializes it, '
    'then the relation remains unloaded.',
    () {
      final town = client.Town.fromJson({'name': 'Stockholm'});

      expect(() => town.mayor, throwsA(isA<RelationNotLoadedError>()));
      expect(
        () => town.copyWith().mayor,
        throwsA(isA<RelationNotLoadedError>()),
      );
    },
  );

  group('Given a customer with its orders omitted,', () {
    late Customer customer;

    setUp(() {
      customer = Customer(name: 'Ada');
    });

    test('when reading orders, '
        'then unloaded access throws.', () {
      expect(() => customer.orders, throwsA(isA<RelationNotLoadedError>()));
    });

    test('when copying without orders, '
        'then orders remain unloaded.', () {
      final copy = customer.copyWith();

      expect(() => copy.orders, throwsA(isA<RelationNotLoadedError>()));
      expect(copy.toJson().containsKey('orders'), isFalse);
    });

    test('when assigning an empty list, '
        'then orders are loaded empty.', () {
      customer.orders = [];

      expect(customer.orders, isEmpty);
      expect(customer.toJson(), containsPair('orders', isEmpty));
    });

    test('when copying with an empty list, '
        'then orders are loaded empty.', () {
      final copy = customer.copyWith(orders: []);

      expect(copy.orders, isEmpty);
      expect(copy.toJsonForProtocol(), containsPair('orders', isEmpty));
    });
  });

  test(
    'Given a customer with an empty loaded order list, '
    'when round-tripping through client JSON, '
    'then orders stay loaded empty.',
    () {
      final customer = Customer(name: 'Ada', orders: []);

      final clientCustomer = client.Customer.fromJson(customer.toJson());
      final roundTrip = Customer.fromJson(clientCustomer.copyWith().toJson());

      expect(clientCustomer.orders, isEmpty);
      expect(roundTrip.orders, isEmpty);
    },
  );

  test(
    'Given a loaded required town, '
    'when copying with an omitted town, '
    'then the loaded value is deep copied.',
    () {
      final town = Town(name: 'Stockholm', mayor: null);
      final company = Company(name: 'Serverpod', townId: 1, town: town);

      final omitted = company.copyWith();

      expect(omitted.town.name, 'Stockholm');
      expect(identical(omitted.town, town), isFalse);
      expect(omitted.town.mayor, isNull);
    },
  );

  test(
    'Given replacement values for safe relations, '
    'when copying models with those values, '
    'then related models and lists are deep copied.',
    () {
      final town = Town(name: 'Stockholm');
      final mayor = Citizen(name: 'Ada', companyId: 1);
      final order = Order(description: 'First', customerId: 1);
      final orders = [order];

      final company = Company(
        name: 'Serverpod',
        townId: 1,
      ).copyWith(town: town);
      final withMayor = town.copyWith(mayor: mayor);
      final customer = Customer(name: 'Ada').copyWith(orders: orders);

      expect(identical(company.town, town), isFalse);
      expect(identical(withMayor.mayor, mayor), isFalse);
      expect(identical(customer.orders, orders), isFalse);
      expect(identical(customer.orders.single, order), isFalse);
      expect(customer.orders.single.description, 'First');
    },
  );

  test(
    'Given legacy nullable required and list relations, '
    'when constructing and copying without relations, '
    'then their getters still return null.',
    () {
      final citizen = Citizen(name: 'Ada', companyId: 1);
      final order = Order(description: 'First', customerId: 1);

      expect(citizen.company, isNull);
      expect(citizen.copyWith().company, isNull);
      expect(order.comments, isNull);
      expect(order.copyWith().comments, isNull);
    },
  );

  test(
    'Given client models with omitted safe relations, '
    'when assigning domain values, '
    'then required, optional and list getters expose those values.',
    () {
      final company = client.Company(name: 'Serverpod', townId: 1);
      final town = client.Town(name: 'Stockholm');
      final customer = client.Customer(name: 'Ada');

      company.town = town;
      town.mayor = null;
      customer.orders = [];

      expect(company.town, same(town));
      expect(town.mayor, isNull);
      expect(customer.orders, isEmpty);
    },
  );

  test(
    'Given immutable models with omitted relations, '
    'when copying and comparing them, '
    'then unloaded state is preserved without invoking getters.',
    () {
      const town = TownInt(name: 'Stockholm');
      const company = CompanyUuid(name: 'Serverpod', townId: 1);
      const customer = CustomerInt(name: 'Ada');

      final townCopy = town.copyWith();
      final companyCopy = company.copyWith();
      final customerCopy = customer.copyWith();

      expect(townCopy, town);
      expect(townCopy.hashCode, town.hashCode);
      expect(companyCopy, company);
      expect(companyCopy.hashCode, company.hashCode);
      expect(customerCopy, customer);
      expect(customerCopy.hashCode, customer.hashCode);
      expect(() => townCopy.mayor, throwsA(isA<RelationNotLoadedError>()));
      expect(
        () => companyCopy.town,
        throwsA(isA<RelationNotLoadedError>()),
      );
      expect(
        () => customerCopy.orders,
        throwsA(isA<RelationNotLoadedError>()),
      );
    },
  );

  test(
    'Given an immutable town with an omitted mayor, '
    'when copying with an explicit null mayor, '
    'then loaded absence is distinct in equality and serialization.',
    () {
      const town = TownInt(name: 'Stockholm');

      final absent = town.copyWith(mayor: null);
      final copied = absent.copyWith();

      expect(absent.mayor, isNull);
      expect(absent, isNot(town));
      expect(copied, absent);
      expect(copied.hashCode, absent.hashCode);
      expect(copied.toJson(), containsPair('mayor', null));
    },
  );

  test(
    'Given immutable models with loaded relations, '
    'when copying replacement values, '
    'then required and list relations are deep copied.',
    () {
      const town = TownInt(name: 'Stockholm', mayor: null);
      final order = OrderUuid(description: 'First', customerId: 1);

      final company = const CompanyUuid(
        name: 'Serverpod',
        townId: 1,
      ).copyWith(town: town);
      final customer = const CustomerInt(name: 'Ada').copyWith(orders: [order]);
      final companyCopy = company.copyWith();
      final customerCopy = customer.copyWith();

      expect(companyCopy.town, town);
      expect(identical(company.town, town), isFalse);
      expect(companyCopy.town.mayor, isNull);
      expect(customerCopy.orders.single.description, 'First');
      expect(identical(customer.orders.single, order), isFalse);
      expect(identical(customerCopy.orders.single, order), isFalse);
    },
  );

  test(
    'Given immutable client models with omitted relations, '
    'when copying and round-tripping explicit domain values, '
    'then loading state and equality match the server contract.',
    () {
      const town = client.TownInt(name: 'Stockholm');
      const company = client.CompanyUuid(name: 'Serverpod', townId: 1);
      const customer = client.CustomerInt(name: 'Ada');

      final loadedTown = town.copyWith(mayor: null);
      final loadedCompany = company.copyWith(town: loadedTown);
      final loadedCustomer = customer.copyWith(orders: []);
      final roundTrip = client.CompanyUuid.fromJson(loadedCompany.toJson());

      expect(town.copyWith(), town);
      expect(town.copyWith().hashCode, town.hashCode);
      expect(loadedTown, isNot(town));
      expect(roundTrip.town.mayor, isNull);
      expect(loadedCustomer.orders, isEmpty);
      expect(
        () => company.copyWith().town,
        throwsA(isA<RelationNotLoadedError>()),
      );
      expect(
        () => customer.copyWith().orders,
        throwsA(isA<RelationNotLoadedError>()),
      );
    },
  );

  test(
    'Given a person with an omitted organization, '
    'when wrapping an implicit foreign key and copying the model, '
    'then organization remains unloaded.',
    () {
      final person = Person(name: 'Ada');

      final wrapped = PersonImplicit(person, $_cityCitizensCityId: 1);
      final copy = wrapped.copyWith();

      expect(copy.toJson(), containsPair('_cityCitizensCityId', 1));
      expect(
        () => copy.organization,
        throwsA(isA<RelationNotLoadedError>()),
      );
    },
  );

  test(
    'Given a person with an explicitly absent organization, '
    'when wrapping an implicit foreign key and copying the model, '
    'then organization remains loaded absent.',
    () {
      final person = Person(name: 'Ada', organization: null);

      final wrapped = PersonImplicit(person, $_cityCitizensCityId: 1);
      final copy = wrapped.copyWith();

      expect(copy.organization, isNull);
      expect(copy.toJson(), containsPair('organization', null));
    },
  );
}
