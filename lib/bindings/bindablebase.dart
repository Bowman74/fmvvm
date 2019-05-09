part of fmvvm_bindings;

abstract class BindableBase implements NotifyChanges {
  StreamController _elementChangedController = StreamController.broadcast();
  FieldManager _fieldManager = FieldManager();

  void setValue(PropertyInfo propertyInfo, Object value) {
    if (_fieldManager.getValue(propertyInfo) != value) {
      _fieldManager.setValue(propertyInfo, value);

      elementChanged(propertyInfo.name);
    }
  }

  Object getValue(PropertyInfo propertyInfo) {
    return _fieldManager.getValue(propertyInfo);
  }

  elementChanged(String propertyName) {
    _elementChangedController.add(propertyName);
  }
  
  Stream get onChanged => _elementChangedController.stream;
}