import 'package:flutter_test/flutter_test.dart';

import 'package:fmvvm/fmvvm.dart';
import 'package:fmvvm/bindings/bindings.dart';

void main() {
  test('Single instance can be registered and retrieved from IoC container as generic', () {
    final simpleConstructor = _SimpleConstructor();
    String _expectedValue = 'foo';

    simpleConstructor.stringTest = _expectedValue;

    var container = ComponentResolver();
    container.resetRegistrations();

    container.registerInstance(simpleConstructor);

    var retrievedInstance = container.resolveType<_SimpleConstructor>();

    expect(retrievedInstance, isNotNull);
    expect(retrievedInstance.stringTest, _expectedValue);
  });

  test('Single instance can be registered and retrieved from IoC container as type', () {
    final simpleConstructor = _SimpleConstructor();
    String _expectedValue = 'foo';

    simpleConstructor.stringTest = _expectedValue;

    var container = ComponentResolver();
    container.resetRegistrations();

    container.registerInstance(simpleConstructor);

    var retrievedInstance = container.resolve(_SimpleConstructor) as _SimpleConstructor;

    expect(retrievedInstance, isNotNull);
    expect(retrievedInstance.stringTest, _expectedValue);
  });

test('Factory instance can be registered and retrieved from IoC container as type', () {

    var container = ComponentResolver();
    container.resetRegistrations();

    container.registerType<_SimpleConstructor>(() {return _SimpleConstructor();});

    var retrievedInstance = container.resolve(_SimpleConstructor) as _SimpleConstructor;

    expect(retrievedInstance, isNotNull);
    expect(retrievedInstance.stringTest, "");
  });

  test('Complex factory instance can be registered and retrieved from IoC container as type', () {

    var container = ComponentResolver();
    container.resetRegistrations();

    container.registerType<_SimpleConstructor>(() {return _SimpleConstructor();});
    container.registerType<_ComplexConstructor>(() {return _ComplexConstructor(container.resolveType<_SimpleConstructor>());});

    var retrievedInstance = container.resolveType<_ComplexConstructor>();

    expect(retrievedInstance, isNotNull);
    expect(retrievedInstance.childObject, isNotNull);
    expect(retrievedInstance.childObject.stringTest, "");
  });
}


class _SimpleConstructor extends BindableBase {
  
  
  static PropertyInfo stringTestProperty = PropertyInfo('stringTest', String);

  String get stringTest => getValue(stringTestProperty);
  set stringTest(String value) => {
      setValue(stringTestProperty, value),
  };
}

class _ComplexConstructor extends BindableBase {
  _ComplexConstructor(_SimpleConstructor simpleConstructor) {
    childObject = simpleConstructor;
  }
  
  static PropertyInfo childObjectProperty = PropertyInfo('childObject', _SimpleConstructor);

  _SimpleConstructor get childObject => getValue(childObjectProperty);
  set childObject(_SimpleConstructor value) => {
      setValue(childObjectProperty, value),
  };
}