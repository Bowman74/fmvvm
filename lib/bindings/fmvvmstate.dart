part of fmvvm.bindings;

/// State object to be used with binding for StatefulWidgets.
/// 
/// This class must be exended whenever data binding is desired for a StatelfulWidget.
/// Intended to be used in conjenction with the FmvvmStatefulWidget class.
abstract class FmvvmState<T extends StatefulWidget, V extends fmvvm_interfaces.ViewModel> extends State<T>
    implements fmvvm_interfaces.ViewModelHolder<V> {

  /// Creates the FmvvmState object.
  /// 
  /// [_viewModel] is the view model to be used.
  /// [_isNavigable] should be true if this widget will be treated like a page instead of part
  /// of a page.
  @mustCallSuper
  FmvvmState(this._viewModel, this._isNavigable);

  final List<Binding> _sourceBindings = List<Binding>();
  final List<StreamSubscription> _subscriptions = List<StreamSubscription>();


  V _viewModel;

  /// The class's viewmodel reference.
  V get viewModel => _viewModel;

  final bool _isNavigable;

  /// Creates a new binding for the state.
  ///
  /// Should only be called once for each binding that is required and not within the build method.
  /// [source] - The BindableBase object to bind to.
  /// [property] - The PropertyInfo object in the BindableBase object to bind to.
  /// [bindingDirection] - If set to two way, the widget will get redrawn if a value on
  /// the BindableBase's property changes.
  /// [valueConverter] - An optional ValueConverter to be used when setting or retrieving
  /// the value for this binding.
  @protected
  Binding createBinding(BindableBase source, PropertyInfo property,
      {fmvvm_interfaces.BindingDirection bindingDirection, fmvvm_interfaces.ValueConverter valueConverter}) {
    var binding = Binding(source, property,
        bindingDirection: bindingDirection, valueConverter: valueConverter);

    _addBindingAndCreateListener(_sourceBindings, binding);

    return binding;
  }

  @protected
  void _addBindingAndCreateListener(List<Binding> bindings, Binding binding) {
    if (!bindings.any((b) => b.source == binding.source)) {
      var subscription = binding.source.onChanged.listen((fieldName) {
        if (binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay &&
            (fieldName == "" ||
                bindings.any((b) =>
                    b.sourceProperty.name == fieldName &&
                    b.source == binding.source))) {
          setState(() {});
        }
      });
      _subscriptions.add(subscription);
    }
    bindings.add(binding);
  }

  /// Returns the value for a binding.
  /// 
  /// [binding] - The binding to get the value of.
  /// 
  /// If a ValueConverter was specified for this binding, it will be used.
  /// If the binding direction is OneTime, calls to this method always return
  /// the same value.
  @protected
  Object getValue(Binding binding) {
    Object returnValue;
    if (binding.bindingDirection == fmvvm_interfaces.BindingDirection.OneTime &&
        !binding.originalValue is _OriginalValueNeverSet) {
      returnValue = binding.originalValue;
    } else if (binding.valueConverter == null) {
      returnValue =
          binding.source.getValue(binding.sourceProperty);
    } else {
      returnValue = binding.valueConverter.convert(binding.source,
          binding.source.getValue(binding.sourceProperty));
    }

    if (binding.originalValue is _OriginalValueNeverSet) {
      binding.originalValue = returnValue;
    }
    return returnValue;
  }

  /// Sets the value for a binding.
  /// 
  /// [binding] - The binding to set the value for.
  /// [value] - The new value for the property in the BinsableBase object that is bound to.
  /// 
  /// If a ValueConverter was specified for this binding, it will be used.
  @protected
  void setValue(Binding binding, Object value) {
    setState(() {
      if (binding.valueConverter == null) {
        binding.source.setValue(binding.sourceProperty, value);
      } else {
        binding.source.setValue(binding.sourceProperty,
            binding.valueConverter.convertBack(binding.source, value));
      }
    });
  }

  /// Returns a function that can be used with a TextEditingController's addListener method.
  /// 
  /// Passes any changes made by the user back to the view model
  @protected
  Function getTargetValuedTextChanged(
      Binding binding, TextEditingController controller) {
    assert(binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay);
    return () => {setValue(binding, controller.value.text)};
  }

  /// Returns a funcation that can be used with the OnChanged event on many StatefulWidgets.
  /// 
  /// Passes any changes made by the user back to the view model
  @protected
  Function getOnChanged(Binding binding) {
    assert(binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay);
    return (Object newValue) => {setValue(binding, newValue)};
  }

  /// Builds the presentaiton for the widget.
  /// 
  /// If this StatefulWidget isNavigatable, the NavigationService's context is set to this context.
  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    if (_isNavigable) {
      Core.componentResolver.resolveType<fmvvm_interfaces.NavigationService>().currentContext = context;
    }
    return null;
  }

  /// Called when the state is disposed.
  /// 
  /// All subscriptions for bindings are cancelled.
  @override
  @mustCallSuper
  void dispose() {
    _subscriptions?.forEach((StreamSubscription s) => {s.cancel()});
    super.dispose();
  }
}
