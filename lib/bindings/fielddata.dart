part of 'bindings.dart';

/// Contains the data backing a PropertyInfo for an instance of a class.
class FieldData<T> {
  final String _name;
  final int _id;

  FieldData(String name, int id, T? startingValue)
      : _name = name,
        _id = id,
        value = startingValue {}

  /// The name of the property.
  String get name => _name;

  /// An id for this FieldData within an instance of a class.
  ///
  /// This field is normally used by the fmvvm framework.
  int get id => _id;

  /// The current value of the property.
  T? value;
}
