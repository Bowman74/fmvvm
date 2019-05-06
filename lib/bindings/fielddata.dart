part of fmvvm_bindings;

class FieldData<T> {
  String _name;
  String _id;
  T value;

  FieldData(String name, String id, Object startingValue) {
    _name = name;
    _id = id;
    value = startingValue;
  }

  String get name => _name;
  String get id => _id;
}