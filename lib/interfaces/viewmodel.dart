part of fmvvm.interfaces;

abstract class ViewModel implements BindableBase {
  void init(Object parameter);

  void appeared();

  void disappeared();
}