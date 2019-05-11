part of fmvvm.interfaces;

/// Interface for non-widget objects that can be bound to.
/// 
/// This interface is usually used for viewmodels and models.
abstract class BindableBase implements NotifyChanges { 

  /// Gives a new value to a property.
  void setValue(PropertyInfo propertyInfo, Object value);

  /// Returns the current value for a property.
  /// 
  /// If the property has not been set, the default value will be returned.
  Object getValue(PropertyInfo propertyInfo);

  /// Method to call if an element has been changed so any listeners can be notified.
  /// 
  /// Leave the [propertyName] blank to indicate the entire object has changed.
  elementChanged(String propertyName);
  
  /// Event raised when an element or the entire object has changed.
  Stream get onChanged;
}