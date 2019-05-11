part of fmvvm.interfaces;

abstract class BindableBase implements NotifyChanges { 
void setValue(PropertyInfo propertyInfo, Object value);

  Object getValue(PropertyInfo propertyInfo);

  elementChanged(String propertyName);
  
  Stream get onChanged;
}