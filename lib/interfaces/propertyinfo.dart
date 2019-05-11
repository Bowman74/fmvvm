part of fmvvm.interfaces;

abstract class PropertyInfo { 
  String get name;

  Type get type;

  Object get defaultValue;

  int get id;

  FieldData createFieldData();
}