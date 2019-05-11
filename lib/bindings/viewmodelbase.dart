part of fmvvm.bindings;

// Base object to be used to create ViewModels.
abstract class ViewModelBase extends BindableBase implements fmvvm_interfaces.ViewModel {
  /// Called after the constructer to initialize the viewmodel.
  /// 
  /// Any information passed to be viewmodel is set via the [parameter].
  void init(Object parameter) {}
}