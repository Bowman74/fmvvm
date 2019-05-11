part of fmvvm.bindings;

/// Class to expend for all StatelessWidgets that plan to use data in a viewmodel for display.
/// 
/// Databinding is not allowed in a StatelessWidget per se as there is no ability to update
/// in either direction. Instead the values in the ViewModel can be retrived and used 
/// in construction of the widget.
abstract class FmvvmStatelessWidget<V extends fmvvm_interfaces.ViewModel>
    extends StatelessWidget implements fmvvm_interfaces.ViewModelHolder<V> {
  
  /// Creates the FmvvmStatelessWidget object.
  /// 
  /// [_viewModel] is the view model to be used.
  /// [_isNavigable] should be true if this widget will be treated like a page instead of part
  /// of a page.
  @mustCallSuper
  FmvvmStatelessWidget(this._viewModel, this._isNavigable, {Key key}) : super(key: key);

  final V _viewModel;
  final bool _isNavigable;

  /// The class's viewmodel reference.
  V get viewModel => _viewModel;

  /// Builds the presentaiton for the widget.
  /// 
  /// If this StatelessWidget isNavigatable, the NavigationService's context is set to this context.
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (_isNavigable) {
      Core.componentResolver.resolveType<fmvvm_interfaces.NavigationService>().currentContext = context;
    }
    return null;
  }

  /// Returns a value from a BindableBase instance.
  /// 
  /// [source] - An instance of the BindableBase object to get a value from.
  /// [value] - The value from the BinbalbeBase object.
  /// [valueConverter] - A ValueConverter instance to convert the value from the [value] 
  /// parameter to one expected by the widget.
  @protected
  Object getValueWithConversion(BindableBase source, Object value,
      fmvvm_interfaces.ValueConverter valueConverter) {
    return valueConverter.convert(source, value);
  }
}