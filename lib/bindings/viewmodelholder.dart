part of fmvvm.bindings;

/// Interface to be implemented by objects that retain references to view models.
abstract class ViewModelHolder<T extends ViewModel> {
  /// The class's viewmodel reference.
  T get viewModel;
}