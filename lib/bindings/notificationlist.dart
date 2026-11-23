part of 'bindings.dart';

/// The NotificationList extends a normal list base and adds a ChangeNotifier
///
/// notifyListeners is called when any items are added or removed from the list.
class NotificationList<E> extends ListBase<E> with ChangeNotifier {
  List<E> _l = [];

  NotificationList();

  @override
  set length(int newLength) {
    _l.length = newLength;
  }

  @override
  int get length => _l.length;

  @override
  E operator [](int index) => _l[index];
  @override
  void operator []=(int index, E value) {
    _l[index] = value;
  }

  @override
  void add(E element) {
    _l.add(element);
    notifyListeners();
  }

  @override
  void addAll(Iterable<E> iterable) {
    super.addAll(iterable);
    notifyListeners();
  }

  @override
  bool remove(Object? element) {
    var returnValue = super.remove(element);
    notifyListeners();
    return returnValue;
  }

  @override
  void removeWhere(bool Function(E element) test) {
    super.removeWhere(test);
    notifyListeners();
  }

  @override
  void retainWhere(bool Function(E element) test) {
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

  factory NotificationList.generate(int length, E Function(int index) generator,
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
      [int? start, int? end]) {
    List.copyRange(target, at, source);
  }

  static void writeIterable<T>(
      NotificationList<T> target, int at, Iterable<T> source) {
    List.writeIterable(target, at, source);
  }
}
