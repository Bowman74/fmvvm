part of fmvvm;

/// Bootstraping class for the fmvvm framework.
class Core {
  static ComponentResolver _componentResolver;
  static NavigationService _navigationService;
  static ViewLocator _viewLocator;

  /// Called to initialize the fmvvm framework. 
  /// 
  /// This should be done before attempting to use any fmvvm components, 
  /// usually during the app startup.
  /// The [registrations] parameter allows overrides of the devault navigation,
  /// view location and component resolution (dependency injection/Ioc) implementations.
  static void initialize({Registrations registrations}) {
    var startRegistrations = registrations ?? Registrations();

    _navigationService = startRegistrations.getNavigationService();
    _viewLocator = startRegistrations.getViewLocator();
    _componentResolver = startRegistrations.getResolver();

      _componentResolver.registerInstance<ViewLocator>(Core.viewLocator);
      _componentResolver.registerInstance<NavigationService>(Core.navigationService);
  }

  /// A global reference to the registered object for dependency injection/IoC.
  static ComponentResolver get componentResolver => _componentResolver;
  /// A global reference to the navigation service used by the system.
  /// 
  /// This can unually also be returned by the componentResolver.
  static NavigationService get navigationService => _navigationService;
  /// A global reference to the view location service used by the system.
  /// 
  /// This can unually also be returned by the componentResolver.
  static ViewLocator get viewLocator => _viewLocator;
}