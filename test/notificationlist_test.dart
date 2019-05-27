import 'package:flutter_test/flutter_test.dart';
import 'package:fmvvm/bindings/bindings.dart';

void main() {
  test('Create NotificationList from List', () {
    var sourceList = List<_TestClass>();

    var class1 = _TestClass();
    class1.id = 1;
    class1.description = "first item";
    sourceList.add(class1);
    var class2 = _TestClass();
    class2.id = 2;
    class2.description = "second item";
    sourceList.add(class2);

    var filledList = NotificationList.from(sourceList);

    expect(filledList, isNotNull);
    expect(filledList.length, 2);
    filledList.singleWhere((l) => l.id == 1);
    filledList.singleWhere((l) => l.id == 2);
  });

  test('Create NotificationList filled from item', () {
    var class1 = _TestClass();
    class1.id = 1;
    class1.description = "first item";

    var filledList = NotificationList<_TestClass>.filled(1, class1);

    expect(filledList, isNotNull);
    expect(filledList.length, 1);
    filledList.singleWhere((l) => l.id == 1);
  });

  test('Create NotificationList filled of list', () {
    var sourceList = List<_TestClass>();

    var class1 = _TestClass();
    class1.id = 1;
    class1.description = "first item";
    sourceList.add(class1);
    var class2 = _TestClass();
    class2.id = 2;
    class2.description = "second item";
    sourceList.add(class2);

    var filledList = NotificationList<_TestClass>.of(sourceList);

    expect(filledList, isNotNull);
    expect(filledList.length, 2);
    filledList.singleWhere((l) => l.id == 1);
    filledList.singleWhere((l) => l.id == 2);
  });
}

class _TestClass {
  int id;
  String description;
}
