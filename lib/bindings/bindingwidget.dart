part of fmvvm.bindings;

/// This widget is for setting up bindings.
///
/// It can be be used in Widgets setup by in a fmvvmStatelessWidget or
/// FmvvmStatefulWidget or in a custom widget that stands on its own.
/// All it requires is that the bindings are setup against BinableBase
/// objects'
class BindingWidget<T extends BindableBase> extends StatefulWidget {
  BindingWidget({@required this.bindings, @required this.builder});

  final Widget Function(BuildContext context) builder;
  final List<Binding> bindings;

  /// Returns a reference to a BindingWidget based on type.
  ///
  /// This looks up the context for an ancestor that is a BindingWidget of the
  /// supplied type. If none are found, an [ArgumentError] is raised.
  static BindingWidget<T> of<T extends BindableBase>(BuildContext context) {
    final type = Utilities.typeOf<BindingWidget<T>>();
    final bindingWidget =
        context.ancestorWidgetOfExactType(type) as BindingWidget<T>;

    if (bindingWidget == null) {
      throw ArgumentError('No BindingWidgets found for the specified type.');
    }
    return bindingWidget;
  }

  /// Returns the value for a binding.
  ///
  /// This uses the [key] that was set up with the binding. Additionally
  /// a [converterParameter] can be passed that will be send to a value
  /// converter if supplied with the binding.
  Object getValue(String key, {Object converterParameter}) {
    Object returnValue;
    Binding binding = _getBinding(key);
    if (binding.bindingDirection == BindingDirection.OneTime &&
        !binding.originalValue is _OriginalValueNeverSet) {
      returnValue = binding.originalValue;
    } else if (binding.valueConverter == null) {
      returnValue = binding.source.getValue(binding.sourceProperty);
    } else {
      returnValue = binding.valueConverter.convert(
          binding.source, binding.source.getValue(binding.sourceProperty),
          parameter: converterParameter);
    }

    if (binding.originalValue is _OriginalValueNeverSet &&
        binding.bindingDirection == BindingDirection.OneTime) {
      binding.originalValue = returnValue;
    }
    return returnValue;
  }

  /// Sets a value back into the BindableBase object.
  ///
  /// This uses the [key] that was set up with the binding. Additionally
  /// a [converterParameter] can be passed that will be send to a value
  /// converter if supplied with the binding. The [value] is the new value to
  /// set into the property specified by the binding.
  void setValue(String key, Object value, {Object converterParameter}) {
    Binding binding = _getBinding(key);
    if (binding.valueConverter == null) {
      binding.source.setValue(binding.sourceProperty, value);
    } else {
      binding.source.setValue(
          binding.sourceProperty,
          binding.valueConverter.convertBack(binding.source, value,
              parameter: converterParameter));
    }
  }

  /// Returns a funcation that can be used with the OnChanged event on many StatefulWidgets.
  ///
  /// Passes any changes made by the user back to the view model
  Function getOnChanged(String key, {Object converterParameter}) {
    Binding binding = _getBinding(key);
    assert(binding.bindingDirection == BindingDirection.TwoWay);
    return (Object newValue) =>
        {setValue(key, newValue, converterParameter: converterParameter)};
  }

  Binding _getBinding(String key) {
    return bindings.singleWhere((b) => b.key == key);
  }

  @override
  _BindingWidgetState<T> createState() => _BindingWidgetState<T>(bindings);
}

/// A state object for use internally by fmvvm for BindingWidgets.
class _BindingWidgetState<T> extends State<BindingWidget> {
  final List<Binding> _sourceBindings;
  final List<_BindingListener> _bindingListeners = List<_BindingListener>();

  _BindingWidgetState(this._sourceBindings) {
    var addedListeners = List<BindableBase>();

    _sourceBindings.forEach((b) {
      _createListener(b, addedListeners);
    });
  }

  /// Creates a property listenter for a binding.
  ///
  /// If the binding is to a notification list, a listener is added to that as well.
  void _createListener(Binding binding, List<BindableBase> addedListeners) {
    if (!addedListeners.any((b) => b == binding.source)) {
      var propertyListener = (String fieldName) {
        if (binding.bindingDirection == BindingDirection.TwoWay &&
            (fieldName == "" ||
                _sourceBindings.any((b) =>
                    b.sourceProperty.name == fieldName &&
                    b.source == binding.source))) {
          setState(() {});
        }
      };

      binding.source.addPropertyListener(propertyListener);
      _bindingListeners.add(_BindingListener()
        ..bindingKey = binding.key
        ..listener = propertyListener
        ..isListListener = false);

      if (binding.source.getValue(binding.sourceProperty) is NotificationList) {
        var notificationList =
            binding.source.getValue(binding.sourceProperty) as NotificationList;
        var listListener = () {
          setState(() {});
        };
        notificationList.addListener(listListener);
        _bindingListeners.add(_BindingListener()
          ..bindingKey = binding.key
          ..listener = listListener
          ..isListListener = true);
      }
    }
    addedListeners.add(binding.source);
  }

  @override
  @mustCallSuper
  Widget build(BuildContext context) {
    return _BindingContext(widget.builder);
  }

  /// Called when the state is disposed.
  ///
  /// All subscriptions for bindings are cancelled.
  @override
  @mustCallSuper
  void dispose() {
    _bindingListeners.forEach((bl) {
      var binding =
          _sourceBindings.singleWhere((sb) => sb.key == bl.bindingKey);
      if (bl.isListListener) {
        var notificationList =
            binding.source.getValue(binding.sourceProperty) as NotificationList;
        notificationList.removeListener(bl.listener);
      } else {
        binding.source.removePropertyListener(bl.listener);
      }
    });
    super.dispose();
  }
}

/// A context object for use internally by fmvvm for BindingWidgets.
class _BindingContext extends StatelessWidget {
  _BindingContext(this.builder);

  final Widget Function(BuildContext context) builder;

  @override
  Widget build(BuildContext context) {
    return builder(context);
  }
}

/// A class used to track listeners so they can be removed as part of the dispose method.
class _BindingListener {
  bool isListListener;
  Object listener;
  String bindingKey;
}
