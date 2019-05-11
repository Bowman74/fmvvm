part of fmvvm.bindings;

class FieldData<T> implements fmvvm_interfaces.FieldData {
  String _name;
  int _id;
  T value;

  FieldData(String name, int id, Object startingValue) {
    _name = name;
    _id = id;
    value = startingValue;
  }

  String get name => _name;
  int get id => _id;
}