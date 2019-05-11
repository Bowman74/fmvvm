import 'package:flutter_test/flutter_test.dart';
import "dart:async";

import 'package:fmvvm/bindings/bindings.dart';

void main() {
  test('ensures a property is set correctly', () {
    final testViewModel = _TestViewModel();
    String _expectedValue = 'foo';

    testViewModel.stringTest = _expectedValue;
    expect(testViewModel.stringTest, _expectedValue);
  });

    test('ensures onChanged raised correctly', () {
      final testViewModel = _TestViewModel();
      Timer t;

      testViewModel.onChanged.first.then(expectAsync1((e) {
      expect(e, equals("stringTest"));
      if (t != null) {
        t.cancel();
      }
    }));


      String _expectedValue = 'foo';

    t = new Timer(new Duration(seconds: 3), () {
      fail('event not fired in time');
    });

      testViewModel.stringTest = _expectedValue;
  });

  test('string property has correct default value', () {
    final testViewModel = _TestViewModel();

    expect(testViewModel.stringTest, '');
  });

  test('int property has correct default value', () {
    final testViewModel = _TestViewModel();

    expect(testViewModel.intTest, 0);
  });

  test('double property has correct default value', () {
    final testViewModel = _TestViewModel();

    expect(testViewModel.doubleTest, 0.0);
  });

  test('datetime property has correct default value', () {
    final testViewModel = _TestViewModel();

    expect(testViewModel.dateTimeTest, DateTime.fromMicrosecondsSinceEpoch(0));
  });

  test('reference type property has correct default value', () {
    final testViewModel = _TestViewModel();

    expect(testViewModel.referenceTypeTest, null);
  });
}

class _TestViewModel extends BindableBase {
  
  static PropertyInfo stringTestProperty = PropertyInfo('stringTest', String);

  String get stringTest => getValue(stringTestProperty);
  set stringTest(String value) => {
      setValue(stringTestProperty, value),
  };

  static PropertyInfo intTestProperty = PropertyInfo('intTest', int);

  int get intTest => getValue(intTestProperty);
  set intTest(int value) => {
      setValue(intTestProperty, value),
    };

  static PropertyInfo doubleTestProperty = PropertyInfo('doubleTest', double);

  double get doubleTest => getValue(doubleTestProperty);
  set doubleTest(double value) => {
      setValue(doubleTestProperty, value),
    };

  static PropertyInfo dateTimeTestProperty = PropertyInfo('dateTimeTest', DateTime);

  DateTime get dateTimeTest => getValue(dateTimeTestProperty);
  set dateTimeTest(DateTime value) => {
      setValue(dateTimeTestProperty, value),
    };

  static PropertyInfo referenceTypeTestProperty = PropertyInfo('referenceTypeTest', _TestViewModel);

  _TestViewModel get referenceTypeTest => getValue(referenceTypeTestProperty);
  set referenceTypeTest(_TestViewModel value) => {
      setValue(referenceTypeTestProperty, value),
    };
}
