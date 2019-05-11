part of fmvvm.bindings;

abstract class FmvvmStatefulWidget<V extends fmvvm_interfaces.ViewModel> extends StatefulWidget
    implements fmvvm_interfaces.ViewModelHolder<V> {
  FmvvmStatefulWidget(this._viewModel, {Key key}) : super(key: key);

  final V _viewModel;

  V get viewModel => _viewModel;
}
