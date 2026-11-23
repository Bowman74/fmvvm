part of 'bindings.dart';

/// State object to be used with binding for StatefulWidgets.
///
/// This class must be extended whenever data binding is desired for a StatefulWidget.
/// Intended to be used in conjunction with the FmvvmStatefulWidget class.
abstract class FmvvmState<T extends FmvvmStatefulWidget<V>,
    V extends BindableBase> extends State<T> implements BindableBaseHolder<V> {
  /// Creates the FmvvmState object.
  ///
  /// [_viewModel] is the view model to be used.
  /// [_isNavigable] should be true if this widget will be treated like a page instead of part
  /// of a page.
  FmvvmState(this._isNavigable);

  late V _bindableBase;

  @override
  void initState() {
    super.initState();

    _bindableBase = widget.bindableBase;

    if (_bindableBase is! ViewModel && _isNavigable) {
      throw ArgumentError("Navigable state objects must be of type ViewModel");
    }
  }

  /// The class's viewmodel reference.
  @override
  V get bindableBase => _bindableBase;

  final bool _isNavigable;

  /// Builds the presentation for the widget.
  ///
  /// If this StatefulWidget isNavigable, the NavigationService's context is set to this context.
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (_isNavigable) {
      Core.componentResolver
          .resolveType<MessageService>()!
          .publish(Message(Constants.newBuildContext, context));
    }
    return Container();
  }
}
