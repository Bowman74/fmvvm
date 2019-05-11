part of fmvvm.bindings;

class Binding implements fmvvm_interfaces.Binding {
  Binding(BindableBase source, PropertyInfo sourceProperty, 
      {fmvvm_interfaces.BindingDirection bindingDirection,
      fmvvm_interfaces.ValueConverter valueConverter}) {
    this.source = source;
    _sourceProperty = sourceProperty;

    _bindingDirection = bindingDirection ?? fmvvm_interfaces.BindingDirection.OneWay;
    _valueConverter = valueConverter;
  }

  fmvvm_interfaces.BindingDirection _bindingDirection;

  PropertyInfo _sourceProperty;

  fmvvm_interfaces.ValueConverter _valueConverter;

  fmvvm_interfaces.BindableBase source;

  fmvvm_interfaces.BindingDirection get bindingDirection => _bindingDirection;

  PropertyInfo get sourceProperty => _sourceProperty;

  fmvvm_interfaces.ValueConverter get valueConverter => _valueConverter;

  Object originalValue = _OriginalValueNeverSet;
}

class _OriginalValueNeverSet {}
