part of fmvvm.interfaces;

abstract class ViewModelHolder<T extends ViewModel> {
  T get viewModel;
}
