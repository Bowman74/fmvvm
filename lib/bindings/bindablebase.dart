part of fmvvm.bindings;

abstract class BindableBase implements fmvvm_interfaces.BindableBase {
  StreamController _elementChangedController = StreamController.broadcast();
  FieldManager _fieldManager = FieldManager();

  void setValue(fmvvm_interfaces.PropertyInfo propertyInfo, Object value) {
    if (_fieldManager.getValue(propertyInfo) != value) {
      _fieldManager.setValue(propertyInfo, value);

      elementChanged(propertyInfo.name);
    }
  }

  Object getValue(fmvvm_interfaces.PropertyInfo propertyInfo) {
    return _fieldManager.getValue(propertyInfo);
  }

  elementChanged(String propertyName) {
    _elementChangedController.add(propertyName);
  }
  
  Stream get onChanged => _elementChangedController.stream;
}