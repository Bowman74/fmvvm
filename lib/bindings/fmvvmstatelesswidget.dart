part of fmvvm.bindings;

abstract class FmvvmStatelessWidget<V extends fmvvm_interfaces.ViewModel>
    extends StatelessWidget implements fmvvm_interfaces.ViewModelHolder<V> {
  FmvvmStatelessWidget(this._viewModel, {Key key}) : super(key: key);

  final V _viewModel;

  V get viewModel => _viewModel;

  @override
  Widget build(BuildContext context) {
    Core.navigationService.currentContext = context;
    return null;
  }

  Object getValueWithConversion(BindableBase source, Object value,
      fmvvm_interfaces.ValueConverter valueConverter) {
    return valueConverter.convert(source, value);
  }
}
