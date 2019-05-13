part of fmvvm.bindings;

/// Interface to be implemented by objects that retain references to view models.
abstract class BindableBaseHolder<T extends BindableBase> {
  /// The class's viewmodel reference.
  T get bindableBase;
}
