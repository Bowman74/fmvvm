part of fmvvm.bindings;

/// Class to expend for all StatefulWidgets that plan to use databinding and be bound to a viewmodel.
abstract class FmvvmStatefulWidget<V extends fmvvm_interfaces.ViewModel> extends StatefulWidget
    implements fmvvm_interfaces.ViewModelHolder<V> {
  /// Creates the StatefulWidget.
  /// 
  /// [_viewmodel] - A reference to the view model to be used.
  @mustCallSuper
  FmvvmStatefulWidget(this._viewModel, {Key key}) : super(key: key);

  final V _viewModel;

  /// The class's viewmodel reference.
  V get viewModel => _viewModel;
}
