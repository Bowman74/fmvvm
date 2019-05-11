part of fmvvm_interfaces;

abstract class ViewLocator {
  String getViewFromViewModelType<T extends ViewModel>();
}