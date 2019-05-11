part of fmvvm_bindings;

class Binding {
  Binding(BindableBase source, PropertyInfo sourceProperty, 
      {BindingDirection bindingDirection,
      ValueConverter valueConverter}) {
    this.source = source;
    _sourceProperty = sourceProperty;

    _bindingDirection = bindingDirection ?? BindingDirection.OneWay;
    _valueConverter = valueConverter;
  }

  BindingDirection _bindingDirection;

  PropertyInfo _sourceProperty;

  ValueConverter _valueConverter;

  BindableBase source;

  BindingDirection get bindingDirection => _bindingDirection;

  PropertyInfo get sourceProperty => _sourceProperty;

  ValueConverter get valueConverter => _valueConverter;

  Object _originalValue = _OriginalValueNeverSet;
}

enum BindingDirection { OneWay, TwoWay, OneTime }

class _OriginalValueNeverSet {}
