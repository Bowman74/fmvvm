part of fmvvm;

class FmvvmContainer implements ComponentResolver {
  FmvvmContainer() {
    if (_dependencyRegistrations == null) {
      _dependencyRegistrations = List<_DependencyRegistration>();
    }
  }

  static List<_DependencyRegistration> _dependencyRegistrations;

  @override
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
        RegistrationType.instanceRegistration) {
      return registration.registeredInstance;
    } else {
      return registration.factoryMethod();
    }
  }

  @override
  T resolveType<T>() {
    return resolve(Utilities.typeOf<T>());
  }

  @override
  void registerInstance<T>(T instance) {
    if (_dependencyRegistrations
        .any((r) => identical(r.typeRegistered, Utilities.typeOf<T>()))) {
      throw StateError("The same type cannot be registered twice");
    }
    _dependencyRegistrations.add(_DependencyRegistration(
        RegistrationType.instanceRegistration, T,
        registeredInstance: instance));
  }

  @override
  void registerType<T>([Function factoryMethod]) {
    if (_dependencyRegistrations
        .any((r) => identical(r.typeRegistered, Utilities.typeOf<T>()))) {
      throw StateError("The same type cannot be registered twice");
    }
    _dependencyRegistrations.add(_DependencyRegistration(
        RegistrationType.typeRegistration, Utilities.typeOf<T>(),
        factoryMethod: factoryMethod));
  }

  @override
  void completeRegistration() {
    // does nothing in the default lightweight Fmvvm IoC implementation
  }

  void resetRegistrations() {
    _dependencyRegistrations = List<_DependencyRegistration>();
  }
}

class _DependencyRegistration {
  _DependencyRegistration(
      RegistrationType registrationType, Type typeRegistered,
      {Object registeredInstance, Function factoryMethod}) {
    if (registrationType == null) {
      throw ArgumentError("registrationType");
    }
    if (registrationType == RegistrationType.instanceRegistration &&
        registeredInstance == null) {
      throw StateError(
          "The registered instance cannot be null when the registration type is an instance registration.");
    }
    if (registrationType == RegistrationType.typeRegistration &&
        factoryMethod == null) {
      throw StateError(
          "The factory method cannot be null when the registration type is a type registration.");
    }
    _registrationType = registrationType;
    _typeRegistered = typeRegistered;
    _registeredInstance = registeredInstance;
    _factoryMethod = factoryMethod;
  }

  RegistrationType _registrationType;
  Type _typeRegistered;
  Object _registeredInstance;
  Function _factoryMethod;

  RegistrationType get registrationType => _registrationType;

  Type get typeRegistered => _typeRegistered;

  Object get registeredInstance => _registeredInstance;

  Function get factoryMethod => _factoryMethod;
}

enum RegistrationType { typeRegistration, instanceRegistration }
