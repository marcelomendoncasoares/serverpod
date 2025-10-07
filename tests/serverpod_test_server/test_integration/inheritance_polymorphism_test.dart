import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() async {
  withServerpod('Polymorphism Integration Tests', (sessionBuilder, endpoints) {
    late String runtimeType;
    late PolymorphicParent returned;

    group(
        'Given a PolymorphicParent object '
        'when sent through polymorphicRoundtrip', () {
      final original = PolymorphicParent(parent: 'This is a parent');

      setUpAll(() async {
        (runtimeType, returned) = await endpoints.inheritancePolymorphismTest
            .polymorphicRoundtrip(sessionBuilder, original);
      });

      test(
          'then the object received on the server has the expected runtimeType.',
          () async {
        expect(runtimeType, 'PolymorphicParent');
      });

      test('then the returned object has the expected type.', () async {
        expect(returned, isA<PolymorphicParent>());
      });

      test('then the returned object matches the original.', () async {
        expect(returned.toJson(), original.toJson());
      });
    });

    group(
        'Given a PolymorphicChild object '
        'when sent through polymorphicRoundtrip', () {
      final original = PolymorphicChild(
        parent: 'This is a parent',
        child: 'This is a child',
      );

      setUpAll(() async {
        (runtimeType, returned) = await endpoints.inheritancePolymorphismTest
            .polymorphicRoundtrip(sessionBuilder, original);
      });

      test(
          'then the object received on the server has the expected runtimeType.',
          () async {
        expect(runtimeType, 'PolymorphicChild');
      });

      test('then the returned object has the expected type.', () async {
        expect(returned, isA<PolymorphicChild>());
      });

      test('then the returned object matches the original.', () async {
        expect(returned.toJson(), original.toJson());
      });
    });

    group(
        'Given a PolymorphicGrandChild object '
        'when sent through polymorphicRoundtrip', () {
      final original = PolymorphicGrandChild(
        parent: 'This is a parent',
        child: 'This is a child',
        grandchild: 'This is a grandchild',
      );

      setUpAll(() async {
        (runtimeType, returned) = await endpoints.inheritancePolymorphismTest
            .polymorphicRoundtrip(sessionBuilder, original);
      });

      test(
          'then the object received on the server has the expected runtimeType.',
          () async {
        expect(runtimeType, '_PolymorphicGrandChildImpl');
      });

      test('then the returned object has the expected type.', () async {
        expect(returned, isA<PolymorphicGrandChild>());
      });

      test('then the returned object matches the original.', () async {
        expect(returned.toJson(), original.toJson());
      });
    });

    group(
        'Given a PolymorphicChildContainer object '
        'when sent through polymorphicContainerRoundtrip', () {
      var original = PolymorphicChildContainer(
        child: PolymorphicGrandChild(
          parent: 'PolymorphicParent 1',
          child: 'PolymorphicChild 1',
          grandchild: 'PolymorphicGrandChild 1',
        ),
        childrenList: [
          PolymorphicChild(
            parent: 'PolymorphicParent 2',
            child: 'PolymorphicChild 2',
          ),
          PolymorphicGrandChild(
            parent: 'PolymorphicParent 3',
            child: 'PolymorphicChild 3',
            grandchild: 'PolymorphicGrandChild 3',
          ),
        ],
        childrenMap: {
          'child4': PolymorphicChild(
            parent: 'PolymorphicParent 4',
            child: 'PolymorphicChild 4',
          ),
          'child5': PolymorphicGrandChild(
            parent: 'PolymorphicParent 5',
            child: 'PolymorphicChild 5',
            grandchild: 'PolymorphicGrandChild 5',
          ),
        },
      );

      late PolymorphicChildContainer returned;
      setUpAll(() async {
        returned = await endpoints.inheritancePolymorphismTest
            .polymorphicContainerRoundtrip(sessionBuilder, original);
      });

      test(
          'then all polymorphic objects in the returned object has the expected types.',
          () {
        expect(returned.child, isA<PolymorphicGrandChild>());

        var childrenList = returned.childrenList;
        expect(childrenList[0], isA<PolymorphicChild>());
        expect(childrenList[0], isNot(isA<PolymorphicGrandChild>()));
        expect(childrenList[1], isA<PolymorphicGrandChild>());

        var childrenMap = returned.childrenMap;
        expect(childrenMap['child4'], isA<PolymorphicChild>());
        expect(childrenMap['child4'], isNot(isA<PolymorphicGrandChild>()));
        expect(childrenMap['child5'], isA<PolymorphicGrandChild>());
      });

      test('then the returned object matches the original.', () async {
        expect(returned.toJson(), original.toJson());
      });
    });
  });
}
