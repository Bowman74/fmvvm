part of fmvvm;

class FmvvmNavigationService extends NavigationService {

  BuildContext _currentContext;
  @override
  Future<void> navigate<T extends ViewModel>({Object parameter}) async {

    var _viewModel = _createViewModel<T>(parameter);

    var routeName = Core.viewLocator.getViewFromViewModelType<T>();

    await Navigator.pushNamed(_currentContext, routeName, arguments: _viewModel);

    _viewModel.appeared();
  }

  ViewModel _createViewModel<T extends ViewModel>(Object parameter) {
    ViewModel _viewModel =  Core.componentResolver.resolveType<T>();
    _viewModel.init(parameter);
    return _viewModel;
  }

  @override
  void navigateBack() {
    Navigator.pop(_currentContext);
  }

  @override
  set currentContext(BuildContext context) {
    _currentContext = context;
  }
}