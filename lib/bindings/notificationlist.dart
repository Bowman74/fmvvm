part of fmvvm.bindings;

class NotificationList<E> extends ListBase<E> implements NotifyChanges {
  StreamController _elementChangedController = StreamController.broadcast();

  final List<E> l = [];
  NotificationList();

  set length(int newLength) {
    l.length = newLength;
  }

  int get length => l.length;

  E operator [](int index) => l[index];
  void operator []=(int index, E value) {
    l[index] = value;
  }

  void add(E element) {
    super.add(element);
    elementChanged("");
  }

  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    elementChanged("");
  }

  bool remove(Object element) {
    var returnValue = super.remove(element);
    elementChanged("");
    return returnValue;
  }

  void removeWhere(bool test(E element)) {
    super.removeWhere(test);
    elementChanged("");
  }

  void retainWhere(bool test(E element)) {
    super.retainWhere(test);
    elementChanged("");
  }

  /// Method to call if an element has been changed so any listeners can be notified.
  ///
  /// Leave the [propertyName] blank to indicate the entire object has changed.
  @protected
  elementChanged(String propertyName) {
    _elementChangedController.add(propertyName);
  }

  /// Event raised when an element or the entire object has changed.
  Stream get onChanged => _elementChangedController.stream;
}
