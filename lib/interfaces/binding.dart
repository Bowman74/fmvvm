part of fmvvm.interfaces;

abstract class Binding { 

  BindableBase source;

  BindingDirection get bindingDirection;

  PropertyInfo get sourceProperty;

  ValueConverter get valueConverter;
}

enum BindingDirection { OneWay, TwoWay, OneTime }