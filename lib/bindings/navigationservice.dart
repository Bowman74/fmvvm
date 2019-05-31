part of fmvvm.bindings;

/// Interface for a navigation service for use by view models.
///
/// Since a view model should no nothing about the presentation layer, no context is used here.
/// An implementation of this class is the basis for viewmodel to viewmodel navigation.
abstract class NavigationService {
  /// Navigates to a new viewmodel of the type specified by the generic.
  ///
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method. The Future will be resolved with the ViewModel that is navigated to is
  /// popped from the stack.
  Future navigate<V extends ViewModel>({Object parameter});

  /// Navigates to a new viewmodel of the type specified by the generic.
  ///
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method. It is expexted that the ViewModel being navigated to will
  /// return an instance of type R when it is popped off the stack.
  Future<R> navigateForResult<R extends Object, V extends ViewModel>(
      {Object parameter});

  /// Pops the current view / viewmodel off the stack and goes to the previous one.
  void navigateBack();

  /// Pops the current view / viewmodel off the stack and goes to the previous one.
  ///
  /// The [paramter] is the result to send back to the calling view model.
  /// This should be used in conjunction with navigateForResult.
  void navigateBackWithResult<R extends Object>([R parameter]);

  /// Creates a view model of a specified type.
  ///
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  /// This method is usefule for creating a view model to pass to an apps
  /// starting widget.
  ViewModel createViewModel<T extends ViewModel>(Object parameter);

  /// The current context. This method is called by default when a widget defined as a page
  /// has been shown.
  set viewContext(BuildContext context);
}
