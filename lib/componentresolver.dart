part of fmvvm;

/// The default fmvvm dependency injection/IoC implementation.
class ComponentResolver {
  ComponentResolver() {
    if (_dependencyRegistrations == null) {
      _dependencyRegistrations = List<_DependencyRegistration>();
    }
  }

  static List<_DependencyRegistration> _dependencyRegistrations;

  /// Resolve a type registered with the contianer specified by [targetType].
  Object resolve(Type targetType) {
    if (!_dependencyRegistrations
        .any((r) => identical(r.typeRegistered, targetType))) {
      throw StateError('The type ' +
          targetType.toString() +
          ' is not registered with the IoC container.');
    }

    var registration = _dependencyRegistrations
        .singleWhere((r) => identical(r.typeRegistered, targetType));

    if (registration.registrationType ==
        _RegistrationType.instanceRegistration) {
      return registration.registeredInstance;
    } else {
      return registration.factoryMethod();
    }
  }

  /// Resolve a type registered with the contianer specified by a generic type.
  T resolveType<T>() {
    return resolve(Utilities.typeOf<T>());
  }

  /// Registers an [instance] of an object of the generic type.
  /// 
  /// All calls to resolve based on this type will always return the registered instance.
  /// This in effect creates a singleton.
  void registerInstance<T>(T instance) {
    if (_dependencyRegistrations
        .any((r) => identical(r.typeRegistered, Utilities.typeOf<T>()))) {
      throw StateError("The same type cannot be registered twice");
    }
    _dependencyRegistrations.add(_DependencyRegistration(
        _RegistrationType.instanceRegistration, T,
        registeredInstance: instance));
  }

  /// Registers a type that can be resolved.
  /// 
  /// The [typeCreationFunction] is a reference to a function that should create an
  /// instance of this type.
  void registerType<T>([Function factoryMethod]) {
    ArgumentError.checkNotNull(factoryMethod, "factoryMethod");
    
    if (_dependencyRegistrations
        .any((r) => identical(r.typeRegistered, Utilities.typeOf<T>()))) {
      throw StateError("The same type cannot be registered twice");
    }
    _dependencyRegistrations.add(_DependencyRegistration(
        _RegistrationType.typeRegistration, Utilities.typeOf<T>(),
        factoryMethod: factoryMethod));
  }

  /// This method should be called when using dependency injection frameworks that require a 
  /// completion function to be called after all registrations are complete.
  void completeRegistration() {

  }

  /// Removes all registrations from the dependency injection container.
  void resetRegistrations() {
    _dependencyRegistrations = List<_DependencyRegistration>();
  }
}
/// A object that contains information about resolving an dependency.
class _DependencyRegistration {
  _DependencyRegistration(
      _RegistrationType registrationType, Type typeRegistered,
      {Object registeredInstance, Function factoryMethod}) {
    if (registrationType == null) {
      throw ArgumentError("registrationType");
    }
    if (registrationType == _RegistrationType.instanceRegistration &&
        registeredInstance == null) {
      throw StateError(
          "The registered instance cannot be null when the registration type is an instance registration.");
    }
    if (registrationType == _RegistrationType.typeRegistration &&
        factoryMethod == null) {
      throw StateError(
          "The factory method cannot be null when the registration type is a type registration.");
    }
    _registrationType = registrationType;
    _typeRegistered = typeRegistered;
    _registeredInstance = registeredInstance;
    _factoryMethod = factoryMethod;
  }

  _RegistrationType _registrationType;
  Type _typeRegistered;
  Object _registeredInstance;
  Function _factoryMethod;

  /// The type of registration, always get the same instance or new instance per type.
  _RegistrationType get registrationType => _registrationType;

  /// The type of object to create.
  Type get typeRegistered => _typeRegistered;

  /// A reference to the object for instance registration.
  Object get registeredInstance => _registeredInstance;

  /// A function to create an instance of an object for type registrations.
  Function get factoryMethod => _factoryMethod;
}

/// Donites if a _DependencyRegistration is an instance or type registration.
enum _RegistrationType { typeRegistration, instanceRegistration }
