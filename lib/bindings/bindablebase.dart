part of fmvvm_bindings;

abstract class BindableBase implements NotifyChanges {
  StreamController _elementChangedController = StreamController.broadcast();
  FieldManager _fieldManager = FieldManager();

  void setValue(PropertyInfo propertyInfo, Object value) {
    _fieldManager.setValue(propertyInfo, value);
  }

  Object getValue(PropertyInfo propertyInfo) {
    return _fieldManager.getValue(propertyInfo);
  }

    elementChanged(String propertyName) {
    _elementChangedController.add(propertyName);
  }
  
  Stream get onChanged => _elementChangedController.stream;
}