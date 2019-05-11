part of fmvvm_bindings;

abstract class FmvvmState<T extends StatefulWidget, V extends ViewModel> extends State<T>
    with BindingManager
    implements ViewModelHolder<V> {
  FmvvmState(this._viewModel);

  V _viewModel;

  V get viewModel => _viewModel;

  Binding createBindingEx(BindableBase source, PropertyInfo property,
      {BindingDirection bindingDirection, ValueConverter valueConverter}) {
    var binding = Binding(source, property,
        bindingDirection: bindingDirection, valueConverter: valueConverter);

    addBindingAndCreateListener(_sourceBindings, binding);

    return binding;
  }

  void addBindingAndCreateListener(List<Binding> bindings, Binding binding) {
    if (!bindings.any((b) => b.source == binding.source)) {
      var subscription = binding.source.onChanged.listen((fieldName) {
        if ((binding.bindingDirection == BindingDirection.OneWay ||
                binding.bindingDirection == BindingDirection.TwoWay) &&
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

  void setValue(Binding binding, Object value) {
    setState(() {
      if (binding.valueConverter == null) {
        binding.source._fieldManager.setValue(binding.sourceProperty, value);
      } else {
        binding.source._fieldManager.setValue(binding.sourceProperty,
            binding.valueConverter.convertBack(binding.source, value));
      }
    });
  }

  Function getTargetValuedTextChanged(
      Binding binding, TextEditingController controller) {
    assert(binding.bindingDirection == BindingDirection.TwoWay);
    return () => {setValue(binding, controller.value.text)};
  }

  Function getOnChanged(Binding binding) {
    assert(binding.bindingDirection == BindingDirection.TwoWay);
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
