part of fmvvm.interfaces;

/// Interface for information about a property that can be bound to.
/// 
/// Normally this will not be implemented by someone using the framework.
abstract class PropertyInfo { 
  /// The name of the property.
  String get name;

  /// The type of the property.
  Type get type;

  /// A properties default value.
  /// 
  /// Used if the property is called before being explicitly set.
  Object get defaultValue;

  /// A unique id used by fmvvm to tie this propertyinfo to a backing field in a class instance.
  int get id;

  /// Used by fmvvm to create backing information for this property info.
  FieldData createFieldData();
}