part of fmvvm.bindings;

/// The NotificationList extends a normal list base and adds a ChangeNotifier
///
/// notifyListeners is called when any items are added or removed from the list.
class NotificationList<E> extends ListBase<E> with ChangeNotifier {
  List<E> _l = [];

  NotificationList();

  set length(int newLength) {
    _l.length = newLength;
  }

  int get length => _l.length;

  E operator [](int index) => _l[index];
  void operator []=(int index, E value) {
    _l[index] = value;
  }

  void add(E element) {
    super.add(element);
    notifyListeners();
  }

  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    notifyListeners();
  }

  bool remove(Object element) {
    var returnValue = super.remove(element);
    notifyListeners();
    return returnValue;
  }

  void removeWhere(bool test(E element)) {
    super.removeWhere(test);
    notifyListeners();
  }

  void retainWhere(bool test(E element)) {
    super.retainWhere(test);
    notifyListeners();
  }

  factory NotificationList.filled(int length, E fill, {bool growable = false}) {
    var returnList = NotificationList<E>();

    returnList._l = List<E>.filled(length, fill, growable: growable);
    return returnList;
  }

  factory NotificationList.from(Iterable elements, {bool growable = true}) {
    var returnList = NotificationList<E>();

    returnList._l = List.from(elements, growable: growable);
    return returnList;
  }

  factory NotificationList.of(Iterable<E> elements, {bool growable = true}) =>
      NotificationList<E>.from(elements, growable: growable);

  factory NotificationList.generate(int length, E generator(int index),
      {bool growable = true}) {
    var returnValue = NotificationList<E>();

    returnValue._l = List<E>.generate(length, generator, growable: growable);

    return returnValue;
  }

  factory NotificationList.unmodifiable(Iterable elements) {
    var returnList = NotificationList<E>();

    returnList._l = List<E>.unmodifiable(elements);
    return returnList;
  }

  static void copyRange<T>(
      NotificationList<T> target, int at, NotificationList<T> source,
      [int start, int end]) {
    List.copyRange(target, at, source);
  }

  static void writeIterable<T>(
      NotificationList<T> target, int at, Iterable<T> source) {
    List.writeIterable(target, at, source);
  }
}
