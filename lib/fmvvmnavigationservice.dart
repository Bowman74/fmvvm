part of fmvvm;

/// Default implementation of the fmvvm NavigationService interface.
class FmvvmNavigationService implements NavigationService {
  BuildContext _viewContext;
  Subscription _subscription;

  /// Navigates to a new viewmodel of the type specified by the generic.
  ///
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  Future navigate<V extends ViewModel>({Object parameter}) async {
    var _viewModel = createViewModel<V>(parameter);

    var routeName = Core._viewLocator.getViewFromViewModelType<V>();

    await Navigator.of(_viewContext)
        .pushNamed(routeName, arguments: _viewModel);
  }

  @override
  Future<R> navigateForResult<R extends Object, V extends ViewModel>(
      {Object parameter}) async {
    var _viewModel = createViewModel<V>(parameter);

    var routeName = Core._viewLocator.getViewFromViewModelType<V>();

    var returnValue = await Navigator.of(_viewContext)
        .pushNamed<R>(routeName, arguments: _viewModel);

    return returnValue;
  }

  @override
  void initialize() {
    var messageService = Core.componentResolver.resolveType<MessageService>();

    _subscription = Subscription(Constants.newBuildContext, (c) {
      _viewContext = c;
    });

    messageService.subscribe(_subscription);
  }

  /// Pops the current view / viewmodel off the stack and goes to the previous one.
  void navigateBack() {
    Navigator.of(_viewContext).pop();
  }

  void navigateBackWithResult<R extends Object>([R parameter]) {
    Navigator.of(_viewContext).pop(parameter);
  }

  /// Creates a view model of a specified type.
  ///
  /// The [parameter] is a value that will be passed to the new viewmodel's
  /// init method.
  /// This method is usefule for creating a view model to pass to an apps
  /// starting widget.
  ViewModel createViewModel<T extends ViewModel>(Object parameter) {
    ViewModel _viewModel = Core.componentResolver.resolveType<T>();
    _viewModel.init(parameter);
    return _viewModel;
  }
}
