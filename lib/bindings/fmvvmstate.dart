part of fmvvm_bindings;

abstract class FmvvmState<T extends StatefulWidget> extends State<T> {
  final List<Binding> _sourceBindings = List<Binding>();

  Binding createBinding(BindableBase source, PropertyInfo property,
      {BindingDirection bindingDirection, ValueConverter valueConverter}) {
    var binding = Binding(source, property,
        bindingDirection: bindingDirection, valueConverter: valueConverter);

    addBindingAndCreateListener(_sourceBindings, binding);

    return binding;
  }

  Object getValue(Binding binding) {
    Object returnValue;
    if (binding.bindingDirection == BindingDirection.OneTime &&
        !binding._originalValue is _OriginalValueNeverSet) {
      returnValue = binding._originalValue;
    } else if (binding.valueConverter == null) {
      returnValue =
          binding.source._fieldManager.getValue(binding.sourceProperty);
    } else {
      returnValue = binding.valueConverter.convert(binding.source,
          binding.source._fieldManager.getValue(binding.sourceProperty));
    }

    if (binding._originalValue is _OriginalValueNeverSet) {
      binding._originalValue = returnValue;
    }
    return returnValue;
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

  void addBindingAndCreateListener(List<Binding> bindings, Binding binding) {
    if (!bindings.any((b) => b.source == binding.source)) {
      binding.source.onChanged.listen((fieldName) {
        if ((binding.bindingDirection == BindingDirection.OneWay ||
                binding.bindingDirection == BindingDirection.TwoWay) &&
            (fieldName == "" ||
                bindings.any((b) =>
                    b.sourceProperty.name == fieldName &&
                    b.source == binding.source))) {
          setState(() {});
        }
      });
    }

    bindings.add(binding);
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
}
