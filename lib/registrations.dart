part of fmvvm;

class Registrations {
  ComponentResolver getResolver() {
    return FmvvmContainer();
  }

  NavigationService getNavigationService() {
    return FmvvmNavigationService();
  }

  ViewLocator getViewLocator() {
    return FmvvmViewLocator();
  }
}