part of fmvvm_bindings;

abstract class BindingManager {
  final List<Binding> _sourceBindings = List<Binding>();
  final List<StreamSubscription> _subscriptions = List<StreamSubscription>();

  Binding createBinding(BindableBase source, PropertyInfo property,
      {ValueConverter valueConverter}) {
    var binding = Binding(source, property,
        valueConverter: valueConverter);

    _sourceBindings.add(binding);

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
}