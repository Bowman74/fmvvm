part of fmvvm_interfaces;

abstract class ViewModel implements BindableBase {
  void init(Object parameter);

  void appeared();

  void disappeared();
}
