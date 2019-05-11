part of fmvvm.bindings;

class PropertyInfo implements fmvvm_interfaces.PropertyInfo {
  String _name;
  Object _defaultValue;
  Type _type;
  int _id = -1;

  PropertyInfo(this._name, this._type, [Object defaultValue]) {
    if (defaultValue == null && _type == String) {
      _defaultValue = '';
    } else if (defaultValue == null && _type == int) {
      _defaultValue = 0;
    } else if (defaultValue == null && _type == double) {
      _defaultValue = 0.0;
    } else if (defaultValue == null && _type == DateTime) {
      _defaultValue = DateTime.fromMicrosecondsSinceEpoch(0);
    } else {
      _defaultValue = defaultValue;
    }
  }

  String get name =>  _name;

  Type get type => _type;

  Object get defaultValue => _defaultValue;

  int get id => _id;
  _setIdentifier(int value) => _id = value;

  fmvvm_interfaces.FieldData createFieldData() {
    return new FieldData(_name, id, _defaultValue);
  }
}