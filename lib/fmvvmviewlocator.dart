part of fmvvm;

/// Default fmvvm implementation of the ViewLocator interface.
class FmvvmViewLocator implements ViewLocator {
  /// returns a string view name or round name based on a viewmodel type.
  String getViewFromViewModelType<T extends ViewModel>() {
    String typeName = Utilities.typeOf<T>().toString();

    return typeName.replaceAll('ViewModel', 'View');
  }
}
