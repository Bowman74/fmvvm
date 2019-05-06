part of fmvvm_interfaces;

abstract class ComponentResolver {
  
  Object resolve(Type targetType);

  T resolveType<T>();
}