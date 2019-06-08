part of fmvvm.bindings;

/// State object to be used with binding for StatefulWidgets.
///
/// This class must be exended whenever data binding is desired for a StatelfulWidget.
/// Intended to be used in conjenction with the FmvvmStatefulWidget class.
abstract class FmvvmState<T extends StatefulWidget, V extends BindableBase>
    extends State<T> implements BindableBaseHolder<V> {
  /// Creates the FmvvmState object.
  ///
  /// [_viewModel] is the view model to be used.
  /// [_isNavigable] should be true if this widget will be treated like a page instead of part
  /// of a page.
  @mustCallSuper
  FmvvmState(this._bindableBase, this._isNavigable) {
    if (_bindableBase is! ViewModel && _isNavigable) {
      throw ArgumentError("Navigable state objects must be of type ViewModel");
    }
  }

  V _bindableBase;

  /// The class's viewmodel reference.
  V get bindableBase => _bindableBase;

  final bool _isNavigable;

  /// Builds the presentaiton for the widget.
  ///
  /// If this StatefulWidget isNavigatable, the NavigationService's context is set to this context.
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (_isNavigable) {
      Core.componentResolver
          .resolveType<MessageService>()
          .publish(Message(Constants.newBuildContext, context));
    }
    return null;
  }
}
