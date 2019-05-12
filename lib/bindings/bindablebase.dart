part of fmvvm.bindings;

/// Class to be extended when creating any non widget object that can be bound to.
abstract class BindableBase {
  StreamController _elementChangedController = StreamController.broadcast();
  FieldManager _fieldManager = FieldManager();

  /// Gives a new value to a property.
  @protected
  void setValue(PropertyInfo propertyInfo, Object value) {
    if (_fieldManager.getValue(propertyInfo) != value) {
      _fieldManager.setValue(propertyInfo, value);

      elementChanged(propertyInfo.name);
    }
  }

  /// Returns the current value for a property.
  /// 
  /// If the property has not been set, the default value will be returned.
  @protected
  Object getValue(PropertyInfo propertyInfo) {
    return _fieldManager.getValue(propertyInfo);
  }

  /// Method to call if an element has been changed so any listeners can be notified.
  /// 
  /// Leave the [propertyName] blank to indicate the entire object has changed.
  @protected
  elementChanged(String propertyName) {
    _elementChangedController.add(propertyName);
  }
  
  /// Event raised when an element or the entire object has changed.
  Stream get onChanged => _elementChangedController.stream;
}