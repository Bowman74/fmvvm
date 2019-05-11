part of fmvvm.bindings;

abstract class FmvvmState<T extends StatefulWidget, V extends fmvvm_interfaces.ViewModel> extends State<T>
    implements fmvvm_interfaces.ViewModelHolder<V> {
  FmvvmState(this._viewModel);

  final List<Binding> _sourceBindings = List<Binding>();
  final List<StreamSubscription> _subscriptions = List<StreamSubscription>();

  V _viewModel;

  V get viewModel => _viewModel;

  Binding createBinding(BindableBase source, PropertyInfo property,
      {fmvvm_interfaces.BindingDirection bindingDirection, fmvvm_interfaces.ValueConverter valueConverter}) {
    var binding = Binding(source, property,
        bindingDirection: bindingDirection, valueConverter: valueConverter);

    addBindingAndCreateListener(_sourceBindings, binding);

    return binding;
  }

  void addBindingAndCreateListener(List<Binding> bindings, Binding binding) {
    if (!bindings.any((b) => b.source == binding.source)) {
      var subscription = binding.source.onChanged.listen((fieldName) {
        if ((binding.bindingDirection == fmvvm_interfaces.BindingDirection.OneWay ||
                binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay) &&
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

  Function getTargetValuedTextChanged(
      Binding binding, TextEditingController controller) {
    assert(binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay);
    return () => {setValue(binding, controller.value.text)};
  }

  Function getOnChanged(Binding binding) {
    assert(binding.bindingDirection == fmvvm_interfaces.BindingDirection.TwoWay);
    return (Object newValue) => {setValue(binding, newValue)};
  }

  void viewModelChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Core.navigationService.currentContext = context;
    return null;
  }

  @override
  void dispose() {
    _subscriptions?.forEach((StreamSubscription s) => {s.cancel()});
    super.dispose();
  }
}
