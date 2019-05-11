part of fmvvm_bindings;

abstract class FmvvmStatefulWidget<V extends ViewModel> extends StatefulWidget
    implements ViewModelHolder<V> {
  FmvvmStatefulWidget(this._viewModel, {Key key}) : super(key: key);

  final V _viewModel;

  V get viewModel => _viewModel;
}
