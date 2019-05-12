part of fmvvm.bindings;

  /// Interface for Geting information about a view or route based on a view model type.
  /// 
  /// This is typically used durning viewmodel to viewmodel navigation.
abstract class ViewLocator {
  /// returns a string view name or round name based on a viewmodel type.
  String getViewFromViewModelType<T extends ViewModel>();
}