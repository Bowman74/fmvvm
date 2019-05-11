part of fmvvm.interfaces;

abstract class ComponentResolver {
  
  Object resolve(Type targetType);

  T resolveType<T>();

  void registerInstance<T>(T instance);

  void registerType<T>([Function typeCreationFunction]);

  void completeRegistration();
}