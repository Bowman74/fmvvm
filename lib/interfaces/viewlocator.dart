part of fmvvm.interfaces;

abstract class ViewLocator {
  String getViewFromViewModelType<T extends ViewModel>();
}