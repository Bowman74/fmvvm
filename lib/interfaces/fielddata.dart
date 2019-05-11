part of fmvvm.interfaces;

/// An interface for the data backing a PropertyInfo for an instance of a class.
abstract class FieldData<T> { 
  /// The name of the property.
  String get name;

  /// An id for this FieldData within an instance of a class.
  /// 
  /// This field is normally used by the fmvvm framework.
  int get id;

  /// The current value of the property.
  T value;
}