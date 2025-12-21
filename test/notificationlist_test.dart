import 'package:flutter_test/flutter_test.dart';
import 'package:fmvvm/bindings/bindings.dart';

void main() {
  test('Create NotificationList from List', () {
    var sourceList = List<_TestClass>.empty(growable: true);

    var class1 = _TestClass(1, "first item");
    sourceList.add(class1);

    var class2 = _TestClass(2, "second item");
    sourceList.add(class2);

    var filledList = NotificationList.from(sourceList);

    expect(filledList, isNotNull);
    expect(filledList.length, 2);
    filledList.singleWhere((l) => l.id == 1);
    filledList.singleWhere((l) => l.id == 2);
  });

  test('Create NotificationList filled from item', () {
    var class1 = _TestClass(1, "first item");

    var filledList = NotificationList<_TestClass>.filled(1, class1);

    expect(filledList, isNotNull);
    expect(filledList.length, 1);
    filledList.singleWhere((l) => l.id == 1);
  });

  test('Create NotificationList filled of list', () {
    var sourceList = List<_TestClass>.empty(growable: true);

    var class1 = _TestClass(1, "first item");
    sourceList.add(class1);

    var class2 = _TestClass(2, "second item");
    sourceList.add(class2);

    var filledList = NotificationList<_TestClass>.of(sourceList);

    expect(filledList, isNotNull);
    expect(filledList.length, 2);
    filledList.singleWhere((l) => l.id == 1);
    filledList.singleWhere((l) => l.id == 2);
  });

  test('NotificationList can add an item', () {
    var filledList = NotificationList<_TestClass>();
    var class1 = _TestClass(1, "first item");

    filledList.add(class1);

    expect(filledList, isNotNull);
    expect(filledList.length, 1);
    filledList.singleWhere((l) => l.id == 1);
  });

  test('NotificationList can add multiple items', () {
    var sourceList = List<_TestClass>.empty(growable: true);

    var class1 = _TestClass(1, "first item");
    sourceList.add(class1);

    var class2 = _TestClass(2, "second item");
    sourceList.add(class2);

    var filledList = NotificationList<_TestClass>();

    filledList.addAll(sourceList);

    expect(filledList, isNotNull);
    expect(filledList.length, 2);
    filledList.singleWhere((l) => l.id == 1);
    filledList.singleWhere((l) => l.id == 2);
  });

  test('NotificationList can delete an item', () {
    var filledList = NotificationList<_TestClass>();
    var class1 = _TestClass(1, "first item");

    filledList.add(class1);
    filledList.remove(class1);

    expect(filledList, isNotNull);
    expect(filledList.length, 0);
    expect(filledList.isEmpty, true);
  });
}

class _TestClass {
  _TestClass(this.id, this.description);

  int id;
  String description;
}
