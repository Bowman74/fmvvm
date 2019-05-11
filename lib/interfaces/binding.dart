part of fmvvm.interfaces;

/// Interface for a binding between a widget and a object that implements BindableBase.
/// 
/// This item is usually created within a FmvvmState object.
abstract class Binding { 

  /// The source BindableBase object.
  BindableBase source;

  /// If the binding only happens once or if it is able to be bi-directional.
  BindingDirection get bindingDirection;

  /// The propertyInfo object being bound to on the source.
  PropertyInfo get sourceProperty;

  /// An optional value converter to be used if the value needs to be changed when moving back and
  /// forth from the widget to the source.
  ValueConverter get valueConverter;
}

/// What type of binding to create.
enum BindingDirection { TwoWay, OneTime }