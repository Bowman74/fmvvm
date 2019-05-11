part of fmvvm;

/// Default implementation of the fmvvm NavigationService interface.
class FmvvmNavigationService implements NavigationService {

  BuildContext _currentContext;

  /// Navigates to a new viewmodel of the type specified by the generic.
  /// 
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  Future<void> navigate<T extends ViewModel>({Object parameter}) async {

    var _viewModel = createViewModel<T>(parameter);

    var routeName = Core._viewLocator.getViewFromViewModelType<T>();

    await Navigator.pushNamed(_currentContext, routeName, arguments: _viewModel);
  }

  /// Pops the current view / viewmodel off the stack and goes to the previous one.
  void navigateBack() {
    Navigator.pop(_currentContext);
  }

  /// Creates a view model of a specified type.
  /// 
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  /// This method is usefule for creating a view model to pass to an apps
  /// starting widget.
  ViewModel createViewModel<T extends ViewModel>(Object parameter) {
    ViewModel _viewModel =  Core.componentResolver.resolveType<T>();
    _viewModel.init(parameter);
    return _viewModel;
  }

  /// The current context. This method is called by default when a widget defined as a page
  /// has been shown.
  set currentContext(BuildContext context) {
    _currentContext = context;
  }
}