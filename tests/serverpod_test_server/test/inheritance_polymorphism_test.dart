import 'package:serverpod_test_server/src/generated/protocol.dart';
import 'package:test/test.dart';

void main() {
  test(
      'Given a PolymorphicParent object '
      'when serialized '
      'then it produces the JSON with the type key.', () {
    final parent = PolymorphicParent(
      parent: 'This is a parent',
    );

    final json = parent.toJson();

    expect(json['__className__'], 'PolymorphicParent');
    expect(json['parent'], 'This is a parent');
  });

  test(
      'Given a PolymorphicChild object '
      'when serialized '
      'then it produces the JSON with the type key.', () {
    final child = PolymorphicChild(
      parent: 'This is a parent',
      child: 'This is a child',
    );

    final json = child.toJson();

    expect(json['__className__'], 'PolymorphicChild');
    expect(json['child'], 'This is a child');
    expect(json['parent'], 'This is a parent');
  });

  test(
      'Given a PolymorphicGrandChild object '
      'when serialized '
      'then it produces the JSON with the type key.', () {
    final grandPolymorphicChild = PolymorphicGrandChild(
      parent: 'This is a parent',
      child: 'This is a child',
      grandchild: 'This is a grandchild',
    );

    final json = grandPolymorphicChild.toJson();

    expect(json['__className__'], 'PolymorphicGrandChild');
    expect(json['grandchild'], 'This is a grandchild');
    expect(json['child'], 'This is a child');
    expect(json['parent'], 'This is a parent');
  });

  test(
      'Given a backwards-compatible PolymorphicParent JSON without runtimeClassName '
      'when deserialized '
      'then it deserializes as PolymorphicParent.', () {
    final json = {
      'parent': 'This is a parent',
    };

    final deserialized = Protocol().deserialize<PolymorphicParent>(json);

    expect(deserialized, isA<PolymorphicParent>());
    expect(deserialized.parent, 'This is a parent');
  });

  test(
      'Given a backwards-compatible PolymorphicChild JSON without runtimeClassName '
      'when deserialized '
      'then it deserializes as PolymorphicChild.', () {
    final json = {
      'parent': 'This is a parent',
      'child': 'This is a child',
    };

    final deserialized = Protocol().deserialize<PolymorphicChild>(json);

    expect(deserialized, isA<PolymorphicChild>());
    expect(deserialized.parent, 'This is a parent');
    expect(deserialized.child, 'This is a child');
  });

  test(
      'Given a backwards-compatible PolymorphicGrandChild JSON without runtimeClassName '
      'when deserialized '
      'then it deserializes as PolymorphicGrandChild.', () {
    final json = {
      'parent': 'This is a parent',
      'child': 'This is a child',
      'grandchild': 'This is a grandchild',
    };

    final deserialized = Protocol().deserialize<PolymorphicGrandChild>(json);

    expect(deserialized, isA<PolymorphicGrandChild>());
    expect(deserialized.parent, 'This is a parent');
    expect(deserialized.child, 'This is a child');
    expect(deserialized.grandchild, 'This is a grandchild');
  });

  test(
      'Given a PolymorphicChild object '
      'when deserialized as PolymorphicParent '
      'then it maintains the runtimeType as PolymorphicChild.', () {
    final child = PolymorphicChild(
      parent: 'This is a parent',
      child: 'This is a child',
    );

    final json = child.toJson();
    final deserialized = Protocol().deserialize<PolymorphicParent>(json);

    expect(deserialized.parent, 'This is a parent');
    expect(deserialized, isA<PolymorphicChild>());
    expect((deserialized as PolymorphicChild).child, 'This is a child');
  });

  test(
      'Given a PolymorphicGrandChild object '
      'when deserialized as PolymorphicParent '
      'then it maintains the runtimeType as PolymorphicGrandChild.', () {
    final grandPolymorphicChild = PolymorphicGrandChild(
      parent: 'This is a parent',
      child: 'This is a child',
      grandchild: 'This is a grandchild',
    );

    final json = grandPolymorphicChild.toJson();
    final deserialized = Protocol().deserialize<PolymorphicParent>(json);

    expect(deserialized.parent, 'This is a parent');
    expect(deserialized, isA<PolymorphicGrandChild>());
    expect((deserialized as PolymorphicGrandChild).child, 'This is a child');
    expect(deserialized.grandchild, 'This is a grandchild');
  });

  test(
      'Given a PolymorphicGrandChild object '
      'when deserialized as PolymorphicChild '
      'then it maintains the runtimeType as PolymorphicGrandChild.', () {
    final grandPolymorphicChild = PolymorphicGrandChild(
      parent: 'This is a parent',
      child: 'This is a child',
      grandchild: 'This is a grandchild',
    );

    final json = grandPolymorphicChild.toJson();
    final deserialized = Protocol().deserialize<PolymorphicChild>(json);

    expect(deserialized.child, 'This is a child');
    expect(deserialized, isA<PolymorphicGrandChild>());
    expect((deserialized as PolymorphicGrandChild).grandchild,
        'This is a grandchild');
  });

  test(
      'Given a class that holds PolymorphicChild objects in a container '
      'when deserialized '
      'then PolymorphicGrandChild objects maintain their runtime type.', () {
    final container = PolymorphicChildContainer(
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

    final json = container.toJson();
    final deserialized =
        Protocol().deserialize<PolymorphicChildContainer>(json);

    expect(deserialized.child, isA<PolymorphicGrandChild>());
    expect(deserialized.childrenList[0], isA<PolymorphicChild>());
    expect(deserialized.childrenList[0], isNot(isA<PolymorphicGrandChild>()));
    expect(deserialized.childrenList[1], isA<PolymorphicGrandChild>());
    expect(deserialized.childrenMap['child4'], isA<PolymorphicChild>());
    expect(deserialized.childrenMap['child4'],
        isNot(isA<PolymorphicGrandChild>()));
    expect(deserialized.childrenMap['child5'], isA<PolymorphicGrandChild>());
  });

  // This test would not fail before the changes to support polymorphism. If a class
  // was a subset of other with same types on all common fields, it would deserialize
  // as the other class.
  test(
      'Given an object that has all fields of PolymorphicParent '
      'when deserialized as PolymorphicParent then '
      'it raises an exception.', () {
    final other = SimilarButNotParent(parent: 'This is not a parent');

    final json = other.toJson();

    expect(
      () => Protocol().deserialize<PolymorphicParent>(json),
      throwsA(isA<TypeError>()),
    );
  });

  test(
      'Given an unrelated object that does not have PolymorphicParent fields '
      'when deserialized as PolymorphicParent '
      'then it raises an exception.', () {
    final unrelated = UnrelatedToPolymorphism(
      unrelated: 'An unrelated message',
    );

    final json = unrelated.toJson();

    expect(
      () => Protocol().deserialize<PolymorphicParent>(json),
      throwsA(isA<TypeError>()),
    );
  });
}
