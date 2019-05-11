part of fmvvm_bindings;

abstract class FmvvmStatelessWidget<V extends ViewModel> extends StatelessWidget
    with BindingManager
    implements ViewModelHolder<V> {
  FmvvmStatelessWidget(this._viewModel, {Key key}) : super(key: key);

  final V _viewModel;

  V get viewModel => _viewModel;

  @override
  Widget build(BuildContext context) {
    Core.navigationService.currentContext = context;
    return null;
  }
}
