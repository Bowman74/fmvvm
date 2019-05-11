part of fmvvm;

class Core {
  static ComponentResolver _componentResolver;
  static NavigationService _navigationService;
  static ViewLocator _viewLocator;

  static void initialize({Registrations registrations}) {
    var startRegistrations = registrations ?? Registrations();

    _navigationService = startRegistrations.getNavigationService();
    _viewLocator = startRegistrations.getViewLocator();
    _componentResolver = startRegistrations.getResolver();

      _componentResolver.registerInstance<ViewLocator>(Core.viewLocator);
      _componentResolver.registerInstance<NavigationService>(Core.navigationService);
  }

  static Future start<T extends ViewModelBase>({Object parameter, BuildContext context}) async {
    await _navigationService.navigate<T>();
  }

  static ComponentResolver get componentResolver => _componentResolver;
  static NavigationService get navigationService => _navigationService;
  static ViewLocator get viewLocator => _viewLocator;
}