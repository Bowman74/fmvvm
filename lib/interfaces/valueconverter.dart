part of fmvvm_interfaces;

abstract class ValueConverter { 
  Object convert(Object source, Object value);

  Object convertBack(Object source, Object value);
}