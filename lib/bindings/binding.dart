part of fmvvm.bindings;

/// Used for a binding between a widget and a object that implements BindableBase.
/// 
/// This item is usually created within a FmvvmState object.
class Binding {
  Binding(BindableBase source, PropertyInfo sourceProperty, 
      {BindingDirection bindingDirection,
      fmvvm_interfaces.ValueConverter valueConverter}) {
    this.source = source;
    _sourceProperty = sourceProperty;

    _bindingDirection = bindingDirection ?? BindingDirection.TwoWay;
    _valueConverter = valueConverter;
  }

  BindingDirection _bindingDirection;

  PropertyInfo _sourceProperty;

  fmvvm_interfaces.ValueConverter _valueConverter;

  /// The source bindable base object.  
  BindableBase source;

  /// If the binding only happens once or if it is able to be bi-directional.
  BindingDirection get bindingDirection => _bindingDirection;
  
  /// The propertyInfo object being bound to on the source.
  PropertyInfo get sourceProperty => _sourceProperty;

  /// An optional value converter to be used if the value needs to be changed when moving back and
  /// forth from the widget to the source.
  fmvvm_interfaces.ValueConverter get valueConverter => _valueConverter;

  Object originalValue = _OriginalValueNeverSet;
}

/// Used to tell if a Binding object's original value was ever set.
class _OriginalValueNeverSet {}

/// What type of binding to create.
enum BindingDirection { TwoWay, OneTime }