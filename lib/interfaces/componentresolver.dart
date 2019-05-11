part of fmvvm.interfaces;

/// Interface for dependency injection within fmvvm.
/// 
/// A default implementation is provided called FmvvmContainer, however any dependency
/// injection framework can be used with fmvvm by encasing it in a class that
/// implements this interface and is passed to the core.initilization method in a Registration
/// class instance.
abstract class ComponentResolver {
  /// Resolve a type registered with the contianer specified by [targetType].
  Object resolve(Type targetType);

  /// Resolve a type registered with the contianer specified by a generic type.
  T resolveType<T>();

  /// Registers an [instance] of an object of the generic type.
  /// 
  /// All calls to resolve based on this type will always return the registered instance.
  /// This in effect creates a singleton.
  void registerInstance<T>(T instance);

  /// Registers a type that can be resolved.
  /// 
  /// The [typeCreationFunction] is a reference to a function that should create an
  /// instance of this type.
  void registerType<T>([Function typeCreationFunction]);

  /// This method should be called when using dependency injection frameworks that require a 
  /// completion function to be called after all registrations are complete.
  void completeRegistration();

  /// Removes all registrations from the dependency injection container.
  void resetRegistrations();
}