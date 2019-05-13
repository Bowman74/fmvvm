part of fmvvm.bindings;

// Base object to be used to create ViewModels.
abstract class ViewModel extends BindableBase {
  /// Called after the constructer to initialize the viewmodel.
  ///
  /// Any information passed to be viewmodel is set via the [parameter].
  void init(Object parameter) {}
}
