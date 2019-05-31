part of fmvvm.bindings;

/// Information about a property that can be bound to.
///
/// These are normally static references within a class that
/// inherits from BindableBase.
class PropertyInfo {
  String _name;
  Object _defaultValue;
  Type _type;
  int _id = -1;

  /// Creates a new instance of PropertyInfo.
  ///
  /// [_name] - The name of the property, usualle the same as the name of the getter/setter
  /// [_type] - The type of the property.
  /// [defaultValue] - A default value for the property if it has not been set.
  PropertyInfo(this._name, this._type, [Object defaultValue]) {
    if (defaultValue == null && _type == String) {
      _defaultValue = '';
    } else if (defaultValue == null && _type == int) {
      _defaultValue = 0;
    } else if (defaultValue == null && _type == double) {
      _defaultValue = 0.0;
    } else if (defaultValue == null && _type == DateTime) {
      _defaultValue = DateTime.fromMicrosecondsSinceEpoch(0);
    } else if (defaultValue == null && _type == bool) {
      _defaultValue = false;
    } else {
      _defaultValue = defaultValue;
    }
  }

  /// The name of the property.
  String get name => _name;

  /// The type of the property.
  Type get type => _type;

  /// A properties default value.
  ///
  /// Used if the property is called before being explicitly set.
  Object get defaultValue => _defaultValue;

  /// A unique id used by fmvvm to tie this propertyinfo to a backing field in a class instance.
  int get id => _id;
  _setIdentifier(int value) => _id = value;

  /// Used by fmvvm to create backing information for this property info.
  FieldData createFieldData() {
    return new FieldData(_name, id, _defaultValue);
  }
}
