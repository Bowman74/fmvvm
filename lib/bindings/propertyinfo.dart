part of fmvvm_bindings;

class PropertyInfo {
  String _name;
  Object _defaultValue;
  Type _type;

  PropertyInfo(String name, Type type, [Object defaultValue]) {
    _name = name;
    _type = type;
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

  final String id = Uuid().v4();

  FieldData createFieldData() {
    return new FieldData(_name, id, _defaultValue);
  }
}