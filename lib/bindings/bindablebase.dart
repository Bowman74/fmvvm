part of fmvvm.bindings;

/// Used to define a property changed listener that sends notifications when
/// particular properties have changed.
typedef PropertyChangedListener = void Function(String propertyName);

/// Class to be extended when creating any non widget object that can be bound to.
abstract class BindableBase extends ChangeNotifier {
  ObserverList<PropertyChangedListener> _listeners =
      ObserverList<PropertyChangedListener>();

  FieldManager _fieldManager = FieldManager();

  /// Gives a new value to a property.
  @protected
  void setValue(PropertyInfo propertyInfo, Object value) {
    if (_fieldManager.getValue(propertyInfo) != value) {
      _fieldManager.setValue(propertyInfo, value);

      notifyPropertyListeners(propertyInfo.name);
    }
  }

  /// Returns the current value for a property.
  ///
  /// If the property has not been set, the default value will be returned.
  @protected
  Object getValue(PropertyInfo propertyInfo) {
    return _fieldManager.getValue(propertyInfo);
  }

  /// Adds a listener that when called returns the string name of a property that has changed as a parameter.
  void addPropertyListener(PropertyChangedListener listener) {
    _listeners.add(listener);
  }

  /// Removes a property listener
  void removePropertyListener(PropertyChangedListener listener) {
    _listeners.remove(listener);
  }

  /// Whether any listeners are currently registered.
  ///
  /// Clients should not depend on this value for their behavior, because having
  /// one listener's logic change when another listener happens to start or stop
  /// listening will lead to extremely hard-to-track bugs. Subclasses might use
  /// this information to determine whether to do any work when there are no
  /// listeners, however; for example, resuming a [Stream] when a listener is
  /// added and pausing it when a listener is removed.
  ///
  /// Typically this is used by overriding [addListener], checking if
  /// [hasListeners] is false before calling `super.addListener()`, and if so,
  /// starting whatever work is needed to determine when to call
  /// [notifyListeners]; and similarly, by overriding [removeListener], checking
  /// if [hasListeners] is false after calling `super.removeListener()`, and if
  /// so, stopping that same work.
  @override
  bool get hasListeners {
    return _listeners.isNotEmpty || super.hasListeners;
  }

  /// Call all the registered listeners.
  ///
  /// Call this method whenever the object changes, to notify any clients the
  /// object may have. Listeners that are added during this iteration will not
  /// be visited. Listeners that are removed during this iteration will not be
  /// visited after they are removed.
  ///
  /// Exceptions thrown by listeners will be caught and reported using
  /// [FlutterError.reportError].
  ///
  /// This method must not be called after [dispose] has been called.
  ///
  /// Surprising behavior can result when reentrantly removing a listener (i.e.
  /// in response to a notification) that has been registered multiple times.
  /// See the discussion at [removeListener].
  @protected
  void notifyPropertyListeners(String propertyName) {
    notifyListeners();
    if (_listeners != null) {
      final List<PropertyChangedListener> localListeners =
          List<PropertyChangedListener>.from(_listeners);
      for (var listener in localListeners) {
        if (_listeners.contains(listener)) {
          listener(propertyName);
        }
      }
    }
  }

  /// Discards any resources used by the object. After this is called, the
  /// object is not in a usable state and should be discarded (calls to
  /// [addListener] and [removeListener] will throw after the object is
  /// disposed).
  ///
  /// This method should only be called by the object's owner.
  @mustCallSuper
  void dispose() {
    super.dispose();
    _listeners = null;
  }
}
