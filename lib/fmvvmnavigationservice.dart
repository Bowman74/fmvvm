part of fmvvm;

class FmvvmNavigationService implements NavigationService {

  BuildContext _currentContext;

  Future<void> navigate<T extends ViewModel>({Object parameter}) async {

    var _viewModel = createViewModel<T>(parameter);

    var routeName = Core.viewLocator.getViewFromViewModelType<T>();

    await Navigator.pushNamed(_currentContext, routeName, arguments: _viewModel);

    _viewModel.appeared();
  }

  ViewModel createViewModel<T extends ViewModel>(Object parameter) {
    ViewModel _viewModel =  Core.componentResolver.resolveType<T>();
    _viewModel.init(parameter);
    return _viewModel;
  }

  void navigateBack() {
    Navigator.pop(_currentContext);
  }

  set currentContext(BuildContext context) {
    _currentContext = context;
  }

}