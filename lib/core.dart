part of fmvvm;

/// Bootstraping class for the fmvvm framework.
class Core {
  static ComponentResolver _componentResolver;
  static NavigationService _navigationService;
  static ViewLocator _viewLocator;
  static MessageService _messageService;

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
    _messageService = startRegistrations.getMessageService();

    _componentResolver.registerInstance<ViewLocator>(_viewLocator);
    _componentResolver.registerInstance<NavigationService>(_navigationService);
    _componentResolver.registerInstance<MessageService>(_messageService);

    _navigationService.initialize();
  }

  /// A global reference to the registered object for dependency injection/IoC.
  static ComponentResolver get componentResolver => _componentResolver;
}
