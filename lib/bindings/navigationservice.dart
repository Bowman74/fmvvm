part of fmvvm.bindings;

/// Interface for a navigation service for use by view models.
/// 
/// Since a view model should no nothing about the presentation layer, no context is used here.
/// An implementation of this class is the basis for viewmodel to viewmodel navigation.
abstract class NavigationService {
  /// Navigates to a new viewmodel of the type specified by the generic.
  /// 
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  Future<void> navigate<T extends ViewModel>({Object parameter});

  /// Pops the current view / viewmodel off the stack and goes to the previous one.
  void navigateBack();

  /// Creates a view model of a specified type.
  /// 
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  /// This method is usefule for creating a view model to pass to an apps
  /// starting widget.
  ViewModel createViewModel<T extends ViewModel>(Object parameter);

  /// The current context. This method is called by default when a widget defined as a page
  /// has been shown.
  set currentContext(BuildContext context);
}
