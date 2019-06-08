part of fmvvm;

/// When fmvvm is instatiated, this class is used to create fmmvm service objects.
///
/// This class can be extended and any of the methods overridden to provide alternate
/// implementations. Any class created in such a way should then be passed to the Core.initialize
/// method.
class Registrations {
  /// Returns a reference to the ComponentResolver to be used by fmvvm.
  ComponentResolver getResolver() {
    return ComponentResolver();
  }

  /// Returns a reference to the NavigationService to be used by fmvvm.
  NavigationService getNavigationService() {
    return FmvvmNavigationService();
  }

  /// Returns a reference to the ViewLocator to be used by fmvvm.
  ViewLocator getViewLocator() {
    return FmvvmViewLocator();
  }

  /// Returns a reference to the MessageService to be used by fmvvm.
  MessageService getMessageService() {
    return FmvvmMessageService();
  }
}
